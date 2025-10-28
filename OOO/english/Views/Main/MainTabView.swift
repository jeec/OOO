import SwiftUI

// MARK: - 主标签视图
struct MainTabView: View {
    @EnvironmentObject private var userService: UserService
    @EnvironmentObject private var wordService: WordService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 学习首页
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首页")
                }
                .tag(0)
            
            // 学习中心
            StudyCenterView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("学习")
                }
                .tag(1)
            
            // 进度统计
            LearningProgressView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("进度")
                }
                .tag(2)
            
            // 个人中心
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

// MARK: - 学习首页
struct HomeView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var wordService: WordService
    @State private var todayWords: [Word] = []
    @State private var showStudyView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 欢迎区域
                    WelcomeSection()
                    
                    // 今日学习
                    TodayStudySection(todayWords: todayWords) {
                        showStudyView = true
                    }
                    
                    // 学习统计
                    StudyStatsSection()
                    
                    // 快速开始
                    QuickStartSection {
                        showStudyView = true
                    }
                }
                .padding()
            }
            .navigationTitle("学习首页")
            .onAppear {
                loadTodayWords()
            }
        }
        .sheet(isPresented: $showStudyView) {
            StudyView()
        }
    }
    
    private func loadTodayWords() {
        if let user = userService.currentUser {
            todayWords = wordService.getWordsForStudy(userLevel: user.level, count: 10)
        }
    }
}

// MARK: - 欢迎区域
struct WelcomeSection: View {
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("你好，\(userService.currentUser?.username ?? "用户")！")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("今天也要努力学习哦")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 用户头像
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(userService.currentUser?.username.prefix(1).uppercased() ?? "U")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
            
            // 用户等级
            if let user = userService.currentUser {
                let levelInfo = UserLevel.getLevelInfo(for: user.totalXP)
                let progress = min(max(levelInfo.progress, 0.0), 1.0)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("等级 \(levelInfo.level) - \(levelInfo.title)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(user.totalXP) XP")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    SwiftUI.ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

// MARK: - 今日学习区域
struct TodayStudySection: View {
    let todayWords: [Word]
    let onStartStudy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("今日学习")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("开始学习") {
                    onStartStudy()
                }
                .buttonStyle(.borderedProminent)
            }
            
            if todayWords.isEmpty {
                Text("暂无学习内容")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(todayWords.prefix(6)) { word in
                        WordCard(word: word)
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

// MARK: - 单词卡片
struct WordCard: View {
    let word: Word
    
    var body: some View {
        VStack(spacing: 8) {
            Text(word.english)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(word.chinese)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            // 难度指示器
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Circle()
                        .fill(index <= word.difficulty.rawValue ? word.difficulty.color : Color.gray.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
            }
        }
        .padding(12)
        .background(word.difficulty.color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - 学习统计区域
struct StudyStatsSection: View {
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("学习统计")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let user = userService.currentUser {
                HStack(spacing: 20) {
                    MainStatItem(
                        title: "已学单词",
                        value: "\(user.studyStats.totalWordsLearned)",
                        icon: "book.fill",
                        color: .blue
                    )
                    
                    MainStatItem(
                        title: "连续天数",
                        value: "\(user.streakDays)",
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    MainStatItem(
                        title: "准确率",
                        value: "\(Int(user.studyStats.accuracy * 100))%",
                        icon: "target",
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

// MARK: - 统计项目
struct MainStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 快速开始区域
struct QuickStartSection: View {
    let onStartStudy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("快速开始")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                QuickStartCard(
                    title: "单词卡片",
                    icon: "rectangle.stack.fill",
                    color: .blue
                ) {
                    onStartStudy()
                }
                
                QuickStartCard(
                    title: "拼写练习",
                    icon: "pencil",
                    color: .green
                ) {
                    onStartStudy()
                }
                
                QuickStartCard(
                    title: "听力训练",
                    icon: "headphones",
                    color: .orange
                ) {
                    onStartStudy()
                }
                
                QuickStartCard(
                    title: "单词匹配",
                    icon: "puzzlepiece.fill",
                    color: .purple
                ) {
                    onStartStudy()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

// MARK: - 快速开始卡片
struct QuickStartCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
}
