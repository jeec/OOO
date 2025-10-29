import Foundation
import SwiftUI
import Combine

// MARK: - 用户服务
@MainActor
class UserService: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "currentUser"
    
    init() {
        loadUser()
    }
    
    // MARK: - 用户认证
    func login(email: String, password: String) async -> Result<User, AuthError> {
        isLoading = true
        defer { isLoading = false }
        
        guard !email.isEmpty else { return .failure(.invalidInput) }
        guard password.count >= 4 else { return .failure(.invalidInput) }
        
        let nameHint = email.split(separator: "@").first.map { String($0) } ?? "口语学员"
        let displayName = nameHint.capitalized.isEmpty ? "口语学员" : nameHint.capitalized
        let user = User(username: displayName, email: email)
        self.currentUser = user
        self.isLoggedIn = true
        self.saveUser(user)
        return .success(user)
    }
    
    func register(username: String, email: String, password: String) async -> Result<User, AuthError> {
        isLoading = true
        defer { isLoading = false }
        
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              email.contains("@"),
              password.count >= 4 else {
            return .failure(.invalidInput)
        }
        
        let user = User(username: username, email: email)
        self.currentUser = user
        self.isLoggedIn = true
        self.saveUser(user)
        return .success(user)
    }
    
    func logout() {
        provisionGuestAccount(resetProgress: false)
    }
    
    // MARK: - 用户数据管理
    func updateUser(_ user: User) {
        currentUser = user
        saveUser(user)
    }
    
    func addXP(_ xp: Int) {
        guard var user = currentUser else { return }
        user.totalXP += xp
        
        // 检查是否升级
        let levelInfo = UserLevel.getLevelInfo(for: user.totalXP)
        if levelInfo.level > user.level {
            user.level = levelInfo.level
            // 可以在这里触发升级动画或通知
        }
        
        updateUser(user)
    }
    
    func updateStreak() {
        guard var user = currentUser else { return }
        let today = Calendar.current.startOfDay(for: Date())
        let lastLogin = Calendar.current.startOfDay(for: user.lastLoginDate)
        
        if today > lastLogin {
            if Calendar.current.dateInterval(of: .day, for: lastLogin)?.end == today {
                user.streakDays += 1
            } else {
                user.streakDays = 1
            }
            user.lastLoginDate = Date()
            updateUser(user)
        }
    }
    
    func unlockAchievement(_ achievement: Achievement) {
        guard var user = currentUser else { return }
        
        if !user.achievements.contains(where: { $0.id == achievement.id }) {
            var newAchievement = achievement
            newAchievement = Achievement(
                id: achievement.id,
                title: achievement.title,
                description: achievement.description,
                icon: achievement.icon,
                xpReward: achievement.xpReward,
                category: achievement.category
            )
            // 这里需要修改Achievement结构体以支持可变状态
            user.achievements.append(newAchievement)
            addXP(achievement.xpReward)
            updateUser(user)
        }
    }
    
    // MARK: - 学习记录
    func recordStudySession(for word: Word, isCorrect: Bool, timeSpent: Int) {
        guard var user = currentUser else { return }
        
        user.studyStats.totalAnswers += 1
        if isCorrect {
            user.studyStats.correctAnswers += 1
            user.studyStats.totalWordsLearned += 1
        }
        
        let studyMinutes = max(1, Int(round(Double(timeSpent) / 60.0)))
        user.studyStats.totalStudyTime += studyMinutes
        
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        if let lastStudy = user.studyStats.lastStudyDate {
            let lastDay = calendar.startOfDay(for: lastStudy)
            if calendar.isDate(today, inSameDayAs: lastDay) {
                // 同一天学习，不改变 streak
            } else if let nextDay = calendar.date(byAdding: .day, value: 1, to: lastDay),
                      calendar.isDate(nextDay, inSameDayAs: today) {
                user.studyStats.currentStreak += 1
            } else {
                user.studyStats.currentStreak = 1
            }
        } else {
            user.studyStats.currentStreak = 1
        }
        
        user.studyStats.lastStudyDate = now
        user.studyStats.longestStreak = max(user.studyStats.longestStreak, user.studyStats.currentStreak)
        user.streakDays = user.studyStats.currentStreak
        user.lastLoginDate = now
        
        let weekdayIndex = (calendar.component(.weekday, from: today) + 5) % 7
        if user.studyStats.weeklyProgress.indices.contains(weekdayIndex) {
            user.studyStats.weeklyProgress[weekdayIndex] += 1
        }
        
        let dayIndex = calendar.component(.day, from: today) - 1
        if user.studyStats.monthlyProgress.indices.contains(dayIndex) {
            user.studyStats.monthlyProgress[dayIndex] += 1
        }
        
        updateUser(user)
        
        let xpGain = isCorrect ? 10 : 2
        addXP(xpGain)
    }
    
    // MARK: - 数据持久化
    private func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            userDefaults.set(data, forKey: userKey)
        }
    }
    
    private func loadUser() {
        if let data = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isLoggedIn = true
        } else {
            provisionGuestAccount(resetProgress: true)
        }
    }
    
    private func provisionGuestAccount(resetProgress: Bool) {
        var guest = User(username: "口语新手", email: "guest@practice.app")
        if !resetProgress, let existing = currentUser {
            guest.totalXP = existing.totalXP
            guest.level = existing.level
            guest.streakDays = existing.streakDays
            guest.studyStats = existing.studyStats
            guest.learningGoals = existing.learningGoals
        }
        guest.isPremium = false
        guest.learningGoals.dailyWords = 5
        currentUser = guest
        isLoggedIn = true
        saveUser(guest)
    }
}

// MARK: - 认证错误
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case invalidInput
    case networkError
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "邮箱或密码错误"
        case .invalidInput:
            return "输入信息无效"
        case .networkError:
            return "网络连接失败"
        case .userNotFound:
            return "用户不存在"
        }
    }
}
