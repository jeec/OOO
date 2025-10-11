import SwiftUI
import Combine

// MARK: - 用户数据模型
class AdvancedUserProfile: ObservableObject {
    @Published var username: String = "游客"
    @Published var isLoggedIn: Bool = false
    @Published var userLevel: Int = 1
    @Published var score: Int = 0
    
    func login(username: String) {
        self.username = username
        self.isLoggedIn = true
        self.userLevel = 1
        self.score = 0
    }
    
    func logout() {
        self.username = "游客"
        self.isLoggedIn = false
        self.userLevel = 1
        self.score = 0
    }
    
    func addScore(_ points: Int) {
        score += points
        if score >= 100 {
            userLevel += 1
            score = 0
        }
    }
}

// MARK: - 主视图
struct EnvironmentObjectAdvancedDemoView: View {
    @StateObject private var userProfile = AdvancedUserProfile()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🌍 @EnvironmentObject高级演示")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("在视图层次结构中共享数据")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 用户信息显示
                    VStack(spacing: 15) {
                        Text("用户信息")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        HStack {
                            Text("用户名:")
                            Spacer()
                            Text(userProfile.username)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("登录状态:")
                            Spacer()
                            Text(userProfile.isLoggedIn ? "已登录" : "未登录")
                                .fontWeight(.bold)
                                .foregroundColor(userProfile.isLoggedIn ? .green : .red)
                        }
                        
                        HStack {
                            Text("用户等级:")
                            Spacer()
                            Text("Lv.\(userProfile.userLevel)")
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Text("积分:")
                            Spacer()
                            Text("\(userProfile.score)")
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 登录/登出按钮
                    VStack(spacing: 15) {
                        Text("用户操作")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        if userProfile.isLoggedIn {
                            Button("登出") {
                                userProfile.logout()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        } else {
                            Button("登录") {
                                userProfile.login(username: "用户\(Int.random(in: 1000...9999))")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 导航到子视图
                    NavigationLink("进入游戏界面") {
                        GameView()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // 说明文字
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 @EnvironmentObject特点:")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("• 自动注入到视图层次结构")
                        Text("• 无需手动传递数据")
                        Text("• 支持深层嵌套访问")
                        Text("• 数据变化时自动更新UI")
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("@EnvironmentObject")
        }
        .environmentObject(userProfile) // 注入环境对象
    }
}

// MARK: - 游戏界面
struct GameView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎮 游戏界面")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("这里可以访问用户数据，无需传递参数")
                .font(.caption)
                .foregroundColor(.secondary)
            
            NavigationLink("进入游戏设置") {
                GameSettingsView()
            }
            .buttonStyle(.borderedProminent)
            
            NavigationLink("进入游戏商店") {
                GameStoreView()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("游戏界面")
    }
}

// MARK: - 游戏设置
struct GameSettingsView: View {
    @EnvironmentObject var userProfile: AdvancedUserProfile
    
    var body: some View {
        VStack(spacing: 20) {
            Text("⚙️ 游戏设置")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                Text("当前用户: \(userProfile.username)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("等级: Lv.\(userProfile.userLevel)")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                Text("积分: \(userProfile.score)")
                    .font(.title3)
                    .foregroundColor(.purple)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            Button("获得积分") {
                userProfile.addScore(10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
            Text("💡 这里直接访问了环境对象，无需传递参数！")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("游戏设置")
    }
}

// MARK: - 游戏商店
struct GameStoreView: View {
    @EnvironmentObject var userProfile: AdvancedUserProfile
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🛒 游戏商店")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                Text("欢迎, \(userProfile.username)!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("你的等级: Lv.\(userProfile.userLevel)")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                Text("可用积分: \(userProfile.score)")
                    .font(.title3)
                    .foregroundColor(.purple)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            
            Button("购买道具 (消耗50积分)") {
                if userProfile.score >= 50 {
                    userProfile.addScore(-50)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(userProfile.score < 50)
            
            Text("💡 环境对象在深层嵌套中依然有效！")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("游戏商店")
    }
}

#Preview {
    EnvironmentObjectAdvancedDemoView()
}
