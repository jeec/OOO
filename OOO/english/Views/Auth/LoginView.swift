import SwiftUI

// MARK: - 登录视图
struct LoginView: View {
    @EnvironmentObject private var userService: UserService
    @State private var email = "test@example.com"
    @State private var password = "123456"
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showRegister = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo 和标题
                    VStack(spacing: 20) {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("口语练习室")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("随时随地练就地道英语口语")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                    
                    // 登录表单
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("邮箱")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("请输入邮箱", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("密码")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("请输入密码", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // 登录按钮
                        Button(action: login) {
                            HStack {
                                if userService.isLoading {
                                    SwiftUI.ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("登录")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(userService.isLoading || email.isEmpty || password.isEmpty)
                        .opacity(userService.isLoading || email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                        
                        // 注册链接
                        HStack {
                            Text("还没有账号？")
                                .foregroundColor(.secondary)
                            
                            Button("立即注册") {
                                showRegister = true
                            }
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        }
                        
                        // 测试账号提示
                        VStack(spacing: 8) {
                            Text("测试账号")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("邮箱: test@example.com")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("密码: 123456")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .alert("登录失败", isPresented: $showAlert) {
            Button("确定") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
    
    private func login() {
        print("登录按钮被点击")
        print("邮箱: \(email)")
        print("密码: \(password)")
        print("加载状态: \(userService.isLoading)")
        
        Task {
            print("开始登录请求")
            let result = await userService.login(email: email, password: password)
            print("登录结果: \(result)")
            
            await MainActor.run {
                switch result {
                case .success:
                    print("登录成功")
                    // 登录成功，会自动跳转到主界面
                    break
                case .failure(let error):
                    print("登录失败: \(error.localizedDescription)")
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - 注册视图
struct RegisterView: View {
    @EnvironmentObject private var userService: UserService
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // 标题
                    VStack(spacing: 10) {
                        Text("创建账号")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("开始你的英语学习之旅")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                    
                    // 注册表单
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("用户名")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("请输入用户名", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("邮箱")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("请输入邮箱", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("密码")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("请输入密码", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("确认密码")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("请再次输入密码", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // 注册按钮
                        Button(action: register) {
                            HStack {
                                if userService.isLoading {
                        SwiftUI.ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                                } else {
                                    Text("注册")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(LinearGradient(
                                        colors: [Color.green, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(userService.isLoading || !isFormValid)
                        .opacity(userService.isLoading || !isFormValid ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationTitle("注册")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .alert("注册失败", isPresented: $showAlert) {
            Button("确定") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty && 
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func register() {
        Task {
            let result = await userService.register(username: username, email: email, password: password)
            
            await MainActor.run {
                switch result {
                case .success:
                    dismiss()
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
