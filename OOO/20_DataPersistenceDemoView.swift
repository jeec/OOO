import SwiftUI

// MARK: - 数据持久化演示
struct DataPersistenceDemoView: View {
    // MARK: - @AppStorage - 应用级数据存储
    @AppStorage("username") private var username: String = "用户"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("userAge") private var userAge: Int = 18
    @AppStorage("userScore") private var userScore: Double = 0.0
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    
    // MARK: - @SceneStorage - 场景级数据存储
    @SceneStorage("currentTab") private var currentTab: Int = 0
    @SceneStorage("scrollPosition") private var scrollPosition: Double = 0.0
    @SceneStorage("isExpanded") private var isExpanded: Bool = false
    @SceneStorage("selectedColor") private var selectedColor: String = "blue"
    
    // MARK: - 本地状态
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("💾 数据持久化演示")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("学习 @AppStorage 和 @SceneStorage 的使用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // MARK: - @AppStorage 演示
                    VStack(spacing: 15) {
                        Text("📱 @AppStorage - 应用级数据存储")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("用户名: \(username)")
                            Text("年龄: \(userAge)")
                            Text("分数: \(userScore, specifier: "%.3f")")
                            Text("首次启动: \(isFirstLaunch ? "是" : "否")")
                            Text("深色模式: \(isDarkMode ? "开启" : "关闭")")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        
                        VStack(spacing: 10) {
                            TextField("输入用户名", text: $username)
                                .textFieldStyle(.roundedBorder)
                            
                            HStack {
                                Text("年龄:")
                                Stepper(value: $userAge, in: 1...100) {
                                    Text("\(userAge)")
                                }
                                .background(.red.opacity(0.1))
                            }
                            
                            HStack {
                                Text("分数:")
                                Slider(value: $userScore, in: 0...100)
                                Text("\(userScore, specifier: "%.1f")")
                            }
                            
                            Toggle("深色模式", isOn: $isDarkMode)
                            
                            Toggle("首次启动", isOn: $isFirstLaunch)
                        }
                    }
                    
                    // MARK: - @SceneStorage 演示
                    VStack(spacing: 15) {
                        Text("🔄 @SceneStorage - 场景级数据存储")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("当前标签: \(currentTab)")
                            Text("滚动位置: \(scrollPosition, specifier: "%.2f")")
                            Text("是否展开: \(isExpanded ? "是" : "否")")
                            Text("选中颜色: \(selectedColor)")
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        
                        VStack(spacing: 10) {
                            Picker("选择标签", selection: $currentTab) {
                                Text("标签 0").tag(0)
                                Text("标签 1").tag(1)
                                Text("标签 2").tag(2)
                            }
                            .pickerStyle(.segmented)
                            
                            HStack {
                                Text("滚动位置:")
                                Slider(value: $scrollPosition, in: 0...100)
                                Text("\(scrollPosition, specifier: "%.1f")")
                            }
                            
                            Toggle("展开状态", isOn: $isExpanded)
                            
                            Picker("选择颜色", selection: $selectedColor) {
                                Text("蓝色").tag("blue")
                                Text("红色").tag("red")
                                Text("绿色").tag("green")
                                Text("黄色").tag("yellow")
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    
                    // MARK: - 数据操作演示
                    VStack(spacing: 15) {
                        Text("🔧 数据操作演示")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        VStack(spacing: 10) {
                            Button("重置所有数据") {
                                resetAllData()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("显示当前数据") {
                                showCurrentData()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("模拟应用重启") {
                                simulateAppRestart()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    // MARK: - 使用场景说明
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 使用场景:")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("• @AppStorage: 用户设置、偏好、登录状态等需要持久保存的数据")
                        Text("• @SceneStorage: 界面状态、临时数据、滚动位置等场景相关数据")
                        Text("• 两者都支持 String、Int、Bool、Double、URL、Data 等类型")
                        Text("• @AppStorage 数据在应用重启后保留，@SceneStorage 数据在场景重建时保留")
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("数据持久化")
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .alert("数据信息", isPresented: $showAlert) {
                Button("确定") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - 辅助方法
    private func resetAllData() {
        // 重置 @AppStorage 数据
        username = "用户"
        userAge = 18
        userScore = 0.0
        isFirstLaunch = true
        isDarkMode = false
        
        // 重置 @SceneStorage 数据
        currentTab = 0
        scrollPosition = 0.0
        isExpanded = false
        selectedColor = "blue"
        
        alertMessage = "所有数据已重置！"
        showAlert = true
    }
    
    private func showCurrentData() {
        let appStorageData = """
        @AppStorage 数据:
        用户名: \(username)
        年龄: \(userAge)
        分数: \(userScore)
        首次启动: \(isFirstLaunch)
        深色模式: \(isDarkMode)
        """
        
        let sceneStorageData = """
        
        @SceneStorage 数据:
        当前标签: \(currentTab)
        滚动位置: \(scrollPosition)
        是否展开: \(isExpanded)
        选中颜色: \(selectedColor)
        """
        
        alertMessage = appStorageData + sceneStorageData
        showAlert = true
    }
    
    private func simulateAppRestart() {
        // 模拟应用重启：@AppStorage 数据保留，@SceneStorage 数据可能丢失
        alertMessage = """
        模拟应用重启后：
        @AppStorage 数据会保留（用户名、年龄等）
        @SceneStorage 数据可能丢失（标签、滚动位置等）
        
        这是两者的主要区别！
        """
        showAlert = true
    }
}

#Preview {
    DataPersistenceDemoView()
}
