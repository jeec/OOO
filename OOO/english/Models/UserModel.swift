import Foundation
import SwiftUI

// MARK: - 用户模型
struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var email: String
    var avatar: String?
    var level: Int
    var totalXP: Int
    var streakDays: Int
    var lastLoginDate: Date
    var createdAt: Date
    var isPremium: Bool
    var learningGoals: LearningGoals
    var achievements: [Achievement]
    var studyStats: StudyStats
    
    init(username: String, email: String) {
        self.id = UUID()
        self.username = username
        self.email = email
        self.avatar = nil
        self.level = 1
        self.totalXP = 0
        self.streakDays = 0
        self.lastLoginDate = Date()
        self.createdAt = Date()
        self.isPremium = false
        self.learningGoals = LearningGoals()
        self.achievements = []
        self.studyStats = StudyStats()
    }
}

// MARK: - 学习目标
struct LearningGoals: Codable {
    var dailyWords: Int
    var studyTime: Int // 分钟
    var targetLevel: Int
    var focusAreas: [String] // 学习重点领域
    
    init() {
        self.dailyWords = 10
        self.studyTime = 15
        self.targetLevel = 5
        self.focusAreas = ["基础词汇", "日常对话"]
    }
}

// MARK: - 学习统计
struct StudyStats: Codable {
    var totalWordsLearned: Int
    var totalStudyTime: Int // 分钟
    var correctAnswers: Int
    var totalAnswers: Int
    var currentStreak: Int
    var longestStreak: Int
    var weeklyProgress: [Int] // 7天的学习进度
    var monthlyProgress: [Int] // 30天的学习进度
    var lastStudyDate: Date?
    
    init() {
        self.totalWordsLearned = 0
        self.totalStudyTime = 0
        self.correctAnswers = 0
        self.totalAnswers = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.weeklyProgress = Array(repeating: 0, count: 7)
        self.monthlyProgress = Array(repeating: 0, count: 30)
        self.lastStudyDate = nil
    }
    
    var accuracy: Double {
        guard totalAnswers > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalAnswers)
    }
}

// MARK: - 成就系统
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let xpReward: Int
    let isUnlocked: Bool
    let unlockedDate: Date?
    let category: AchievementCategory
    
    init(id: String, title: String, description: String, icon: String, xpReward: Int, category: AchievementCategory) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.xpReward = xpReward
        self.isUnlocked = false
        self.unlockedDate = nil
        self.category = category
    }
}

enum AchievementCategory: String, CaseIterable, Codable {
    case learning = "学习"
    case streak = "连续学习"
    case accuracy = "准确率"
    case time = "学习时间"
    case social = "社交"
    case special = "特殊"
}

// MARK: - 用户等级系统
struct UserLevel {
    static let levels = [
        (level: 1, xp: 0, title: "初学者"),
        (level: 2, xp: 100, title: "入门者"),
        (level: 3, xp: 300, title: "学习者"),
        (level: 4, xp: 600, title: "进步者"),
        (level: 5, xp: 1000, title: "熟练者"),
        (level: 6, xp: 1500, title: "进阶者"),
        (level: 7, xp: 2100, title: "高级者"),
        (level: 8, xp: 2800, title: "专家"),
        (level: 9, xp: 3600, title: "大师"),
        (level: 10, xp: 4500, title: "传奇")
    ]
    
    static func getLevelInfo(for xp: Int) -> (level: Int, title: String, progress: Double, nextLevelXP: Int) {
        for i in 0..<levels.count {
            let current = levels[i]
            let next = i < levels.count - 1 ? levels[i + 1] : levels[i]
            
            if xp >= current.xp && (i == levels.count - 1 || xp < next.xp) {
                let progress = i == levels.count - 1 ? 1.0 : Double(xp - current.xp) / Double(next.xp - current.xp)
                return (current.level, current.title, progress, next.xp)
            }
        }
        return (1, "初学者", 0.0, 100)
    }
}
