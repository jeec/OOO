import SwiftUI

// MARK: - 进度视图
struct ProgressView: View {
    @EnvironmentObject var userService: UserService
    @State private var selectedTimeRange: TimeRange = .week
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 时间范围选择
                    TimeRangeSelector(selectedRange: $selectedTimeRange)
                    
                    // 学习统计
                    LearningStatsCard()
                    
                    // 进度图表
                    ProgressChartCard(timeRange: selectedTimeRange)
                    
                    // 成就展示
                    AchievementsCard()
                    
                    // 学习建议
                    LearningTipsCard()
                }
                .padding()
            }
            .navigationTitle("学习进度")
        }
    }
}

// MARK: - 时间范围
enum TimeRange: String, CaseIterable {
    case week = "本周"
    case month = "本月"
    case year = "今年"
    case all = "全部"
}

// MARK: - 时间范围选择器
struct TimeRangeSelector: View {
    @Binding var selectedRange: TimeRange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("时间范围")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button(range.rawValue) {
                        selectedRange = range
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(selectedRange == range ? .white : .blue)
                    .background(selectedRange == range ? Color.blue : Color.clear)
                    .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

// MARK: - 学习统计卡片
struct LearningStatsCard: View {
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("学习统计")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let user = userService.currentUser {
                let levelInfo = UserLevel.getLevelInfo(for: user.totalXP)
                
                VStack(spacing: 15) {
                    // 等级进度
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("当前等级")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(levelInfo.level)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        Text(levelInfo.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ProgressView()
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                        
                        HStack {
                            Text("\(user.totalXP) XP")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("下一级: \(levelInfo.nextLevelXP) XP")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 统计数据
                    HStack(spacing: 20) {
                        StatItem(
                            title: "已学单词",
                            value: "\(user.studyStats.totalWordsLearned)",
                            color: .green
                        )
                        
                        StatItem(
                            title: "学习时间",
                            value: "\(user.studyStats.totalStudyTime)分钟",
                            color: .orange
                        )
                        
                        StatItem(
                            title: "准确率",
                            value: "\(Int(user.studyStats.accuracy * 100))%",
                            color: .purple
                        )
                    }
                    
                    // 连续学习
                    HStack(spacing: 20) {
                        StatItem(
                            title: "连续天数",
                            value: "\(user.streakDays)",
                            color: .red
                        )
                        
                        StatItem(
                            title: "最长连续",
                            value: "\(user.studyStats.longestStreak)天",
                            color: .yellow
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

// MARK: - 进度图表卡片
struct ProgressChartCard: View {
    let timeRange: TimeRange
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("学习进度")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let user = userService.currentUser {
                VStack(spacing: 15) {
                    // 模拟进度图表
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(0..<7) { index in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue)
                                    .frame(width: 30, height: CGFloat.random(in: 20...100))
                                
                                Text(["周一", "周二", "周三", "周四", "周五", "周六", "周日"][index])
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 120)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 学习目标
                    VStack(alignment: .leading, spacing: 8) {
                        Text("今日目标")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("学习单词")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("5 / \(user.learningGoals.dailyWords)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                        ProgressView()
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

// MARK: - 成就卡片
struct AchievementsCard: View {
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("成就展示")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("查看全部") {
                    // 跳转到成就页面
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if let user = userService.currentUser {
                if user.achievements.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "star")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                        
                        Text("还没有获得成就")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("继续学习来解锁成就吧！")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(user.achievements.prefix(6)) { achievement in
                            ProgressAchievementItem(achievement: achievement)
                        }
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

// MARK: - 成就项目
struct ProgressAchievementItem: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? Color.yellow : Color.gray, lineWidth: 1)
        )
    }
}

// MARK: - 学习建议卡片
struct LearningTipsCard: View {
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
            
            VStack(alignment: .leading, spacing: 12) {
                LearningTipItem(
                    icon: "clock.fill",
                    text: "每天固定时间学习，养成良好习惯",
                    color: .blue
                )
                
                LearningTipItem(
                    icon: "repeat",
                    text: "定期复习已学单词，巩固记忆",
                    color: .green
                )
                
                LearningTipItem(
                    icon: "target",
                    text: "设定合理的学习目标，循序渐进",
                    color: .orange
                )
                
                LearningTipItem(
                    icon: "heart.fill",
                    text: "保持积极心态，享受学习过程",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

// MARK: - 学习建议项目
struct LearningTipItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ProgressView()
        .environmentObject(UserService())
}
