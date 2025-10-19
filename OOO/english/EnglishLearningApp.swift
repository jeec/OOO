import SwiftUI
import Combine

// MARK: - 英语学习应用主文件
// 注意：这个文件不能有 @main，因为主项目已经有 @main

// MARK: - 主界面
struct EnglishLearningContentView: View {
    @StateObject private var gameManager = GameManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // 标题
                    VStack(spacing: 10) {
                        Text("🎓 英语学习乐园")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("让学习变得有趣！")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // 用户统计
                    UserStatsView(gameManager: gameManager)
                    
                    // 游戏模式选择
                    VStack(spacing: 20) {
                        Text("选择学习模式")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            GameModeCard(
                                title: "📚 单词卡片",
                                description: "记忆单词",
                                color: .blue,
                                action: { gameManager.startCardGame() }
                            )
                            
                            GameModeCard(
                                title: "✍️ 单词拼写",
                                description: "练习拼写",
                                color: .green,
                                action: { gameManager.startSpellingGame() }
                            )
                            
                            GameModeCard(
                                title: "🎯 单词匹配",
                                description: "配对游戏",
                                color: .orange,
                                action: { gameManager.startMatchingGame() }
                            )
                            
                            GameModeCard(
                                title: "🏆 成就中心",
                                description: "查看成就",
                                color: .purple,
                                action: { gameManager.openAchievements() }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $gameManager.showGame) {
            if let gameType = gameManager.currentGameType {
                EnglishGameView(gameType: gameType, gameManager: gameManager)
            }
        }
        .sheet(isPresented: $gameManager.showAchievements) {
            AchievementsView(gameManager: gameManager)
        }
    }
}

// MARK: - 用户统计视图
struct UserStatsView: View {
    let gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text("📊 学习统计")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 30) {
                StatItem(
                    title: "已学单词",
                    value: "\(gameManager.learnedWords)",
                    color: .blue
                )
                
                StatItem(
                    title: "连续天数",
                    value: "\(gameManager.streakDays)",
                    color: .green
                )
                
                StatItem(
                    title: "总分数",
                    value: "\(gameManager.totalScore)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

// MARK: - 统计项目
struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 游戏模式卡片
struct GameModeCard: View {
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
            .shadow(radius: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 游戏管理器
class GameManager: ObservableObject {
    @Published var showGame = false
    @Published var showAchievements = false
    @Published var currentGameType: GameType?
    
    // 用户数据
    @Published var learnedWords = 0
    @Published var streakDays = 0
    @Published var totalScore = 0
    
    // 游戏数据
    @Published var currentWord: Word?
    @Published var gameScore = 0
    @Published var gameLevel = 1
    
    func startCardGame() {
        currentGameType = .cardGame
        showGame = true
    }
    
    func startSpellingGame() {
        currentGameType = .spellingGame
        showGame = true
    }
    
    func startMatchingGame() {
        currentGameType = .matchingGame
        showGame = true
    }
    
    func openAchievements() {
        showAchievements = true
    }
    
    func updateScore(_ points: Int) {
        gameScore += points
        totalScore += points
    }
    
    func completeWord() {
        learnedWords += 1
    }
}

// MARK: - 游戏类型枚举
enum GameType {
    case cardGame
    case spellingGame
    case matchingGame
}

// MARK: - 单词模型
struct Word: Identifiable, Codable {
    let id = UUID()
    let english: String
    let chinese: String
    let pronunciation: String
    let difficulty: Int // 1-5 难度等级
    let category: String
    
    static let sampleWords = [
        Word(english: "Apple", chinese: "苹果", pronunciation: "/ˈæpəl/", difficulty: 1, category: "水果"),
        Word(english: "Book", chinese: "书", pronunciation: "/bʊk/", difficulty: 1, category: "学习"),
        Word(english: "Cat", chinese: "猫", pronunciation: "/kæt/", difficulty: 1, category: "动物"),
        Word(english: "Dog", chinese: "狗", pronunciation: "/dɔːɡ/", difficulty: 1, category: "动物"),
        Word(english: "Elephant", chinese: "大象", pronunciation: "/ˈeləfənt/", difficulty: 2, category: "动物"),
        Word(english: "Beautiful", chinese: "美丽的", pronunciation: "/ˈbjuːtɪfəl/", difficulty: 3, category: "形容词"),
        Word(english: "Adventure", chinese: "冒险", pronunciation: "/ədˈventʃər/", difficulty: 4, category: "名词"),
        Word(english: "Magnificent", chinese: "壮丽的", pronunciation: "/mæɡˈnɪfɪsənt/", difficulty: 5, category: "形容词")
    ]
}

// MARK: - 游戏视图
struct EnglishGameView: View {
    let gameType: GameType
    let gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    switch gameType {
                    case .cardGame:
                        CardGameView(gameManager: gameManager)
                    case .spellingGame:
                        SpellingGameView(gameManager: gameManager)
                    case .matchingGame:
                        MatchingGameView(gameManager: gameManager)
                    }
                }
            }
            .navigationTitle(gameTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("分数: \(gameManager.gameScore)")
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var gameTitle: String {
        switch gameType {
        case .cardGame:
            return "📚 单词卡片"
        case .spellingGame:
            return "✍️ 单词拼写"
        case .matchingGame:
            return "🎯 单词匹配"
        }
    }
}

// MARK: - 卡片游戏视图
struct CardGameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var isFlipped = false
    
    private let words = Word.sampleWords.shuffled()
    
    var body: some View {
        VStack(spacing: 30) {
            if currentIndex < words.count {
                let word = words[currentIndex]
                
                // 单词卡片
                VStack(spacing: 20) {
                    Text("第 \(currentIndex + 1) 个单词")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 200)
                            .shadow(radius: 10)
                        
                        VStack(spacing: 15) {
                            if !isFlipped {
                                Text(word.english)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("点击查看中文")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            } else {
                                Text(word.chinese)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(word.pronunciation)
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isFlipped.toggle()
                        }
                    }
                }
                
                // 操作按钮
                HStack(spacing: 20) {
                    Button("不认识") {
                        nextWord()
                    }
                    .buttonStyle(GameButtonStyle(color: .red))
                    
                    Button("认识") {
                        gameManager.updateScore(10)
                        gameManager.completeWord()
                        nextWord()
                    }
                    .buttonStyle(GameButtonStyle(color: .green))
                }
            } else {
                // 游戏结束
                VStack(spacing: 20) {
                    Text("🎉 恭喜完成！")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("你学会了 \(words.count) 个单词")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("获得分数: \(gameManager.gameScore)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
    }
    
    private func nextWord() {
        if currentIndex < words.count - 1 {
            currentIndex += 1
            isFlipped = false
        }
    }
}

// MARK: - 拼写游戏视图
struct SpellingGameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var currentIndex = 0
    @State private var userInput = ""
    @State private var showResult = false
    @State private var isCorrect = false
    
    private let words = Word.sampleWords.shuffled()
    
    var body: some View {
        VStack(spacing: 30) {
            if currentIndex < words.count {
                let word = words[currentIndex]
                
                VStack(spacing: 20) {
                    Text("第 \(currentIndex + 1) 个单词")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // 中文提示
                    Text(word.chinese)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("发音: \(word.pronunciation)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    // 输入框
                    TextField("请输入英文单词", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onSubmit {
                            checkAnswer()
                        }
                    
                    // 检查按钮
                    Button("检查答案") {
                        checkAnswer()
                    }
                    .buttonStyle(GameButtonStyle(color: .blue))
                    .disabled(userInput.isEmpty)
                    
                    // 结果显示
                    if showResult {
                        VStack(spacing: 10) {
                            Text(isCorrect ? "✅ 正确！" : "❌ 错误")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(isCorrect ? .green : .red)
                            
                            if !isCorrect {
                                Text("正确答案: \(word.english)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button("下一个") {
                                nextWord()
                            }
                            .buttonStyle(GameButtonStyle(color: .green))
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                }
            } else {
                // 游戏结束
                VStack(spacing: 20) {
                    Text("🎉 拼写练习完成！")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("获得分数: \(gameManager.gameScore)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
    }
    
    private func checkAnswer() {
        let word = words[currentIndex]
        isCorrect = userInput.lowercased() == word.english.lowercased()
        showResult = true
        
        if isCorrect {
            gameManager.updateScore(20)
            gameManager.completeWord()
        }
    }
    
    private func nextWord() {
        if currentIndex < words.count - 1 {
            currentIndex += 1
            userInput = ""
            showResult = false
        }
    }
}

// MARK: - 匹配游戏视图
struct MatchingGameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedCards: [Int] = []
    @State private var matchedPairs = 0
    @State private var gameWords: [GameWord] = []
    @State private var gameComplete = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎯 单词匹配游戏")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("找到对应的中英文单词")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if !gameComplete {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(Array(gameWords.enumerated()), id: \.offset) { index, word in
                        MatchingCard(
                            word: word,
                            isSelected: selectedCards.contains(index),
                            isMatched: word.isMatched
                        ) {
                            selectCard(at: index)
                        }
                    }
                }
                .padding()
            } else {
                VStack(spacing: 20) {
                    Text("🎉 匹配完成！")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("获得分数: \(gameManager.gameScore)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .onAppear {
            setupGame()
        }
    }
    
    private func setupGame() {
        let selectedWords = Array(Word.sampleWords.prefix(6))
        gameWords = selectedWords.flatMap { word in
            [
                GameWord(text: word.english, type: .english, originalWord: word),
                GameWord(text: word.chinese, type: .chinese, originalWord: word)
            ]
        }.shuffled()
    }
    
    private func selectCard(at index: Int) {
        guard !gameWords[index].isMatched else { return }
        
        if selectedCards.count == 2 {
            selectedCards.removeAll()
        }
        
        selectedCards.append(index)
        
        if selectedCards.count == 2 {
            checkMatch()
        }
    }
    
    private func checkMatch() {
        let firstIndex = selectedCards[0]
        let secondIndex = selectedCards[1]
        
        let firstWord = gameWords[firstIndex]
        let secondWord = gameWords[secondIndex]
        
        if firstWord.originalWord.id == secondWord.originalWord.id {
            // 匹配成功
            gameWords[firstIndex].isMatched = true
            gameWords[secondIndex].isMatched = true
            matchedPairs += 1
            gameManager.updateScore(15)
            gameManager.completeWord()
            
            if matchedPairs == 6 {
                gameComplete = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            selectedCards.removeAll()
        }
    }
}

// MARK: - 匹配卡片
struct MatchingCard: View {
    let word: GameWord
    let isSelected: Bool
    let isMatched: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(word.text)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            isMatched ? Color.green :
                            isSelected ? Color.blue :
                            word.type == .english ? Color.orange : Color.purple
                        )
                )
                .shadow(radius: isSelected ? 5 : 2)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - 游戏单词模型
struct GameWord {
    let text: String
    let type: WordType
    let originalWord: Word
    var isMatched = false
}

enum WordType {
    case english
    case chinese
}

// MARK: - 游戏按钮样式
struct GameButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - 成就视图
struct AchievementsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🏆 成就中心")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                VStack(spacing: 15) {
                    AchievementItem(
                        title: "初学者",
                        description: "学会第一个单词",
                        isUnlocked: gameManager.learnedWords >= 1,
                        icon: "🌟"
                    )
                    
                    AchievementItem(
                        title: "单词达人",
                        description: "学会10个单词",
                        isUnlocked: gameManager.learnedWords >= 10,
                        icon: "📚"
                    )
                    
                    AchievementItem(
                        title: "学习狂人",
                        description: "学会50个单词",
                        isUnlocked: gameManager.learnedWords >= 50,
                        icon: "🎓"
                    )
                    
                    AchievementItem(
                        title: "分数大师",
                        description: "获得1000分",
                        isUnlocked: gameManager.totalScore >= 1000,
                        icon: "💎"
                    )
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 成就项目
struct AchievementItem: View {
    let title: String
    let description: String
    let isUnlocked: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.title)
                .opacity(isUnlocked ? 1.0 : 0.3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isUnlocked {
                Text("✅")
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isUnlocked ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    EnglishLearningContentView()
}
