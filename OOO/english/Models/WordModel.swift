import Foundation
import SwiftUI

// MARK: - 单词模型
struct Word: Identifiable, Codable, Hashable {
    let id: UUID
    let english: String
    let chinese: String
    let pronunciation: String
    let phonetic: String
    let difficulty: WordDifficulty
    let category: WordCategory
    let tags: [String]
    let examples: [WordExample]
    let synonyms: [String]
    let antonyms: [String]
    let frequency: Int // 使用频率 1-5
    let isEssential: Bool // 是否为核心词汇
    
    init(english: String, chinese: String, pronunciation: String, phonetic: String, 
         difficulty: WordDifficulty, category: WordCategory, tags: [String] = [],
         examples: [WordExample] = [], synonyms: [String] = [], antonyms: [String] = [],
         frequency: Int = 3, isEssential: Bool = false) {
        self.id = UUID()
        self.english = english
        self.chinese = chinese
        self.pronunciation = pronunciation
        self.phonetic = phonetic
        self.difficulty = difficulty
        self.category = category
        self.tags = tags
        self.examples = examples
        self.synonyms = synonyms
        self.antonyms = antonyms
        self.frequency = frequency
        self.isEssential = isEssential
    }
}

// MARK: - 单词难度
enum WordDifficulty: Int, CaseIterable, Codable {
    case beginner = 1
    case elementary = 2
    case intermediate = 3
    case upperIntermediate = 4
    case advanced = 5
    
    var displayName: String {
        switch self {
        case .beginner: return "初级"
        case .elementary: return "基础"
        case .intermediate: return "中级"
        case .upperIntermediate: return "中高级"
        case .advanced: return "高级"
        }
    }
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .elementary: return .blue
        case .intermediate: return .orange
        case .upperIntermediate: return .purple
        case .advanced: return .red
        }
    }
}

// MARK: - 单词分类
enum WordCategory: String, CaseIterable, Codable {
    case daily = "日常生活"
    case work = "工作职场"
    case travel = "旅游出行"
    case food = "美食餐饮"
    case health = "健康医疗"
    case education = "教育培训"
    case technology = "科技数码"
    case entertainment = "娱乐休闲"
    case sports = "体育运动"
    case nature = "自然环境"
    case family = "家庭关系"
    case emotion = "情感表达"
    case business = "商务贸易"
    case academic = "学术研究"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .daily: return "house.fill"
        case .work: return "briefcase.fill"
        case .travel: return "airplane"
        case .food: return "fork.knife"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .technology: return "laptopcomputer"
        case .entertainment: return "tv.fill"
        case .sports: return "sportscourt"
        case .nature: return "leaf.fill"
        case .family: return "person.2.fill"
        case .emotion: return "heart.circle.fill"
        case .business: return "chart.line.uptrend.xyaxis"
        case .academic: return "graduationcap.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .daily: return .blue
        case .work: return .gray
        case .travel: return .cyan
        case .food: return .orange
        case .health: return .red
        case .education: return .purple
        case .technology: return .indigo
        case .entertainment: return .pink
        case .sports: return .green
        case .nature: return .mint
        case .family: return .yellow
        case .emotion: return .red
        case .business: return .brown
        case .academic: return .blue
        case .other: return .gray
        }
    }
}

// MARK: - 单词例句
struct WordExample: Identifiable, Codable, Hashable {
    let id: UUID
    let english: String
    let chinese: String
    let context: String? // 使用场景
    
    init(english: String, chinese: String, context: String? = nil) {
        self.id = UUID()
        self.english = english
        self.chinese = chinese
        self.context = context
    }
}

// MARK: - 学习记录
struct LearningRecord: Identifiable, Codable {
    let id: UUID
    let wordId: UUID
    let userId: UUID
    let studyDate: Date
    let studyType: StudyType
    let isCorrect: Bool
    let timeSpent: Int // 秒
    let difficulty: WordDifficulty
    let masteryLevel: MasteryLevel
    
    init(wordId: UUID, userId: UUID, studyType: StudyType, isCorrect: Bool, 
         timeSpent: Int, difficulty: WordDifficulty, masteryLevel: MasteryLevel = .new) {
        self.id = UUID()
        self.wordId = wordId
        self.userId = userId
        self.studyDate = Date()
        self.studyType = studyType
        self.isCorrect = isCorrect
        self.timeSpent = timeSpent
        self.difficulty = difficulty
        self.masteryLevel = masteryLevel
    }
}

enum StudyType: String, CaseIterable, Codable {
    case recognition = "识别"
    case spelling = "拼写"
    case listening = "听力"
    case speaking = "口语"
    case matching = "配对"
    case translation = "翻译"
}

enum MasteryLevel: Int, CaseIterable, Codable {
    case new = 0
    case learning = 1
    case familiar = 2
    case mastered = 3
    
    var displayName: String {
        switch self {
        case .new: return "新词"
        case .learning: return "学习中"
        case .familiar: return "熟悉"
        case .mastered: return "已掌握"
        }
    }
    
    var color: Color {
        switch self {
        case .new: return .gray
        case .learning: return .orange
        case .familiar: return .blue
        case .mastered: return .green
        }
    }
}

// MARK: - 学习计划
struct StudyPlan: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let name: String
    let description: String
    let targetWords: Int
    let dailyWords: Int
    let duration: Int // 天数
    let difficulty: WordDifficulty
    let categories: [WordCategory]
    let isActive: Bool
    let createdAt: Date
    let startDate: Date?
    let endDate: Date?
    
    init(userId: UUID, name: String, description: String, targetWords: Int, 
         dailyWords: Int, duration: Int, difficulty: WordDifficulty, categories: [WordCategory]) {
        self.id = UUID()
        self.userId = userId
        self.name = name
        self.description = description
        self.targetWords = targetWords
        self.dailyWords = dailyWords
        self.duration = duration
        self.difficulty = difficulty
        self.categories = categories
        self.isActive = false
        self.createdAt = Date()
        self.startDate = nil
        self.endDate = nil
    }
}
