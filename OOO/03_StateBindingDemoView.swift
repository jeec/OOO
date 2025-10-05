//
//  03_StateBindingDemoView.swift
//  OOO
//
//  Created by Ji Yongchun on 2025/10/2.
//

import SwiftUI

// MARK: - 自定义开关组件（演示 @Binding）
struct CustomToggle: View {
    @Binding var isOn: Bool
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isOn.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isOn ? color : Color.gray.opacity(0.3))
                        .frame(width: 50, height: 30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 26, height: 26)
                        .offset(x: isOn ? 10 : -10)
                        .shadow(color: Color.red, radius: 10)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - 计数器组件（演示 @State 和 @Binding）
struct CounterComponent: View {
    @State private var count: Int = 0
    @State private var step: Int = 1
    @State private var isAutoIncrement: Bool = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            // 计数器显示
            VStack {
                Text("\(count)")
                    .font(.system(size: 58, weight: .bold, design: .monospaced))
                    .foregroundColor(countColor)
                
                Text("Step: \(step)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            
            // 控制按钮
            HStack(spacing: 16) {
                Button("−") {
                    withAnimation(.spring()) {
                        count -= step
                    }
                }
                .buttonStyle(.bordered)
                .font(.title2)
                .disabled(count <= 0)
                
                Button("Reset") {
                    withAnimation(.spring()) {
                        count = 0
                    }
                }
                .buttonStyle(.bordered)
                .font(.title2)
                
                Button("+") {
                    withAnimation(.spring()) {
                        count += step
                    }
                }
                .buttonStyle(.borderedProminent)
                .font(.title2)
            }
            
            // 步长控制
            VStack {
                Text("Step Size")
                    .font(.headline)
                
                HStack {
                    Button("1") { step = 1 }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(step == 1 ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(step == 1 ? .white : .primary)
                        .cornerRadius(8)
                    
                    Button("5") { step = 5 }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(step == 5 ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(step == 5 ? .white : .primary)
                        .cornerRadius(8)
                    
                    Button("10") { step = 10 }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(step == 10 ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(step == 10 ? .white : .primary)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .onChange(of: isAutoIncrement) { _, newValue in
            if newValue {
                startAutoIncrement()
            } else {
                stopAutoIncrement()
            }
        }
    }
    
    private var countColor: Color {
        if count < 0 {
            return .red
        } else if count == 0 {
            return .gray
        } else if count <= 10 {
            return .blue
        } else {
            return .green
        }
    }
    
    private func startAutoIncrement() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                count += step
            }
        }
    }
    
    private func stopAutoIncrement() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - 设置面板（演示 @State 和 @Binding 的传递）
struct SettingsPanel: View {
    @Binding var isAutoIncrement: Bool
    @Binding var showAdvancedSettings: Bool
    @State private var soundEnabled: Bool = true
    @State private var vibrationEnabled: Bool = true
    @State private var theme: String = "Light"
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            // 自动递增开关
            CustomToggle(
                isOn: $isAutoIncrement,
                title: "Auto Increment",
                color: .blue
            )
            
            // 声音开关
            CustomToggle(
                isOn: $soundEnabled,
                title: "Sound Effects",
                color: .green
            )
            
            // 震动开关
            CustomToggle(
                isOn: $vibrationEnabled,
                title: "Vibration",
                color: .orange
            )
            
            // 高级设置开关
            CustomToggle(
                isOn: $showAdvancedSettings,
                title: "Advanced Settings",
                color: .purple
            )
            
            // 主题选择
            if showAdvancedSettings {
                VStack {
                    Text("Theme")
                        .font(.headline)
                    
                    Picker("Theme", selection: $theme) {
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                        Text("Auto").tag("Auto")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

// MARK: - 主演示视图
struct StateBindingDemoView: View {
    @State private var isAutoIncrement: Bool = false
    @State private var showSettings: Bool = false
    @State private var showAdvancedSettings: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("@State & @Binding Demo")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 计数器组件
                CounterComponent()
                
                // 设置按钮
                Button("Settings") {
                    withAnimation(.spring()) {
                        showSettings.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                .font(.headline)
                
                // 设置面板
                if showSettings {
                    SettingsPanel(
                        isAutoIncrement: $isAutoIncrement,
                        showAdvancedSettings: $showAdvancedSettings
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
                
                // 状态信息
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current State:")
                        .font(.headline)
                    
                    HStack {
                        Text("Auto Increment:")
                        Spacer()
                        Text(isAutoIncrement ? "ON" : "OFF")
                            .foregroundColor(isAutoIncrement ? .green : .red)
                    }
                    
                    HStack {
                        Text("Settings Panel:")
                        Spacer()
                        Text(showSettings ? "Visible" : "Hidden")
                            .foregroundColor(showSettings ? .blue : .gray)
                    }
                    
                    HStack {
                        Text("Advanced Settings:")
                        Spacer()
                        Text(showAdvancedSettings ? "Enabled" : "Disabled")
                            .foregroundColor(showAdvancedSettings ? .purple : .gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("@State & @Binding")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    StateBindingDemoView()
}
