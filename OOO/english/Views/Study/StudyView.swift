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
    @State private var wordStartTime = Date()
    
    private var currentWord: Word? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }
    
    private var studyType: StudyType {
        switch mode {
        case .cardGame: return .recognition
        case .spellingGame: return .spelling
        case .matchingGame: return .matching
        case .listeningGame: return .listening
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if words.isEmpty {
                    VStack(spacing: 12) {
                        SwiftUI.ProgressView()
                        Text("正在加载练习...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let word = currentWord {
                    content(for: word)
                } else {
                    GameCompleteView(score: score, totalWords: words.count) {
                        dismiss()
                    }
                }
            }
            .navigationTitle(mode.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("退出") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("分数: \(score)")
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear(perform: loadWords)
    }
    
    @ViewBuilder
    private func content(for word: Word) -> some View {
        switch mode {
        case .cardGame, .listeningGame:
            SimpleCardGameView(
                word: word,
                mode: mode,
                onRemember: { handleAnswer(isCorrect: true) },
                onRetry: { handleAnswer(isCorrect: false) }
            )
        case .spellingGame:
            SimpleSpellingGameView(
                word: word,
                onAnswer: { handleAnswer(isCorrect: $0) }
            )
        case .matchingGame:
            SimpleMatchingGameView(
                word: word,
                options: matchingOptions(for: word),
                onAnswer: { handleAnswer(isCorrect: $0) }
            )
        }
    }
    
    private func loadWords() {
        var selected = wordService.getWords(by: category, difficulty: difficulty)
        if selected.isEmpty {
            selected = wordService.getWords(difficulty: difficulty)
        }
        if selected.isEmpty {
            selected = wordService.words
        }
        words = Array(selected.shuffled().prefix(mode == .matchingGame ? 8 : 10))
        currentIndex = 0
        score = 0
        wordStartTime = Date()
    }
    
    private func matchingOptions(for word: Word) -> [Word] {
        var options: [Word] = [word]
        let candidates = wordService.words.filter { $0.id != word.id }.shuffled()
        for candidate in candidates {
            if options.count >= 4 { break }
            options.append(candidate)
        }
        return options.shuffled()
    }
    
    private func handleAnswer(isCorrect: Bool) {
        guard currentIndex < words.count else { return }
        let elapsed = max(Int(Date().timeIntervalSince(wordStartTime)), 1)
        let word = words[currentIndex]
        
        if let user = userService.currentUser {
            wordService.recordStudySession(
                wordId: word.id,
                userId: user.id,
                studyType: studyType,
                isCorrect: isCorrect,
                timeSpent: elapsed,
                difficulty: word.difficulty
            )
            userService.recordStudySession(for: word, isCorrect: isCorrect, timeSpent: elapsed)
        }
        
        if isCorrect {
            score += 10
        } else {
            score = max(0, score - 2)
        }
        
        currentIndex += 1
        wordStartTime = Date()
    }
}

// MARK: - 游戏完成视图
struct GameCompleteView: View {
    let score: Int
    let totalWords: Int
    let onFinish: () -> Void
    
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
                onFinish()
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
    let mode: StudyMode
    let onRemember: () -> Void
    let onRetry: () -> Void
    @State private var isFlipped = false
    @State private var hasAnswered = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text(mode == .listeningGame ? "听力训练" : "单词卡片")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                Text(word.english)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if mode == .listeningGame {
                    Text(word.pronunciation)
                        .font(.title3)
                        .foregroundColor(.blue)
                    Text(word.phonetic)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if isFlipped {
                    Text(word.chinese)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            .onTapGesture {
                withAnimation { isFlipped.toggle() }
            }
            
            Button(isFlipped ? "隐藏释义" : "显示释义") {
                withAnimation { isFlipped.toggle() }
            }
            .buttonStyle(.bordered)
            
            HStack(spacing: 20) {
                Button("再练练") {
                    guard !hasAnswered else { return }
                    hasAnswered = true
                    onRetry()
                }
                .buttonStyle(.bordered)
                
                Button("掌握了") {
                    guard !hasAnswered else { return }
                    hasAnswered = true
                    onRemember()
                }
                .buttonStyle(.borderedProminent)
            }
            .disabled(hasAnswered)
            
            if hasAnswered {
                Text("答案已记录，继续加油！")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onChange(of: word.id) { _ in
            isFlipped = false
            hasAnswered = false
        }
    }
}

struct SimpleSpellingGameView: View {
    let word: Word
    let onAnswer: (Bool) -> Void
    @State private var userInput = ""
    @State private var showResult = false
    @State private var isCorrect = false
    
    var body: some View {
        VStack(spacing: 24) {
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
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            Button("检查") {
                guard !showResult else { return }
                let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
                isCorrect = trimmed.lowercased() == word.english.lowercased()
                showResult = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || showResult)
            
            if showResult {
                Text(isCorrect ? "正确！" : "再试一次！")
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : .red)
                
                Button("下一题") {
                    onAnswer(isCorrect)
                    resetState()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .onChange(of: word.id) { _ in
            resetState()
        }
    }
    
    private func resetState() {
        userInput = ""
        showResult = false
        isCorrect = false
    }
}

struct SimpleMatchingGameView: View {
    let word: Word
    let options: [Word]
    let onAnswer: (Bool) -> Void
    @State private var selectedOption: UUID?
    @State private var hasAnswered = false
    @State private var isCorrect = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("单词匹配")
                .font(.title)
                .fontWeight(.bold)
            
            Text("请选择正确的中文释义")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text(word.english)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                ForEach(options, id: \.id) { option in
                    Button {
                        guard !hasAnswered else { return }
                        selectedOption = option.id
                        isCorrect = option.id == word.id
                        hasAnswered = true
                    } label: {
                        HStack {
                            Text(option.chinese)
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            if hasAnswered && selectedOption == option.id {
                                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(isCorrect ? .green : .red)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(selectedOption == option.id ? 0.2 : 0.1))
                        .cornerRadius(12)
                    }
                    .disabled(hasAnswered && selectedOption != option.id)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            
            if hasAnswered {
                Text(isCorrect ? "太棒了！" : "再接再厉！")
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : .red)
                
                Button("下一题") {
                    onAnswer(isCorrect)
                    resetState()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .onChange(of: word.id) { _ in
            resetState()
        }
    }
    
    private func resetState() {
        selectedOption = nil
        hasAnswered = false
        isCorrect = false
    }
}

#Preview {
    StudyView()
        .environmentObject(UserService())
        .environmentObject(WordService())
}
