import SwiftUI

// MARK: - 可选值解包演示
struct OptionalDemoView: View {
    @State private var name: String? = "张三"
    @State private var age: String? = "25"
    @State private var result: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("📦 可选值解包演示")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("当前值：")
                        .font(.headline)
                    
                    Text("name: \(name?.description ?? "nil")")
                    Text("age: \(age?.description ?? "nil")")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                VStack(spacing: 10) {
                    Button("✅ 安全解包 (Guard)") {
                        safeUnwrap()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("❌ 强制解包 (危险)") {
                        forceUnwrap()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("🔄 设置为nil") {
                        name = nil
                        age = nil
                        result = "值已设置为nil"
                    }
                    .buttonStyle(.bordered)
                    
                    Button("🔄 恢复值") {
                        name = "李四"
                        age = "30"
                        result = "值已恢复"
                    }
                    .buttonStyle(.bordered)
                }
                
                if !result.isEmpty {
                    Text(result)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // 解释说明
                VStack(alignment: .leading, spacing: 10) {
                    Text("💡 为什么要先写 let name = name？")
                        .font(.headline)
                    
                    Text("1. 检查可选值是否为nil")
                    Text("2. 如果不为nil，解包为具体类型")
                    Text("3. 创建新的常量供后续使用")
                    Text("4. 避免强制解包导致的崩溃")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("可选值解包")
        }
    }
    
    // MARK: - 安全解包方法
    private func safeUnwrap() {
        result = ""
        
        // 使用Guard安全解包
        guard let name = name else {
            result = "❌ name为nil，无法解包"
            return
        }
        
        guard let ageString = age else {
            result = "❌ age为nil，无法解包"
            return
        }
        
        guard let ageInt = Int(ageString) else {
            result = "❌ age不是有效数字"
            return
        }
        
        result = "✅ 解包成功！\n姓名: \(name)\n年龄: \(ageInt)"
    }
    
    // MARK: - 强制解包方法（危险）
    private func forceUnwrap() {
        result = ""
        
        do {
            // 强制解包 - 如果为nil会崩溃
            let nameValue = name!  // 危险！
            let ageValue = age!    // 危险！
            let ageInt = Int(ageValue)!
            
            result = "✅ 强制解包成功！\n姓名: \(nameValue)\n年龄: \(ageInt)"
        } catch {
            result = "❌ 强制解包失败，程序可能崩溃"
        }
    }
}

// MARK: - 可选值解包详细解释
class OptionalExplanation {
    
    // 1. 基本解包
    func basicUnwrapping() {
        var name: String? = "张三"
        
        // 解包过程：
        // 1. 检查name是否为nil
        // 2. 如果不为nil，将其值赋给新常量name
        // 3. 新name的类型是String（非可选）
        guard let name = name else {
            print("name为nil")
            return
        }
        
        print("解包成功: \(name)")  // name现在是String类型
    }
    
    // 2. 解包过程分解
    func unwrappingProcess() {
        var name: String? = "张三"
        
        // 等价于以下步骤：
        if let unwrappedName = name {
            // unwrappedName是String类型
            print("解包成功: \(unwrappedName)")
        } else {
            print("name为nil")
        }
    }
    
    // 3. 类型转换
    func typeConversion() {
        var name: String? = "张三"
        
        // 解包前：name的类型是String?
        print("解包前类型: \(type(of: name))")  // Optional<String>
        
        guard let name = name else { return }
        
        // 解包后：name的类型是String
        print("解包后类型: \(type(of: name))")  // String
        print("解包后值: \(name)")
    }
    
    // 4. 多个条件检查
    func multipleConditions() {
        var name: String? = "张三"
        var age: String? = "25"
        
        // 同时解包多个可选值
        guard let name = name, !name.isEmpty else {
            print("姓名无效")
            return
        }
        
        guard let ageString = age, let ageInt = Int(ageString) else {
            print("年龄无效")
            return
        }
        
        print("用户: \(name), 年龄: \(ageInt)")
    }
    
    // 5. 解包的作用域
    func scopeExample() {
        var name: String? = "张三"
        
        // 解包后的name只在guard语句的else块之后有效
        guard let name = name else {
            print("name为nil")
            return
        }
        
        // 这里可以安全使用name（String类型）
        print("姓名: \(name)")
        print("姓名长度: \(name.count)")
        
        // 如果在这里再次使用原始的可选值
        // print(name?.count)  // 这里name仍然是String?类型
    }
}

// MARK: - 预览
#Preview {
    OptionalDemoView()
}
