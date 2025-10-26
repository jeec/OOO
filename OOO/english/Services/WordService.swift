import Foundation
import SwiftUI
import Combine

// MARK: - 单词服务
class WordService: ObservableObject {
    @Published var words: [Word] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let wordsKey = "wordsDatabase"
    
    init() {
        loadWords()
    }
     
    // MARK: - 单词数据管理
    func loadWords() {
        isLoading = true
        
        // 首先尝试从本地加载
        if let data = userDefaults.data(forKey: wordsKey),
           let savedWords = try? JSONDecoder().decode([Word].self, from: data) {
            words = savedWords
            isLoading = false
            return
        }
        
        // 如果没有本地数据，加载默认单词库
        loadDefaultWords()
    }
    
    private func loadDefaultWords() {
        // 简化默认单词库，避免初始化时卡住
        words = [
            Word(english: "Hello", chinese: "你好", pronunciation: "/həˈloʊ/", phonetic: "hə-LOH",
                 difficulty: .beginner, category: .daily, tags: ["问候", "基础"],
                 examples: [WordExample(english: "Hello, how are you?", chinese: "你好，你好吗？")],
                 frequency: 5, isEssential: true),
            
            Word(english: "Good", chinese: "好的", pronunciation: "/ɡʊd/", phonetic: "gud",
                 difficulty: .beginner, category: .daily, tags: ["形容词", "基础"],
                 examples: [WordExample(english: "Good morning!", chinese: "早上好！")],
                 frequency: 5, isEssential: true),
            
            Word(english: "Thank you", chinese: "谢谢", pronunciation: "/θæŋk ju/", phonetic: "thangk yoo",
                 difficulty: .beginner, category: .daily, tags: ["礼貌", "基础"],
                 examples: [WordExample(english: "Thank you very much!", chinese: "非常感谢！")],
                 frequency: 5, isEssential: true),
            
            Word(english: "Apple", chinese: "苹果", pronunciation: "/ˈæpəl/", phonetic: "AP-əl",
                 difficulty: .beginner, category: .food, tags: ["水果", "健康"],
                 examples: [WordExample(english: "I eat an apple every day.", chinese: "我每天吃一个苹果。")],
                 frequency: 3, isEssential: false),
            
            Word(english: "Computer", chinese: "电脑", pronunciation: "/kəmˈpjuːtər/", phonetic: "kəm-PYOO-tər",
                 difficulty: .elementary, category: .technology, tags: ["科技", "设备"],
                 examples: [WordExample(english: "I use my computer for work.", chinese: "我用电脑工作。")],
                 frequency: 4, isEssential: true)
        ]
        saveWords()
        isLoading = false
    }
    
    func saveWords() {
        if let data = try? JSONEncoder().encode(words) {
            userDefaults.set(data, forKey: wordsKey)
        }
    }
    
    // MARK: - 单词查询
    func getWords(by category: WordCategory? = nil, difficulty: WordDifficulty? = nil) -> [Word] {
        var filteredWords = words
        
        if let category = category {
            filteredWords = filteredWords.filter { $0.category == category }
        }
        
        if let difficulty = difficulty {
            filteredWords = filteredWords.filter { $0.difficulty == difficulty }
        }
        
        return filteredWords
    }
    
    func getWordsForStudy(userLevel: Int, count: Int = 20) -> [Word] {
        let targetDifficulty = getDifficultyForLevel(userLevel)
        let studyWords = getWords(difficulty: targetDifficulty)
        return Array(studyWords.shuffled().prefix(count))
    }
    
    func getWordsForReview(userId: UUID) -> [Word] {
        // 这里应该根据用户的学习记录来获取需要复习的单词
        // 暂时返回一些示例单词
        return Array(words.shuffled().prefix(10))
    }
    
    func searchWords(_ query: String) -> [Word] {
        return words.filter { word in
            word.english.localizedCaseInsensitiveContains(query) ||
            word.chinese.localizedCaseInsensitiveContains(query)
        }
    }
    
    // MARK: - 学习进度
    func recordStudySession(wordId: UUID, userId: UUID, studyType: StudyType, 
                           isCorrect: Bool, timeSpent: Int, difficulty: WordDifficulty) {
        let record = LearningRecord(
            wordId: wordId,
            userId: userId,
            studyType: studyType,
            isCorrect: isCorrect,
            timeSpent: timeSpent,
            difficulty: difficulty
        )
        
        // 这里应该保存学习记录到数据库
        // 暂时只打印日志
        print("学习记录: \(record)")
    }
    
