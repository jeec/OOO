import SwiftUI
import Combine

// MARK: - 数据模型
class StateCounterViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var name: String = "计数器"
    
    func increment() {
        count += 1
    }
    
    func decrement() {
        count -= 1
    }
}

// MARK: - 主视图
struct StateObjectVsObservedObjectDemoView: View {
    // StateObject: 创建并拥有对象
    @StateObject private var viewModel = StateCounterViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🔄 StateObject vs ObservedObject")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("理解两种状态管理的区别")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // StateObject演示
                    VStack(spacing: 15) {
                        Text("@StateObject - 创建并拥有")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("计数: \(viewModel.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 20) {
                            Button("-") {
                                viewModel.decrement()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("+") {
                                viewModel.increment()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 传递给子视图
                    NavigationLink("进入子视图") {
                        StateChildView(viewModel: viewModel)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("状态管理对比")
        }
    }
}

// MARK: - 子视图
struct StateChildView: View {
    // ObservedObject: 观察已存在的对象
    @ObservedObject var viewModel: StateCounterViewModel
    
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
                    .font(.headline)
                
                HStack(spacing: 20) {
                    Button("重置") {
                        viewModel.count = 0
                    }
                    .buttonStyle(.bordered)
                    
                    Button("+10") {
                        viewModel.count += 10
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            
            Text("💡 子视图可以修改父视图的数据")
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding()
        .navigationTitle("子视图")
    }
}

#Preview {
    StateObjectVsObservedObjectDemoView()
}
