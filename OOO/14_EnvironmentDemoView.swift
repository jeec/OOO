import SwiftUI

// MARK: - 主视图
struct EnvironmentDemoView: View {
    // @Environment: 访问系统环境值
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.locale) private var locale
    @Environment(\.calendar) private var calendar
    @Environment(\.timeZone) private var timeZone
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🌍 @Environment演示")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("访问系统环境值和设置")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 颜色方案
                    VStack(spacing: 15) {
                        Text("颜色方案")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        HStack {
                            Text("当前模式:")
                            Spacer()
                            Text(colorScheme == .dark ? "深色模式" : "浅色模式")
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        
                        Rectangle()
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .frame(height: 50)
                            .overlay(
                                Text("背景色预览")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            )
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 设备尺寸类别
                    VStack(spacing: 15) {
                        Text("设备尺寸类别")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        HStack {
                            Text("水平尺寸:")
                            Spacer()
                            Text(horizontalSizeClass == .compact ? "紧凑" : "常规")
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("垂直尺寸:")
                            Spacer()
                            Text(verticalSizeClass == .compact ? "紧凑" : "常规")
                                .fontWeight(.bold)
                        }
                        
                        Text("设备类型: \(getDeviceType())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 无障碍设置
                    VStack(spacing: 15) {
                        Text("无障碍设置")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        HStack {
                            Text("减少动画:")
                            Spacer()
                            Text(reduceMotion ? "开启" : "关闭")
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("区分颜色:")
                            Spacer()
                            Text(differentiateWithoutColor ? "开启" : "关闭")
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 本地化信息
                    VStack(spacing: 15) {
                        Text("本地化信息")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        HStack {
                            Text("语言:")
                            Spacer()
                            Text(locale.identifier)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("日历:")
                            Spacer()
                            Text(String(describing: calendar.identifier).capitalized)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("时区:")
                            Spacer()
                            Text(timeZone.identifier)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 说明文字
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 @Environment特点:")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text("• 自动获取系统环境值")
                        Text("• 响应系统设置变化")
                        Text("• 支持无障碍功能")
                        Text("• 提供本地化信息")
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("@Environment")
        }
    }
    
    // 辅助方法：判断设备类型
    private func getDeviceType() -> String {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular):
            return "iPhone (竖屏)"
        case (.regular, .compact):
            return "iPhone (横屏)"
        case (.regular, .regular):
            return "iPad"
        default:
            return "未知设备"
        }
    }
}

#Preview {
    EnvironmentDemoView()
}
