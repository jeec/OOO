import SwiftUI

// MARK: - 个人中心视图
struct ProfileView: View {
    @EnvironmentObject var userService: UserService
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户信息卡片
                    UserInfoCard()
                    
                    // 学习统计
                    LearningStatsSection()
                    
                    // 功能菜单
                    FunctionMenuSection(
                        showSettings: $showSettings,
                        showAchievements: $showAchievements,
                        showLogoutAlert: $showLogoutAlert
                    )
                    
                    // 学习目标
                    LearningGoalsSection()
                }
                .padding()
            }
            .navigationTitle("个人中心")
        }
        .alert("确认退出", isPresented: $showLogoutAlert) {
            Button("取消", role: .cancel) { }
            Button("退出", role: .destructive) {
                userService.logout()
            }
        } message: {
            Text("确定要退出登录吗？")
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showAchievements) {
            ProfileAchievementsView()
        }
    }
}

// MARK: - 用户信息卡片
struct UserInfoCard: View {
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(spacing: 20) {
            // 用户头像和基本信息
            HStack(spacing: 15) {
                // 头像
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(userService.currentUser?.username.prefix(1).uppercased() ?? "U")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                // 用户信息
                VStack(alignment: .leading, spacing: 8) {
                    Text(userService.currentUser?.username ?? "用户")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(userService.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let user = userService.currentUser {
                        let levelInfo = UserLevel.getLevelInfo(for: user.totalXP)
                        Text("等级 \(levelInfo.level) - \(levelInfo.title)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            
            // 等级进度
            if let user = userService.currentUser {
                let levelInfo = UserLevel.getLevelInfo(for: user.totalXP)
                let levelProgress = min(max(levelInfo.progress, 0.0), 1.0)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("等级进度")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(user.totalXP) / \(levelInfo.nextLevelXP) XP")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    SwiftUI.ProgressView(value: levelProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

// MARK: - 学习统计区域
struct LearningStatsSection: View {
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("学习统计")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let user = userService.currentUser {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    StatCard(
                        title: "已学单词",
                        value: "\(user.studyStats.totalWordsLearned)",
                        icon: "book.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "学习时间",
                        value: "\(user.studyStats.totalStudyTime)分钟",
                        icon: "clock.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "连续天数",
                        value: "\(user.streakDays)",
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "准确率",
                        value: "\(Int(user.studyStats.accuracy * 100))%",
                        icon: "target",
                        color: .purple
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

// MARK: - 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
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
        .frame(height: 100)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - 功能菜单区域
struct FunctionMenuSection: View {
    @Binding var showSettings: Bool
    @Binding var showAchievements: Bool
    @Binding var showLogoutAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("功能菜单")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                MenuItem(
                    icon: "gearshape.fill",
                    title: "设置",
                    color: .gray
                ) {
                    showSettings = true
                }
                
                MenuItem(
                    icon: "trophy.fill",
                    title: "成就中心",
                    color: .yellow
                ) {
                    showAchievements = true
                }
                
                MenuItem(
                    icon: "chart.bar.fill",
                    title: "学习报告",
                    color: .blue
                ) {
                    // 跳转到学习报告
                }
                
                MenuItem(
                    icon: "questionmark.circle.fill",
                    title: "帮助与反馈",
                    color: .green
                ) {
                    // 跳转到帮助页面
                }
                
                MenuItem(
                    icon: "info.circle.fill",
                    title: "关于我们",
                    color: .purple
                ) {
                    // 跳转到关于页面
                }
                
                MenuItem(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "退出登录",
                    color: .red
                ) {
                    showLogoutAlert = true
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

// MARK: - 菜单项目
struct MenuItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 学习目标区域
struct LearningGoalsSection: View {
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("学习目标")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let user = userService.currentUser {
                VStack(spacing: 12) {
                    GoalItem(
                        icon: "book.fill",
                        title: "每日单词",
                        value: "\(user.learningGoals.dailyWords)个",
                        progress: 0.5,
                        color: .blue
                    )
                    
                    GoalItem(
                        icon: "clock.fill",
                        title: "学习时间",
                        value: "\(user.learningGoals.studyTime)分钟",
                        progress: 0.3,
                        color: .green
                    )
                    
                    GoalItem(
                        icon: "target",
                        title: "目标等级",
                        value: "等级\(user.learningGoals.targetLevel)",
                        progress: 0.7,
                        color: .orange
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

// MARK: - 目标项目
struct GoalItem: View {
    let icon: String
    let title: String
    let value: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            SwiftUI.ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
    }
}

// MARK: - 设置视图
struct SettingsView: View {
    @EnvironmentObject var userService: UserService
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                Section("学习设置") {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                        Text("学习提醒")
                        Spacer()
                        Toggle("", isOn: $notificationsEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.green)
                        Text("音效")
                        Spacer()
                        Toggle("", isOn: $soundEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .foregroundColor(.orange)
                        Text("震动反馈")
                        Spacer()
                        Toggle("", isOn: $vibrationEnabled)
                    }
                }
                
                Section("学习目标") {
                    if let user = userService.currentUser {
                        HStack {
                            Text("每日单词")
                            Spacer()
                            Text("\(user.learningGoals.dailyWords)个")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("学习时间")
                            Spacer()
                            Text("\(user.learningGoals.studyTime)分钟")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("英语学习团队")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 成就视图
struct ProfileAchievementsView: View {
    @EnvironmentObject var userService: UserService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(AchievementDatabase.getAllAchievements()) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
            .navigationTitle("成就中心")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 成就卡片
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 30))
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            
            Text(achievement.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            if achievement.isUnlocked {
                Text("+\(achievement.xpReward) XP")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(achievement.isUnlocked ? Color.yellow : Color.gray, lineWidth: 2)
        )
    }
}

// MARK: - 成就数据库
struct AchievementDatabase {
    static func getAllAchievements() -> [Achievement] {
        return [
            Achievement(
                id: "first_word",
                title: "初学者",
                description: "学会第一个单词",
                icon: "star.fill",
                xpReward: 10,
                category: .learning
            ),
            Achievement(
                id: "word_master",
                title: "单词达人",
                description: "学会100个单词",
                icon: "book.fill",
                xpReward: 50,
                category: .learning
            ),
            Achievement(
                id: "streak_7",
                title: "坚持不懈",
                description: "连续学习7天",
                icon: "flame.fill",
                xpReward: 30,
                category: .streak
            ),
            Achievement(
                id: "accuracy_90",
                title: "准确率大师",
                description: "准确率达到90%",
                icon: "target",
                xpReward: 40,
                category: .accuracy
            )
        ]
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserService())
}
