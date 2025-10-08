import SwiftUI
import Combine

// MARK: - 数据模型
class StateManagementCounterViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var name: String = "计数器"
    
    func increment() {
        count += 1
    }
    
    func decrement() {
        count -= 1
    }
    
    func reset() {
        count = 0
    }
}

// MARK: - 主视图
struct StateManagementDemoView: View {
    // @State: 管理视图内部状态
    @State private var localCount: Int = 0
    @State private var isLocalMode: Bool = true
    
    // @StateObject: 创建并拥有对象
    @StateObject private var viewModel = StateManagementCounterViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🎯 状态管理三剑客")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("@State vs @ObservedObject vs @StateObject")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 模式切换
                    VStack(spacing: 15) {
                        Text("选择模式")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Picker("模式", selection: $isLocalMode) {
                            Text("@State 本地模式").tag(true)
                            Text("@StateObject 对象模式").tag(false)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // @State 演示
                    if isLocalMode {
                        VStack(spacing: 15) {
                            Text("@State - 本地状态管理")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("计数: \(localCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 20) {
                                Button("-") {
                                    localCount -= 1
                                }
                                .buttonStyle(.bordered)
                                
                                Button("重置") {
                                    localCount = 0
                                }
                                .buttonStyle(.bordered)
                                
                                Button("+") {
                                    localCount += 1
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            
                            Text("💡 @State特点:")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("• 管理视图内部状态")
                            Text("• 数据变化时自动更新UI")
                            Text("• 适合简单的本地状态")
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // @StateObject 演示
                    if !isLocalMode {
                        VStack(spacing: 15) {
                            Text("@StateObject - 对象状态管理")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            Text("计数: \(viewModel.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("名称: \(viewModel.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 20) {
                                Button("-") {
                                    viewModel.decrement()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("重置") {
                                    viewModel.reset()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("+") {
                                    viewModel.increment()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            
                            Text("💡 @StateObject特点:")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text("• 创建并拥有对象")
                            Text("• 管理对象生命周期")
                            Text("• 适合复杂的状态管理")
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // 传递给子视图
                    NavigationLink("进入子视图") {
                        StateManagementChildView(viewModel: viewModel)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // 对比说明
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📊 三剑客对比:")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("• @State: 简单本地状态")
                        Text("• @StateObject: 创建复杂对象")
                        Text("• @ObservedObject: 观察外部对象")
                        Text("• 选择合适的状态管理方式")
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("状态管理三剑客")
        }
    }
}

// MARK: - 子视图
struct StateManagementChildView: View {
    // @ObservedObject: 观察外部对象
    @ObservedObject var viewModel: StateManagementCounterViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("子视图 - @ObservedObject")
                .font(.title)
                .fontWeight(.bold)
            
            Text("观察父视图传递的对象")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                Text("计数: \(viewModel.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("名称: \(viewModel.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 20) {
                    Button("子视图 -") {
                        viewModel.decrement()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("子视图 +") {
                        viewModel.increment()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Text("💡 @ObservedObject特点:")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("• 观察外部对象")
                Text("• 不拥有对象生命周期")
                Text("• 适合接收外部数据")
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("子视图")
    }
}

#Preview {
    StateManagementDemoView()
}
