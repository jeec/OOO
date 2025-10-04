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
        VStack(spacing: 16) {
            CounterRow(count: $count, count2: $count2)
        }
        .padding()
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
