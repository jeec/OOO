import SwiftUI

// MARK: - 学习中心视图
struct StudyCenterView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var wordService: WordService
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // 标签选择器
                Picker("学习类型", selection: $selectedTab) {
                    Text("推荐").tag(0)
                    Text("分类").tag(1)
                    Text("难度").tag(2)
                    Text("复习").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 内容区域
                TabView(selection: $selectedTab) {
                    RecommendedView()
                        .tag(0)
                    
                    CategoryView()
                        .tag(1)
                    
                    DifficultyView()
                        .tag(2)
                    
                    ReviewView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("学习中心")
        }
    }
}

// MARK: - 推荐学习
struct RecommendedView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var wordService: WordService
    @State private var recommendedWords: [Word] = []
    @State private var showStudyView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 学习建议
                LearningSuggestionCard()
                
                // 推荐单词
                if !recommendedWords.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("为你推荐")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(recommendedWords.prefix(9)) { word in
                                WordCard(word: word)
                            }
                        }
                        
                        Button("开始学习这些单词") {
                            showStudyView = true
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 3)
                }
            }
            .padding()
        }
        .onAppear {
            loadRecommendedWords()
        }
        .sheet(isPresented: $showStudyView) {
            StudyView()
        }
    }
    
    private func loadRecommendedWords() {
        if let user = userService.currentUser {
            recommendedWords = wordService.getWordsForStudy(userLevel: user.level, count: 20)
        }
    }
}

// MARK: - 学习建议卡片
struct LearningSuggestionCard: View {
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("学习建议")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            if let user = userService.currentUser {
                let levelInfo = UserLevel.getLevelInfo(for: user.totalXP)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("根据你的等级（\(levelInfo.title)），建议：")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        SuggestionItem(
                            icon: "book.fill",
                            text: "每天学习 \(user.learningGoals.dailyWords) 个新单词",
                            color: .blue
                        )
                        
                        SuggestionItem(
                            icon: "clock.fill",
                            text: "学习时间：\(user.learningGoals.studyTime) 分钟",
                            color: .green
                        )
                        
                        SuggestionItem(
                            icon: "target",
                            text: "重点练习：\(user.learningGoals.focusAreas.joined(separator: "、"))",
                            color: .orange
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

// MARK: - 建议项目
struct SuggestionItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 分类学习
struct CategoryView: View {
    @EnvironmentObject var wordService: WordService
    @State private var selectedCategory: WordCategory = .daily
    @State private var showStudyView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 分类选择
                VStack(alignment: .leading, spacing: 15) {
                    Text("选择学习分类")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(WordCategory.allCases, id: \.self) { category in
                            CategoryStudyCard(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 3)
                
                // 开始学习按钮
                Button("开始学习 \(selectedCategory.rawValue)") {
                    showStudyView = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            .padding()
        }
        .sheet(isPresented: $showStudyView) {
            StudyView()
        }
    }
}

// MARK: - 分类学习卡片
struct CategoryStudyCard: View {
    let category: WordCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? category.color : category.color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(category.color, lineWidth: isSelected ? 0 : 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 难度学习
struct DifficultyView: View {
    @EnvironmentObject var wordService: WordService
    @State private var selectedDifficulty: WordDifficulty = .beginner
    @State private var showStudyView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 难度选择
                VStack(alignment: .leading, spacing: 15) {
                    Text("选择学习难度")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(WordDifficulty.allCases, id: \.self) { difficulty in
                            DifficultyStudyCard(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                selectedDifficulty = difficulty
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 3)
                
                // 开始学习按钮
                Button("开始学习 \(selectedDifficulty.displayName) 单词") {
                    showStudyView = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            .padding()
        }
        .sheet(isPresented: $showStudyView) {
            StudyView()
        }
    }
}

// MARK: - 难度学习卡片
struct DifficultyStudyCard: View {
    let difficulty: WordDifficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(difficulty.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : difficulty.color)
                
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { index in
                        Circle()
                            .fill(index <= difficulty.rawValue ? (isSelected ? .white : difficulty.color) : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? difficulty.color : difficulty.color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(difficulty.color, lineWidth: isSelected ? 0 : 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 复习学习
struct ReviewView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var wordService: WordService
    @State private var reviewWords: [Word] = []
    @State private var showStudyView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 复习统计
                ReviewStatsCard()
                
                // 复习单词
                if !reviewWords.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("需要复习的单词")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(reviewWords.prefix(9)) { word in
                                WordCard(word: word)
                            }
                        }
                        
                        Button("开始复习") {
                            showStudyView = true
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 3)
                } else {
                    VStack(spacing: 15) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("太棒了！")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("没有需要复习的单词")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 3)
                }
            }
            .padding()
        }
        .onAppear {
            loadReviewWords()
        }
        .sheet(isPresented: $showStudyView) {
            StudyView()
        }
    }
    
    private func loadReviewWords() {
        if let user = userService.currentUser {
            reviewWords = wordService.getWordsForReview(userId: user.id)
        }
    }
}

// MARK: - 复习统计卡片
struct ReviewStatsCard: View {
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("复习统计")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            if let user = userService.currentUser {
                HStack(spacing: 20) {
                    StatItem(
                        title: "今日复习",
                        value: "0",
                        color: .blue
                    )
                    
                    StatItem(
                        title: "待复习",
                        value: "5",
                        color: .orange
                    )
                    
                    StatItem(
                        title: "已掌握",
                        value: "\(user.studyStats.totalWordsLearned)",
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

private struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    StudyCenterView()
        .environmentObject(UserService())
        .environmentObject(WordService())
}