    func getWordMasteryLevel(wordId: UUID, userId: UUID) -> MasteryLevel {
        // 这里应该根据学习记录计算掌握程度
        // 暂时返回随机值
        return MasteryLevel.allCases.randomElement() ?? .new
    }
    
    // MARK: - 辅助方法
    private func getDifficultyForLevel(_ level: Int) -> WordDifficulty {
        switch level {
        case 1...2: return .beginner
        case 3...4: return .elementary
        case 5...6: return .intermediate
        case 7...8: return .upperIntermediate
        default: return .advanced
        }
    }
}

// MARK: - 单词数据库
struct WordDatabase {
    static func getDefaultWords() -> [Word] {
        return [
            // 基础词汇
            Word(english: "Hello", chinese: "你好", pronunciation: "/həˈloʊ/", phonetic: "hə-LOH",
                 difficulty: .beginner, category: .daily, tags: ["问候", "基础"],
                 examples: [WordExample(english: "Hello, how are you?", chinese: "你好，你好吗？")],
                 frequency: 5, isEssential: true),
            
            Word(english: "Good", chinese: "好的", pronunciation: "/ɡʊd/", phonetic: "gud",
                 difficulty: .beginner, category: .daily, tags: ["形容词", "基础"],
                 examples: [WordExample(english: "Good morning!", chinese: "早上好！")],
                 frequency: 5, isEssential: true),
            
            Word(english: "Thank you", chinese: "谢谢", pronunciation: "/θæŋk ju/", phonetic: "thangk yoo",
                 difficulty: .beginner, category: .daily, tags: ["礼貌", "基础"],
                 examples: [WordExample(english: "Thank you very much!", chinese: "非常感谢！")],
                 frequency: 5, isEssential: true),
            
            // 工作词汇
            Word(english: "Meeting", chinese: "会议", pronunciation: "/ˈmiːtɪŋ/", phonetic: "MEE-ting",
                 difficulty: .elementary, category: .work, tags: ["工作", "商务"],
                 examples: [WordExample(english: "We have a meeting at 3 PM.", chinese: "我们下午3点有个会议。")],
                 frequency: 4, isEssential: true),
            
            Word(english: "Project", chinese: "项目", pronunciation: "/ˈprɑːdʒekt/", phonetic: "PRAH-jekt",
                 difficulty: .elementary, category: .work, tags: ["工作", "管理"],
                 examples: [WordExample(english: "This project is very important.", chinese: "这个项目很重要。")],
                 frequency: 4, isEssential: true),
            
            // 食物词汇
            Word(english: "Apple", chinese: "苹果", pronunciation: "/ˈæpəl/", phonetic: "AP-əl",
                 difficulty: .beginner, category: .food, tags: ["水果", "健康"],
                 examples: [WordExample(english: "I eat an apple every day.", chinese: "我每天吃一个苹果。")],
                 frequency: 3, isEssential: false),
            
            Word(english: "Restaurant", chinese: "餐厅", pronunciation: "/ˈrestərɑːnt/", phonetic: "RES-tə-rant",
                 difficulty: .elementary, category: .food, tags: ["餐饮", "场所"],
                 examples: [WordExample(english: "Let's go to a restaurant.", chinese: "我们去餐厅吧。")],
                 frequency: 3, isEssential: false),
            
            // 科技词汇
            Word(english: "Computer", chinese: "电脑", pronunciation: "/kəmˈpjuːtər/", phonetic: "kəm-PYOO-tər",
                 difficulty: .elementary, category: .technology, tags: ["科技", "设备"],
                 examples: [WordExample(english: "I use my computer for work.", chinese: "我用电脑工作。")],
                 frequency: 4, isEssential: true),
            
            Word(english: "Internet", chinese: "互联网", pronunciation: "/ˈɪntərnet/", phonetic: "IN-tər-net",
                 difficulty: .elementary, category: .technology, tags: ["科技", "网络"],
                 examples: [WordExample(english: "The internet is very useful.", chinese: "互联网很有用。")],
                 frequency: 4, isEssential: true),
            
            // 旅游词汇
            Word(english: "Travel", chinese: "旅行", pronunciation: "/ˈtrævəl/", phonetic: "TRAV-əl",
                 difficulty: .elementary, category: .travel, tags: ["旅游", "活动"],
                 examples: [WordExample(english: "I love to travel.", chinese: "我喜欢旅行。")],
                 frequency: 3, isEssential: false),
            
            Word(english: "Hotel", chinese: "酒店", pronunciation: "/hoʊˈtel/", phonetic: "ho-TEL",
                 difficulty: .elementary, category: .travel, tags: ["旅游", "住宿"],
                 examples: [WordExample(english: "We stayed at a nice hotel.", chinese: "我们住在一家不错的酒店。")],
                 frequency: 3, isEssential: false),
            
            // 健康词汇
            Word(english: "Health", chinese: "健康", pronunciation: "/helθ/", phonetic: "helth",
                 difficulty: .elementary, category: .health, tags: ["健康", "生活"],
                 examples: [WordExample(english: "Health is very important.", chinese: "健康很重要。")],
                 frequency: 4, isEssential: true),
            
            Word(english: "Exercise", chinese: "锻炼", pronunciation: "/ˈeksərsaɪz/", phonetic: "EK-sər-syz",
                 difficulty: .elementary, category: .health, tags: ["健康", "运动"],
                 examples: [WordExample(english: "Exercise is good for you.", chinese: "锻炼对你有好处。")],
                 frequency: 3, isEssential: false),
            
            // 教育词汇
            Word(english: "Education", chinese: "教育", pronunciation: "/ˌedʒəˈkeɪʃən/", phonetic: "ed-jə-KAY-shən",
                 difficulty: .intermediate, category: .education, tags: ["教育", "学习"],
                 examples: [WordExample(english: "Education is the key to success.", chinese: "教育是成功的关键。")],
                 frequency: 4, isEssential: true),
            
            Word(english: "Student", chinese: "学生", pronunciation: "/ˈstuːdənt/", phonetic: "STOO-dənt",
                 difficulty: .elementary, category: .education, tags: ["教育", "身份"],
                 examples: [WordExample(english: "I am a student.", chinese: "我是学生。")],
                 frequency: 4, isEssential: true),
            
            // 家庭词汇
            Word(english: "Family", chinese: "家庭", pronunciation: "/ˈfæməli/", phonetic: "FAM-ə-lee",
                 difficulty: .beginner, category: .family, tags: ["家庭", "关系"],
                 examples: [WordExample(english: "I love my family.", chinese: "我爱我的家庭。")],
                 frequency: 5, isEssential: true),
            
            Word(english: "Mother", chinese: "母亲", pronunciation: "/ˈmʌðər/", phonetic: "MUTH-ər",
                 difficulty: .beginner, category: .family, tags: ["家庭", "亲属"],
                 examples: [WordExample(english: "My mother is very kind.", chinese: "我的母亲很善良。")],
                 frequency: 5, isEssential: true),
            
            // 情感词汇
            Word(english: "Happy", chinese: "快乐的", pronunciation: "/ˈhæpi/", phonetic: "HAP-ee",
                 difficulty: .beginner, category: .emotion, tags: ["情感", "积极"],
                 examples: [WordExample(english: "I am very happy today.", chinese: "我今天很快乐。")],
                 frequency: 4, isEssential: true),
            
            Word(english: "Love", chinese: "爱", pronunciation: "/lʌv/", phonetic: "luv",
                 difficulty: .beginner, category: .emotion, tags: ["情感", "积极"],
                 examples: [WordExample(english: "I love you.", chinese: "我爱你。")],
                 frequency: 5, isEssential: true),
            
            // 商务词汇
            Word(english: "Business", chinese: "商业", pronunciation: "/ˈbɪznəs/", phonetic: "BIZ-nəs",
                 difficulty: .intermediate, category: .business, tags: ["商务", "经济"],
                 examples: [WordExample(english: "Business is good this year.", chinese: "今年生意很好。")],
                 frequency: 3, isEssential: false),
            
            Word(english: "Money", chinese: "钱", pronunciation: "/ˈmʌni/", phonetic: "MUN-ee",
                 difficulty: .beginner, category: .business, tags: ["商务", "金融"],
                 examples: [WordExample(english: "Money is important.", chinese: "钱很重要。")],
                 frequency: 4, isEssential: true)
        ]
    }
}
