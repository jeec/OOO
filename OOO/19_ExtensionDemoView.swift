import SwiftUI

// MARK: - 基础类型定义
struct Person {
    let name: String
    let age: Int
    let email: String
    
    init(name: String, age: Int, email: String) {
        self.name = name
        self.age = age
        self.email = email
    }
}

enum WeatherType {
    case sunny, cloudy, rainy, snowy
}

// MARK: - 扩展演示
struct ExtensionDemoView: View {
    @State private var person = Person(name: "张三", age: 25, email: "zhangsan@example.com")
    @State private var weather: WeatherType = .sunny
    @State private var text: String = "Hello SwiftUI"
    @State private var number: Int = 42
    @State private var showDetails: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🔧 Extension演示")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("为现有类型添加新功能")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // MARK: - 结构体扩展演示
                    VStack(spacing: 15) {
                        Text("👤 人员信息扩展")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("姓名: \(person.name)")
                            Text("年龄: \(person.age)")
                            Text("邮箱: \(person.email)")
                            Text("描述: \(person.description)")
                            Text("是否成年: \(person.isAdult ? "是" : "否")")
                            Text("邮箱域名: \(person.emailDomain)")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        
                        Button("更新年龄") {
                            person = Person(name: person.name, age: person.age + 1, email: person.email)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    // MARK: - 枚举扩展演示
                    VStack(spacing: 15) {
                        Text("🌤️ 天气类型扩展")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        HStack {
                            Text("当前天气: \(weather.emoji)")
                                .font(.title)
                            
                            Picker("天气", selection: $weather) {
                                Text("☀️ 晴天").tag(WeatherType.sunny)
                                Text("☁️ 多云").tag(WeatherType.cloudy)
                                Text("🌧️ 雨天").tag(WeatherType.rainy)
                                Text("❄️ 雪天").tag(WeatherType.snowy)
                            }
                            .pickerStyle(.menu)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        
                        Text("建议: \(weather.suggestion)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // MARK: - 字符串扩展演示
                    VStack(spacing: 15) {
                        Text("📝 字符串扩展")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("原文本: \(text)")
                            Text("首字母大写: \(text.capitalizedFirst)")
                            Text("是否包含数字: \(text.containsNumbers ? "是" : "否")")
                            Text("单词数量: \(text.wordCount)")
                            Text("反转文本: \(text.reversed)")
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        
                        TextField("输入文本", text: $text)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // MARK: - 数字扩展演示
                    VStack(spacing: 15) {
                        Text("🔢 数字扩展")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("数字: \(number)")
                            Text("是否为偶数: \(number.isEven ? "是" : "否")")
                            Text("平方: \(number.squared)")
                            Text("阶乘: \(number.factorial)")
                            Text("是否为质数: \(number.isPrime ? "是" : "否")")
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                        
                        HStack {
                            Button("-") { number -= 1 }
                                .buttonStyle(.bordered)
                            Button("+") { number += 1 }
                                .buttonStyle(.bordered)
                            Button("随机") { number = Int.random(in: 1...20) }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    // MARK: - 协议扩展演示
                    VStack(spacing: 15) {
                        Text("📋 协议扩展")
                            .font(.headline)
                        .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("协议扩展为所有类型添加了通用功能:")
                            Text("• 类型名称: \(Person.self.typeName)")
                            Text("• 内存大小: \(Person.self.memorySize) 字节")
                            Text("• 是否为引用类型: \(Person.self.isReferenceType ? "是" : "否")")
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // MARK: - 扩展特点说明
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 Extension特点:")
                            .font(.headline)
                            .foregroundColor(.indigo)
                        
                        Text("• 为现有类型添加新功能")
                        Text("• 无需修改原始定义")
                        Text("• 支持计算属性和方法")
                        Text("• 可以遵循新协议")
                        Text("• 提高代码组织性")
                    }
                    .padding()
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(8)
                    
                    // MARK: - 详细信息
                    if showDetails {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("🔍 扩展详情:")
                                .font(.headline)
                                .foregroundColor(.teal)
                            
                            Text("• 结构体扩展: 添加计算属性和方法")
                            Text("• 枚举扩展: 添加关联值和功能")
                            Text("• 字符串扩展: 添加实用方法")
                            Text("• 数字扩展: 添加数学运算")
                            Text("• 协议扩展: 为所有类型添加通用功能")
                        }
                        .padding()
                        .background(Color.teal.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(showDetails ? "隐藏详情" : "显示详情") {
                        showDetails.toggle()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Extension演示")
        }
    }
}

// MARK: - 结构体扩展
extension Person {
    var description: String {
        return "\(name)，\(age)岁，邮箱：\(email)"
    }
    
    var isAdult: Bool {
        return age >= 18
    }
    
    var emailDomain: String {
        return String(email.split(separator: "@").last ?? "")
    }
}

// MARK: - 枚举扩展
extension WeatherType {
    var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .snowy: return "❄️"
        }
    }
    
    var suggestion: String {
        switch self {
        case .sunny: return "适合户外活动，记得防晒！"
        case .cloudy: return "天气不错，适合散步。"
        case .rainy: return "记得带伞，注意安全。"
        case .snowy: return "天气寒冷，注意保暖。"
        }
    }
}

// MARK: - 字符串扩展
extension String {
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
    
    var containsNumbers: Bool {
        return rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    var wordCount: Int {
        return components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    var reversed: String {
        return String(self.reversed())
    }
}

// MARK: - 整数扩展
extension Int {
    var isEven: Bool {
        return self % 2 == 0
    }
    
    var squared: Int {
        return self * self
    }
    
    var factorial: Int {
        guard self >= 0 else { return 0 }
        guard self > 1 else { return 1 }
        guard self <= 20 else { return 0 } // 防止溢出，20! 已经很大了
        
        var result = 1
        for i in 1...self {
            result *= i
        }
        return result
    }
    
    var isPrime: Bool {
        guard self > 1 else { return false }
        guard self > 2 else { return true }
        guard self % 2 != 0 else { return false }
        
        for i in stride(from: 3, through: Int(sqrt(Double(self))), by: 2) {
            if self % i == 0 {
                return false
            }
        }
        return true
    }
}

// MARK: - 协议扩展
protocol TypeInfo {
    static var typeName: String { get }
    static var memorySize: Int { get }
    static var isReferenceType: Bool { get }
}

extension TypeInfo {
    static var typeName: String {
        return String(describing: Self.self)
    }
    
    static var memorySize: Int {
        return MemoryLayout<Self>.size
    }
    
    static var isReferenceType: Bool {
        return Self.self is AnyClass
    }
}

// 让所有类型遵循协议
extension Person: TypeInfo {}
extension String: TypeInfo {}
extension Int: TypeInfo {}

#Preview {
    ExtensionDemoView()
}

