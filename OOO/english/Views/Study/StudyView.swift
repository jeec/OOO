import SwiftUI

// MARK: - 学习视图
struct StudyView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var wordService: WordService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: StudyMode = .cardGame
    @State private var selectedDifficulty: WordDifficulty = .beginner
    @State private var selectedCategory: WordCategory = .daily
    @State private var showGame = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 标题
                VStack(spacing: 10) {
                    Text("选择学习模式")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("选择适合你的学习方式")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // 学习模式选择
                VStack(spacing: 20) {
                    Text("学习模式")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        StudyModeCard(
                            mode: .cardGame,
                            title: "单词卡片",
                            description: "记忆单词",
                            icon: "rectangle.stack.fill",
                            color: .blue,
                            isSelected: selectedMode == .cardGame
                        ) {
                            selectedMode = .cardGame
                        }
                        
                        StudyModeCard(
                            mode: .spellingGame,
                            title: "拼写练习",
                            description: "练习拼写",
                            icon: "pencil",
                            color: .green,
                            isSelected: selectedMode == .spellingGame
                        ) {
                            selectedMode = .spellingGame
                        }
                        
                        StudyModeCard(
                            mode: .matchingGame,
                            title: "单词匹配",
                            description: "配对游戏",
                            icon: "puzzlepiece.fill",
                            color: .orange,
                            isSelected: selectedMode == .matchingGame
                        ) {
                            selectedMode = .matchingGame
                        }
                        
                        StudyModeCard(
                            mode: .listeningGame,
                            title: "听力训练",
                            description: "听力练习",
                            icon: "headphones",
                            color: .purple,
                            isSelected: selectedMode == .listeningGame
                        ) {
                            selectedMode = .listeningGame
                        }
                    }
                }
                
                // 难度选择
                VStack(spacing: 15) {
                    Text("难度选择")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(WordDifficulty.allCases, id: \.self) { difficulty in
                                DifficultyCard(
                                    difficulty: difficulty,
                                    isSelected: selectedDifficulty == difficulty
                                ) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 分类选择
                VStack(spacing: 15) {
                    Text("学习分类")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(WordCategory.allCases, id: \.self) { category in
                                CategoryCard(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 开始学习按钮
                Button("开始学习") {
                    showGame = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding()
            .navigationTitle("学习中心")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showGame) {
            StudyGameView(
                mode: selectedMode,
                difficulty: selectedDifficulty,
                category: selectedCategory
            )
        }
    }
}

// MARK: - 学习模式
enum StudyMode: String, CaseIterable {
    case cardGame = "单词卡片"
    case spellingGame = "拼写练习"
    case matchingGame = "单词匹配"
    case listeningGame = "听力训练"
}

// MARK: - 学习模式卡片
struct StudyModeCard: View {
    let mode: StudyMode
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? color : color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(color, lineWidth: isSelected ? 0 : 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 难度卡片
struct DifficultyCard: View {
    let difficulty: WordDifficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(difficulty.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : difficulty.color)
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Circle()
                            .fill(index <= difficulty.rawValue ? (isSelected ? .white : difficulty.color) : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? difficulty.color : difficulty.color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(difficulty.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 分类卡片
struct CategoryCard: View {
    let category: WordCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : category.color)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? category.color : category.color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(category.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 游戏视图
struct StudyGameView: View {
    let mode: StudyMode
    let difficulty: WordDifficulty
    let category: WordCategory
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var wordService: WordService
    @Environment(\.dismiss) private var dismiss
    @State private var words: [Word] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var showResult = false
    
    var body: some View {
        NavigationView {
            VStack {
                if words.isEmpty {
                    VStack {
                        SwiftUI.ProgressView()
                        Text("加载中...")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if currentIndex < words.count {
                    switch mode {
                    case .cardGame:
                        SimpleCardGameView(word: words[currentIndex])
                    case .spellingGame:
                        SimpleSpellingGameView(word: words[currentIndex])
                    case .matchingGame:
                        SimpleMatchingGameView(words: Array(words.prefix(6)))
                    case .listeningGame:
                        SimpleCardGameView(word: words[currentIndex])
                    }
                } else {
                    // 游戏结束
                    GameCompleteView(score: score, totalWords: words.count)
                }
            }
            .navigationTitle(mode.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("退出") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("分数: \(score)")
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadWords()
        }
    }
    
    private func loadWords() {
        words = wordService.getWords(by: category, difficulty: difficulty)
        if words.isEmpty {
            words = wordService.getWords(difficulty: difficulty)
        }
    }
}

// MARK: - 游戏完成视图
struct GameCompleteView: View {
    let score: Int
    let totalWords: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🎉 学习完成！")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 15) {
                Text("你的得分")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(score)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                Text("共学习 \(totalWords) 个单词")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button("继续学习") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

// MARK: - 简单游戏视图
struct SimpleCardGameView: View {
    let word: Word
    @State private var isFlipped = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("单词卡片")
                .font(.title)
                .fontWeight(.bold)
            
            Button(action: { isFlipped.toggle() }) {
                VStack(spacing: 20) {
                    if isFlipped {
                        Text(word.chinese)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    } else {
                        Text(word.english)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("点击翻转")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct SimpleSpellingGameView: View {
    let word: Word
    @State private var userInput = ""
    @State private var showResult = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("拼写练习")
                .font(.title)
                .fontWeight(.bold)
            
            Text(word.chinese)
                .font(.title2)
                .foregroundColor(.blue)
            
            TextField("请输入英文单词", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Button("检查") {
                showResult = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(userInput.isEmpty)
            
            if showResult {
                Text(userInput.lowercased() == word.english.lowercased() ? "正确！" : "错误")
                    .font(.headline)
                    .foregroundColor(userInput.lowercased() == word.english.lowercased() ? .green : .red)
            }
        }
        .padding()
    }
}

struct SimpleMatchingGameView: View {
    let words: [Word]
    @State private var selectedWords: [Word] = []
    @State private var matchedPairs = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("单词匹配")
                .font(.title)
                .fontWeight(.bold)
            
            Text("已匹配: \(matchedPairs) / \(words.count)")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(words) { word in
                    Button(action: {
                        if !selectedWords.contains(where: { $0.id == word.id }) {
                            selectedWords.append(word)
                        }
                    }) {
                        VStack {
                            Text(word.english)
                                .font(.headline)
                            Text(word.chinese)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
    }
}

#Preview {
    StudyView()
        .environmentObject(UserService())
        .environmentObject(WordService())
}
