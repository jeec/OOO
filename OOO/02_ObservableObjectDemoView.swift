//
//  02_ObservableObjectDemoView.swift
//  OOO
//
//  Created by Ji Yongchun on 2025/10/2.
//

import SwiftUI
import Combine

// MARK: - ObservableObject 数据模型
class CounterViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var isRunning: Bool = false
    @Published var message: String = "Ready to start"
    
    // 计算属性
    var isEven: Bool {
        count % 2 == 0
    }
    
    var countDescription: String {
        switch count {
        case 0:
            return "Zero"
        case 1...10:
            return "Small number"
        case 11...100:
            return "Medium number"
        default:
            return "Large number"
        }
    }
    
    // 方法
    func increment() {
        count += 1
    }
    
    func decrement() {
        if count > 0 {
            count -= 1
        }
    }
    
    func reset() {
        count = 0
        message = "Reset to zero"
    }
    
    func startAutoIncrement() {
        isRunning = true
        message = "Auto incrementing..."
    }
    
    func stopAutoIncrement() {
        isRunning = false
        message = "Stopped"
    }
}

// MARK: - 主演示视图
struct ObservableObjectDemoView: View {
    @StateObject private var viewModel = CounterViewModel()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("ObservableObject Demo")
                    .font(.title)
                    .fontWeight(.bold)
                
                // 计数器显示
                CounterDisplaySection(viewModel: viewModel)
                
                // 控制按钮
                ControlButtonsSection(viewModel: viewModel)
                
                // 状态信息
                StatusInfoSection(viewModel: viewModel)
                
                // 自动递增演示
                AutoIncrementSection(viewModel: viewModel)
                
                Spacer()
            }
            .padding()
            .navigationTitle("ObservableObject")
            .alert("Notification", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: viewModel.count) { oldValue, newValue in
                // 演示 onChange 副作用
                if newValue > 0 && newValue % 5 == 0 {
                    alertMessage = "Count reached \(newValue)! 🎉"
                    showingAlert = true
                }
            }
            .task {
                // 演示 task 异步操作
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                viewModel.message = "ViewModel initialized"
            }
        }
    }
}

// MARK: - 计数器显示子视图
struct CounterDisplaySection: View {
    @ObservedObject var viewModel: CounterViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // 主要计数显示
            Text("\(viewModel.count)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(viewModel.isEven ? .blue : .red)
            
            // 计数描述
            Text(viewModel.countDescription)
                .font(.title2)
                .foregroundColor(.secondary)
            
            // 奇偶性指示
            HStack {
                Image(systemName: viewModel.isEven ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(viewModel.isEven ? .green : .orange)
                Text(viewModel.isEven ? "Even" : "Odd")
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - 控制按钮子视图
struct ControlButtonsSection: View {
    @ObservedObject var viewModel: CounterViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Button("−") {
                    viewModel.decrement()
                }
                .buttonStyle(.bordered)
                .font(.title2)
                .disabled(viewModel.count <= 0)
                
                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
                .font(.title2)
                
                Button("+") {
                    viewModel.increment()
                }
                .buttonStyle(.borderedProminent)
                .font(.title2)
            }
        }
    }
}

// MARK: - 状态信息子视图
struct StatusInfoSection: View {
    @ObservedObject var viewModel: CounterViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Status Information")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Count: \(viewModel.count)")
                    Text("Running: \(viewModel.isRunning ? "Yes" : "No")")
                    Text("Message: \(viewModel.message)")
                }
                .font(.subheadline)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - 自动递增演示子视图
struct AutoIncrementSection: View {
    @ObservedObject var viewModel: CounterViewModel
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Auto Increment Demo")
                .font(.headline)
            
            Button(viewModel.isRunning ? "Stop Auto" : "Start Auto") {
                if viewModel.isRunning {
                    viewModel.stopAutoIncrement()
                    timer?.invalidate()
                    timer = nil
                } else {
                    viewModel.startAutoIncrement()
                    startTimer()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.count >= 50) // 防止无限增长
            
            if viewModel.isRunning {
                Text("Auto incrementing every 1 second...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            viewModel.increment()
        }
    }
}

#Preview {
    ObservableObjectDemoView()
}
