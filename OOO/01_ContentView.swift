//
//  01_ContentView.swift
//  OOO
//
//  Created by Ji Yongchun on 2025/10/2.
//

import SwiftUI

struct ContentView: View {
    @State private var count = 0
    @State private var count2 = 1

    var body: some View {
        NavigationView {
            List {
                NavigationLink("🔄 ObservableObject演示") {
                    ObservableObjectDemoView()
                }
                
                NavigationLink("🔗 State & Binding演示") {
                    StateBindingDemoView()
                }
                
                NavigationLink("🐾 小动物重力游戏") {
                    GravityFragmentsGame()
                }
                
                NavigationLink("🛡️ Guard语句演示") {
                    GuardDemoView()
                }
                
                NavigationLink("📦 可选值解包演示") {
                    OptionalDemoView()
                }
                
                NavigationLink("🍎 Swift vs 🟢 Kotlin") {
                    SwiftVsKotlinDemoView()
                }
                
                NavigationLink("🌍 EnvironmentObject演示") {
                    EnvironmentObjectDemoView()
                }
                
                NavigationLink("💾 AppStorage演示") {
                    AppStorageDemoView()
                }
                
                NavigationLink("🎯 FocusState演示") {
                    FocusStateDemoView()
                }
                
                NavigationLink("🔄 StateObject vs ObservedObject") {
                    StateObjectVsObservedObjectDemoView()
                }
                
                NavigationLink("📢 @Published演示") {
                    PublishedDemoView()
                }
                
                NavigationLink("🔄 @State vs @Binding") {
                    StateVsBindingDemoView()
                }
                
                NavigationLink("🌍 @Environment演示") {
                    EnvironmentDemoView()
                }
                
                NavigationLink("🎯 状态管理三剑客") {
                    StateManagementDemoView()
                }
                
                NavigationLink("🌍 @EnvironmentObject高级演示") {
                    EnvironmentObjectAdvancedDemoView()
                }
                
                NavigationLink("👆 @GestureState演示") {
                    GestureStateDemoView()
                }
                
                NavigationLink("📋 Protocol演示") {
                    ProtocolDemoView()
                }
                
                NavigationLink("🔧 Extension演示") {
                    ExtensionDemoView()
                }
            }
            .navigationTitle("SwiftUI学习")
        }
    }
}

struct CounterRow: View {
    @Binding var count: Int
    @Binding var count2: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("Count: \(count)")
                .font(.largeTitle)

            Button("Increment") {
                count += 1
            }
            .buttonStyle(.glassProminent)

            Text("Count2: \(count2)")
                .font(.title2)

            Button("Decrease") {
                if count2 > 0 {
                    count2 -= 1
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(count2 <= 0)
        }
    }
}

#Preview {
    ContentView()
}
