import SwiftUI

// MARK: - Guard语句演示
struct GuardDemoView: View {
    @State private var username: String = ""
    @State private var age: String = ""
    @State private var email: String = ""
    @State private var result: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🛡️ Guard语句演示")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("用户名", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("年龄", text: $age)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    TextField("邮箱", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                }
                .padding()
                
                Button("验证信息") {
                    validateUserInfo()
                }
                .buttonStyle(.borderedProminent)
                
                if !result.isEmpty {
                    Text(result)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // 演示不同的Guard用法
                VStack(alignment: .leading, spacing: 10) {
                    Text("Guard用法示例：")
                        .font(.headline)
                    
                    Text("1. 基本条件检查")
                    Text("2. 可选值解包")
                    Text("3. 类型转换")
                    Text("4. 数组/字典检查")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Guard演示")
            .alert("验证结果", isPresented: $showAlert) {
                Button("确定") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - 验证用户信息（使用Guard）
    private func validateUserInfo() {
        // 1. 基本条件检查
        guard !username.isEmpty else {
            showAlert(message: "用户名不能为空")
            return
        }
        
        guard username.count >= 3 else {
            showAlert(message: "用户名至少需要3个字符")
            return
        }
        
        // 2. 可选值解包
        guard let ageInt = Int(age) else {
            showAlert(message: "年龄必须是数字")
            return
        }
        
        guard ageInt >= 18 else {
            showAlert(message: "年龄必须大于等于18岁")
            return
        }
        
        // 3. 邮箱格式检查
        guard isValidEmail(email) else {
            showAlert(message: "邮箱格式不正确")
            return
        }
        
        // 所有验证通过
        result = "✅ 验证成功！\n用户名: \(username)\n年龄: \(ageInt)\n邮箱: \(email)"
    }
    
    // MARK: - 邮箱格式验证
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
        result = ""
    }
}

// MARK: - Guard高级用法演示
class GuardAdvancedDemo {
    
    // 1. 基本Guard用法
    func basicGuardExample(value: Int?) {
        guard let unwrappedValue = value else {
            print("值为nil，退出函数")
            return
        }
        print("解包成功，值为: \(unwrappedValue)")
    }
    
    // 2. 多个条件检查
    func multipleConditions(name: String?, age: Int?) {
        guard let name = name, !name.isEmpty else {
            print("姓名无效")
            return
        }
        
        guard let age = age, age > 0 else {
            print("年龄无效")
            return
        }
        
        print("姓名: \(name), 年龄: \(age)")
    }
    
    // 3. 类型转换
    func typeConversion(value: Any?) {
        guard let stringValue = value as? String else {
            print("无法转换为String类型")
            return
        }
        
        guard let intValue = Int(stringValue) else {
            print("字符串无法转换为整数")
            return
        }
        
        print("转换成功: \(intValue)")
    }
    
    // 4. 数组/字典检查
    func arrayDictionaryCheck(data: [String: Any]) {
        guard let name = data["name"] as? String, !name.isEmpty else {
            print("姓名字段无效")
            return
        }
        
        guard let age = data["age"] as? Int, age > 0 else {
            print("年龄字段无效")
            return
        }
        
        guard let hobbies = data["hobbies"] as? [String], !hobbies.isEmpty else {
            print("爱好列表无效")
            return
        }
        
        print("数据验证成功: \(name), \(age)岁, 爱好: \(hobbies)")
    }
    
    // 5. 网络请求示例
    func networkRequest(url: String?) {
        guard let urlString = url, !urlString.isEmpty else {
            print("URL无效")
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("无法创建URL对象")
            return
        }
        
        // 模拟网络请求
        print("开始请求: \(url)")
    }
}

// MARK: - Guard vs if-let 对比
class GuardVsIfLetDemo {
    
    // 使用if-let（嵌套较深）
    func ifLetExample(user: [String: Any]?) {
        if let user = user {
            if let name = user["name"] as? String {
                if let age = user["age"] as? Int {
                    if age >= 18 {
                        print("成年用户: \(name)")
                    } else {
                        print("未成年用户")
                    }
                } else {
                    print("年龄无效")
                }
            } else {
                print("姓名无效")
            }
        } else {
            print("用户数据为空")
        }
    }
    
    // 使用guard（更清晰）
    func guardExample(user: [String: Any]?) {
        guard let user = user else {
            print("用户数据为空")
            return
        }
        
        guard let name = user["name"] as? String, !name.isEmpty else {
            print("姓名无效")
            return
        }
        
        guard let age = user["age"] as? Int, age >= 18 else {
            print("年龄无效或未成年")
            return
        }
        
        print("成年用户: \(name)")
    }
}

// MARK: - 预览
#Preview {
    GuardDemoView()
}
