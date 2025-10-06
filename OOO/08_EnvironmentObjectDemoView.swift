import SwiftUI
import Combine

// MARK: - 用户数据模型
class UserData: ObservableObject {
    @Published var username: String = "张三"
    @Published var isLoggedIn: Bool = false
}

// MARK: - 主视图
struct EnvironmentObjectDemoView: View {
    @StateObject private var userData = UserData()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🌍 EnvironmentObject演示")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 显示当前状态
                VStack {
                    Text("用户名: \(userData.username)")
                    Text("登录状态: \(userData.isLoggedIn ? "已登录" : "未登录")")
                        .foregroundColor(userData.isLoggedIn ? .green : .red)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                NavigationLink("进入子视图") {
                    ChildView()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("EnvironmentObject")
        }
        .environmentObject(userData) // 注入环境对象
    }
}

// MARK: - 子视图
struct ChildView: View {
    @EnvironmentObject var userData: UserData // 自动获取环境对象
    
    var body: some View {
        VStack(spacing: 20) {
            Text("子视图")
                .font(.title)
            
            Text("用户名: \(userData.username)")
            Text("登录状态: \(userData.isLoggedIn ? "已登录" : "未登录")")
                .foregroundColor(userData.isLoggedIn ? .green : .red)
            
            VStack(spacing: 10) {
                Button("切换登录状态") {
                    userData.isLoggedIn.toggle()
                }
                .buttonStyle(.bordered)
                
                Button("修改用户名") {
                    userData.username = userData.username == "张三" ? "李四" : "张三"
                }
                .buttonStyle(.bordered)
            }
            
            NavigationLink("进入孙视图") {
                GrandChildView()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("子视图")
    }
}

// MARK: - 孙视图
struct GrandChildView: View {
    @EnvironmentObject var userData: UserData // 自动获取环境对象
    
    var body: some View {
        VStack(spacing: 20) {
            Text("孙视图")
                .font(.title)
            
            Text("用户名: \(userData.username)")
            Text("登录状态: \(userData.isLoggedIn ? "已登录" : "未登录")")
                .foregroundColor(userData.isLoggedIn ? .green : .red)
            
            Button("重置数据") {
                userData.username = "张三"
                userData.isLoggedIn = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("孙视图")
    }
}

// MARK: - 预览
#Preview {
    EnvironmentObjectDemoView()
}
