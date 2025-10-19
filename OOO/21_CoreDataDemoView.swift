import SwiftUI
import Combine

// MARK: - 简化的数据模型（不使用 Core Data）
struct UserInfo: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var age: Int
    var createdAt: Date
    var isActive: Bool
    
    init(name: String, email: String, age: Int, isActive: Bool = true) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.age = age
        self.createdAt = Date()
        self.isActive = isActive
    }
}

// MARK: - 数据管理器
class DataManager: ObservableObject {
    @Published var users: [UserInfo] = []
    
    init() {
        // 添加一些示例数据
        addSampleData()
    }
    
    func addUser(_ user: UserInfo) {
        users.append(user)
    }
    
    func deleteUser(at indexSet: IndexSet) {
        users.remove(atOffsets: indexSet)
    }
    
    func deleteUser(_ user: UserInfo) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users.remove(at: index)
        }
    }
    
    private func addSampleData() {
        users = [
            UserInfo(name: "张三", email: "zhangsan@example.com", age: 25, isActive: true),
            UserInfo(name: "李四", email: "lisi@example.com", age: 30, isActive: false),
            UserInfo(name: "王五", email: "wangwu@example.com", age: 22, isActive: true),
            UserInfo(name: "赵六", email: "zhaoliu@example.com", age: 35, isActive: true),
            UserInfo(name: "钱七", email: "qianqi@example.com", age: 28, isActive: false)
        ]
    }
}

// MARK: - 数据管理演示视图
struct CoreDataDemoView: View {
    // MARK: - 数据管理
    @StateObject private var dataManager = DataManager()
    
    // MARK: - 本地状态
    @State private var showAddUser = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var searchText = ""
    @State private var selectedFilter: FilterType = .all
    
    enum FilterType: String, CaseIterable {
        case all = "全部"
        case active = "活跃用户"
        case adult = "成年用户"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - 搜索和过滤
                VStack(spacing: 12) {
                    Text("🔍 数据管理演示")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("学习数据管理和状态管理的使用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("搜索用户", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                        
                        Picker("过滤", selection: $selectedFilter) {
                            ForEach(FilterType.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                
                // MARK: - 数据统计
                HStack(spacing: 20) {
                    VStack {
                        Text("\(dataManager.users.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("总用户")
                            .font(.caption)
                    }
                    
                    VStack {
                        Text("\(activeUsersCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("活跃用户")
                            .font(.caption)
                    }
                    
                    VStack {
                        Text("\(adultUsersCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text("成年用户")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                
                // MARK: - 用户列表
                List {
                    ForEach(filteredUsers, id: \.id) { user in
                        UserRowView(user: user)
                    }
                    .onDelete(perform: deleteUsers)
                }
                .listStyle(.plain)
            }
            .navigationTitle("数据管理演示")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加用户") {
                        showAddUser = true
                    }
                }
            }
            .sheet(isPresented: $showAddUser) {
                AddUserView()
            }
            .alert("提示", isPresented: $showAlert) {
                Button("确定") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - 计算属性
    private var filteredUsers: [UserInfo] {
        let baseUsers: [UserInfo]
        
        switch selectedFilter {
        case .all:
            baseUsers = dataManager.users
        case .active:
            baseUsers = dataManager.users.filter { $0.isActive }
        case .adult:
            baseUsers = dataManager.users.filter { $0.age >= 18 }
        }
        
        if searchText.isEmpty {
            return baseUsers
        } else {
            return baseUsers.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var activeUsersCount: Int {
        dataManager.users.filter { $0.isActive }.count
    }
    
    private var adultUsersCount: Int {
        dataManager.users.filter { $0.age >= 18 }.count
    }
    
    // MARK: - 方法
    private func deleteUsers(offsets: IndexSet) {
        let usersToDelete = offsets.map { filteredUsers[$0] }
        
        for user in usersToDelete {
            dataManager.deleteUser(user)
        }
        
        alertMessage = "删除了 \(usersToDelete.count) 个用户"
        showAlert = true
    }
}

// MARK: - 用户行视图
struct UserRowView: View {
    let user: UserInfo
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(user.age) 岁")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Circle()
                            .fill(user.isActive ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(user.isActive ? "活跃" : "非活跃")
                            .font(.caption)
                            .foregroundColor(user.isActive ? .green : .red)
                    }
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text("创建时间: \(user.createdAt, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("ID: \(user.id.uuidString.prefix(8))...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - 添加用户视图
struct AddUserView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var age = 18
    @State private var isActive = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("用户信息") {
                    TextField("姓名", text: $name)
                    TextField("邮箱", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    Stepper("年龄: \(age)", value: $age, in: 1...100)
                    
                    Toggle("活跃状态", isOn: $isActive)
                }
                
                Section("预览") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("姓名: \(name.isEmpty ? "未填写" : name)")
                        Text("邮箱: \(email.isEmpty ? "未填写" : email)")
                        Text("年龄: \(age)")
                        Text("状态: \(isActive ? "活跃" : "非活跃")")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("添加用户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveUser()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
        }
    }
    
    private func saveUser() {
        let newUser = UserInfo(name: name, email: email, age: age, isActive: isActive)
        // 这里需要通过环境对象或绑定来添加用户
        dismiss()
    }
}

// MARK: - 使用场景说明
struct DataManagementUsageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("💡 数据管理使用场景:")
                .font(.headline)
                .foregroundColor(.purple)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• @StateObject: 管理数据模型的生命周期")
                Text("• @Published: 自动监听数据变化，实时更新 UI")
                Text("• 支持排序、过滤、搜索等高级功能")
                Text("• 适合存储用户数据、设置、历史记录等")
                Text("• 提供数据验证、状态管理等功能")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    CoreDataDemoView()
}
