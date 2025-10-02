//
//  ContentView.swift
//  OOO
//
//  Created by Ji Yongchun on 2025/10/2.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world! 123").strikethrough()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
