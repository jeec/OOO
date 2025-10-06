import SwiftUI

// MARK: - 焦点状态演示
struct FocusStateDemoView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    // 焦点状态管理
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, email, password
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🎯 FocusState演示")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("管理输入框焦点，提升用户体验")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 15) {
                        TextField("用户名", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .username)
                        
                        TextField("邮箱", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .email)
                            .keyboardType(.emailAddress)
                        
                        SecureField("密码", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .password)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    VStack(spacing: 10) {
                        Button("聚焦用户名") {
                            focusedField = .username
                        }
                        .buttonStyle(.bordered)
                        
                        Button("聚焦邮箱") {
                            focusedField = .email
                        }
                        .buttonStyle(.bordered)
                        
                        Button("聚焦密码") {
                            focusedField = .password
                        }
                        .buttonStyle(.bordered)
                        
                        Button("取消焦点") {
                            focusedField = nil
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("FocusState")
        }
    }
}

#Preview {
    FocusStateDemoView()
}
