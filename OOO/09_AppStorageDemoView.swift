import SwiftUI

// MARK: - AppStorage演示
struct AppStorageDemoView: View {
    // 基本类型存储
    @AppStorage("username") private var username: String = "用户"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("fontSize") private var fontSize: Double = 16.0
    @AppStorage("selectedTheme") private var selectedTheme: String = "蓝色"
    
    // 计数器（演示数据持久化）
    @AppStorage("clickCount") private var clickCount: Int = 0
    @AppStorage("lastLoginDate") private var lastLoginDate: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                Text("💾 AppStorage演示")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("数据会自动保存，重启应用后仍然存在")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 用户设置区域
                VStack(alignment: .leading, spacing: 15) {
                    Text("用户设置")
                        .font(.headline)
                    
                    HStack {
                        Text("用户名:")
                        TextField("输入用户名", text: $username)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("字体大小:")
                        Slider(value: $fontSize, in: 12...24, step: 1)
                        Text("\(Int(fontSize))")
                            .frame(width: 30)
                    }
                    
                    HStack {
                        Text("主题:")
                        Picker("主题", selection: $selectedTheme) {
                            Text("蓝色").tag("蓝色")
                            Text("绿色").tag("绿色")
                            Text("红色").tag("红色")
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Toggle("深色模式", isOn: $isDarkMode)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // 计数器演示
                VStack(spacing: 15) {
                    Text("计数器演示")
                        .font(.headline)
                    
                    Text("点击次数: \(clickCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Button("点击我") {
                        clickCount += 1
                        lastLoginDate = Date().formatted(date: .abbreviated, time: .shortened)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if !lastLoginDate.isEmpty {
                        Text("最后点击: \(lastLoginDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // 重置按钮
                Button("重置所有数据") {
                    username = "用户"
                    isDarkMode = false
                    fontSize = 16.0
                    selectedTheme = "蓝色"
                    clickCount = 0
                    lastLoginDate = ""
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                
                Spacer()
                
                // 说明文字
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 AppStorage特点:")
                        .font(.headline)
                    
                    Text("• 自动保存到UserDefaults")
                    Text("• 应用重启后数据不丢失")
                    Text("• 支持基本数据类型")
                    Text("• 代码简洁，使用方便")
                }
                .font(.caption)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("AppStorage")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

// MARK: - 预览
#Preview {
    AppStorageDemoView()
}
