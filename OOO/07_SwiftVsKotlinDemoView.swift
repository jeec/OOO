import SwiftUI

// MARK: - Swift vs Kotlin 可选值处理对比
struct SwiftVsKotlinDemoView: View {
    @State private var name: String? = "张三"
    @State private var age: String? = "25"
    @State private var result: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🍎 Swift vs 🟢 Kotlin")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("可选值处理方式对比")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
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
                    Button("🍎 Swift方式 (Guard)") {
                        swiftStyle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("🟢 Kotlin方式 (模拟)") {
                        kotlinStyle()
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
                
                // 对比说明
                VStack(alignment: .leading, spacing: 10) {
                    Text("💡 为什么Swift不采用Kotlin的?操作符？")
                        .font(.headline)
                    
                    Text("1. 🛡️ 安全性：强制明确处理所有情况")
                    Text("2. 🎯 明确性：代码意图更清晰")
                    Text("3. 🔧 类型安全：避免意外的null传播")
                    Text("4. 📖 可读性：代码更容易理解和维护")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Swift vs Kotlin")
        }
    }
    
    // MARK: - Swift风格处理
    private func swiftStyle() {
        result = ""
        
        // Swift方式：明确处理每个可选值
        guard let name = name else {
            result = "❌ Swift: name为nil，必须处理"
            return
        }
        
        guard let ageString = age else {
            result = "❌ Swift: age为nil，必须处理"
            return
        }
        
        guard let ageInt = Int(ageString) else {
            result = "❌ Swift: age不是有效数字，必须处理"
            return
        }
        
        result = "✅ Swift: 明确处理成功！\n姓名: \(name)\n年龄: \(ageInt)\n姓名长度: \(name.count)"
    }
    
    // MARK: - Kotlin风格处理（模拟）
    private func kotlinStyle() {
        result = ""
        
        // 模拟Kotlin的?操作符行为
        let nameLength = name?.count  // 返回Optional<Int>
        let ageInt = age.flatMap { Int($0) }  // 返回Optional<Int>
        
        if let nameLength = nameLength, let ageInt = ageInt {
            result = "✅ Kotlin风格: 处理成功！\n姓名长度: \(nameLength)\n年龄: \(ageInt)"
        } else {
            result = "❌ Kotlin风格: 某些值为nil，返回null"
        }
    }
}

// MARK: - 详细对比分析
class SwiftVsKotlinComparison {
    
    // MARK: - Kotlin风格的问题
    func kotlinProblems() {
        // 模拟Kotlin代码
        let name: String? = nil
        let age: String? = "25"
        
        // Kotlin风格的问题：
        // 1. null传播可能不明显
        let nameLength = name?.count  // 返回nil
        let ageInt = age.flatMap { Int($0) }  // 返回Optional<Int>
        
        // 2. 链式调用可能隐藏问题
        let result = name?.uppercased().count  // 如果name为nil，整个表达式返回nil
        
        // 3. 类型不明确
        print("nameLength类型: \(type(of: nameLength))")  // Optional<Int>
        print("ageInt类型: \(type(of: ageInt))")  // Optional<Int>
    }
    
    // MARK: - Swift风格的优势
    func swiftAdvantages() {
        let name: String? = "张三"
        let age: String? = "25"
        
        // Swift风格的优势：
        // 1. 明确处理每个步骤
        guard let name = name else {
            print("name为nil，明确处理")
            return
        }
        
        guard let ageString = age else {
            print("age为nil，明确处理")
            return
        }
        
        guard let ageInt = Int(ageString) else {
            print("age不是有效数字，明确处理")
            return
        }
        
        // 2. 类型明确
        print("name类型: \(type(of: name))")  // String
        print("ageInt类型: \(type(of: ageInt))")  // Int
        
        // 3. 可以安全使用
        let result = name.uppercased().count + ageInt
        print("结果: \(result)")
    }
    
    // MARK: - 实际应用场景对比
    func realWorldComparison() {
        // 场景：处理用户数据
        
        // Kotlin风格（可能的问题）
        func kotlinStyle(user: [String: Any]?) {
            let name = user?["name"] as? String
            let age = user?["age"] as? Int
            
            // 问题：可能返回nil，调用者需要处理
            let result = name?.uppercased().count ?? 0 + (age ?? 0)
            print("Kotlin结果: \(result)")
        }
        
        // Swift风格（更安全）
        func swiftStyle(user: [String: Any]?) {
            guard let user = user else {
                print("用户数据为空")
                return
            }
            
            guard let name = user["name"] as? String else {
                print("姓名无效")
                return
            }
            
            guard let age = user["age"] as? Int else {
                print("年龄无效")
                return
            }
            
            // 安全使用
            let result = name.uppercased().count + age
            print("Swift结果: \(result)")
        }
    }
}

// MARK: - Swift的替代方案
class SwiftAlternatives {
    
    // MARK: - 使用可选链（类似Kotlin）
    func optionalChaining() {
        let name: String? = "张三"
        let age: String? = "25"
        
        // Swift也支持可选链，但结果仍然是可选值
        let nameLength = name?.count  // Optional<Int>
        let ageInt = age.flatMap { Int($0) }  // Optional<Int>
        
        // 仍然需要解包
        if let nameLength = nameLength, let ageInt = ageInt {
            print("姓名长度: \(nameLength), 年龄: \(ageInt)")
        }
    }
    
    // MARK: - 使用nil合并操作符
    func nilCoalescing() {
        let name: String? = nil
        let age: String? = "25"
        
        // 提供默认值
        let nameLength = name?.count ?? 0
        let ageInt = age.flatMap { Int($0) } ?? 0
        
        print("姓名长度: \(nameLength), 年龄: \(ageInt)")
    }
    
    // MARK: - 使用map和flatMap
    func functionalStyle() {
        let name: String? = "张三"
        let age: String? = "25"
        
        // 函数式风格
        let result = name.map { $0.count }
            .flatMap { nameLength in
                age.flatMap { Int($0) }.map { ageInt in
                    nameLength + ageInt
                }
            }
        
        if let result = result {
            print("结果: \(result)")
        }
    }
}

// MARK: - 预览
#Preview {
    SwiftVsKotlinDemoView()
}
