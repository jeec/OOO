import SwiftUI

// MARK: - 主视图
struct StateVsBindingDemoView: View {
    // @State: 管理视图内部状态
    @State private var count: Int = 0
    @State private var isOn: Bool = false
    @State private var text: String = "Hello"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🔄 @State vs @Binding")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("理解两种状态管理的区别")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // @State 演示
                    VStack(spacing: 15) {
                        Text("@State - 内部状态管理")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("计数: \(count)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 20) {
                            Button("-") {
                                count -= 1
                            }
                            .buttonStyle(.bordered)
                            
                            Button("+") {
                                count += 1
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        Toggle("开关状态", isOn: $isOn)
                        
                        TextField("输入文本", text: $text)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 传递给子视图
                    NavigationLink("进入子视图") {
                        BindingChildView(count: $count, isOn: $isOn, text: $text)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // 说明文字
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 关键区别:")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("• @State: 管理视图内部状态")
                        Text("• @Binding: 连接父子视图状态")
                        Text("• 子视图可以修改父视图数据")
                        Text("• 实现双向数据绑定")
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("@State vs @Binding")
        }
    }
}

// MARK: - 子视图
struct BindingChildView: View {
    // @Binding: 接收父视图传递的状态
    @Binding var count: Int
    @Binding var isOn: Bool
    @Binding var text: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("子视图 - @Binding")
                .font(.title)
                .fontWeight(.bold)
            
            Text("可以修改父视图的数据")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                Text("计数: \(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 20) {
                    Button("重置") {
                        count = 0
                    }
                    .buttonStyle(.bordered)
                    
                    Button("+10") {
                        count += 10
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Toggle("开关状态", isOn: $isOn)
                
                TextField("输入文本", text: $text)
                    .textFieldStyle(.roundedBorder)
                
                Button("清空文本") {
                    text = ""
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            
            Text("💡 子视图的修改会影响父视图")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding()
        .navigationTitle("子视图")
    }
}

#Preview {
    StateVsBindingDemoView()
}
