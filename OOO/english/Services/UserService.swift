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
        // 确保初始状态是未登录
        isLoggedIn = false
        currentUser = nil
        loadUser()
    }
    
    // MARK: - 用户认证
    func login(email: String, password: String) async -> Result<User, AuthError> {
        isLoading = true
        defer { isLoading = false }
        
        // 模拟网络请求
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒延迟
        
        // 简单的本地验证（实际应用中应该连接服务器）
        if email == "test@example.com" && password == "123456" {
            let user = User(username: "测试用户", email: email)
            print("设置登录状态前 - isLoggedIn: \(self.isLoggedIn)")
            self.currentUser = user
            self.isLoggedIn = true
            print("设置登录状态后 - isLoggedIn: \(self.isLoggedIn)")
            self.saveUser(user)
            return .success(user)
        } else {
            return .failure(.invalidCredentials)
        }
    }
    
    func register(username: String, email: String, password: String) async -> Result<User, AuthError> {
        isLoading = true
        defer { isLoading = false }
        
        // 模拟网络请求
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒延迟
        
        // 简单的本地验证
        if email.contains("@") && password.count >= 6 {
            let user = User(username: username, email: email)
            self.currentUser = user
            self.isLoggedIn = true
            self.saveUser(user)
            return .success(user)
        } else {
            return .failure(.invalidInput)
        }
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        userDefaults.removeObject(forKey: userKey)
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
    
    // MARK: - 数据持久化
    private func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            userDefaults.set(data, forKey: userKey)
        }
    }
    
    private func loadUser() {
        // 暂时禁用自动登录，确保显示登录页面
        // if let data = userDefaults.data(forKey: userKey),
        //    let user = try? JSONDecoder().decode(User.self, from: data) {
        //     currentUser = user
        //     isLoggedIn = true
        // }
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
