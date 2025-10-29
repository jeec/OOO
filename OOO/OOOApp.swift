//
//  OOOApp.swift
//  OOO
//
//  Created by Ji Yongchun on 2025/10/2.
//

import SwiftUI

@main
struct OOOApp: App {
    @StateObject private var userService = UserService()
    @StateObject private var speakingService = SpeakingPracticeService()
    @StateObject private var wordService = WordService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userService)
                .environmentObject(speakingService)
                .environmentObject(wordService)
        }
    }
}
