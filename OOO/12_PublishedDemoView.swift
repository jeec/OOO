import SwiftUI
import Combine

// MARK: - 数据模型
class UserProfile: ObservableObject {
    @Published var name: String = "张三"
    @Published var age: Int = 25
    @Published var isOnline: Bool = false
    @Published var score: Int = 0
    
    func updateProfile() {
        name = "李四"
        age = 30
        isOnline = true
    }
    
    func addScore() {
        score += 10
    }
}

// MARK: - 主视图
struct PublishedDemoView: View {
    @StateObject private var userProfile = UserProfile()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("📢 @Published演示")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("自动发布数据变化，实现响应式更新")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 用户信息显示
                    VStack(spacing: 15) {
                        Text("用户信息")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        HStack {
                            Text("姓名:")
                            Spacer()
                            Text(userProfile.name)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("年龄:")
                            Spacer()
                            Text("\(userProfile.age)")
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("在线状态:")
                            Spacer()
                            Text(userProfile.isOnline ? "在线" : "离线")
                                .foregroundColor(userProfile.isOnline ? .green : .red)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("积分:")
                            Spacer()
                            Text("\(userProfile.score)")
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 操作按钮
                    VStack(spacing: 15) {
                        Button("更新用户信息") {
                            userProfile.updateProfile()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("增加积分") {
                            userProfile.addScore()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("切换在线状态") {
                            userProfile.isOnline.toggle()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    // 说明文字
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 @Published特点:")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("• 数据变化时自动通知所有观察者")
                        Text("• 实现响应式UI更新")
                        Text("• 简化状态管理代码")
                        Text("• 支持多种数据类型")
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("@Published")
        }
    }
}

#Preview {
    PublishedDemoView()
}
