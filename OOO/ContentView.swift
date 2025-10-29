import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var userService: UserService
    @EnvironmentObject private var speakingService: SpeakingPracticeService
    @EnvironmentObject private var wordService: WordService
    
    var body: some View {
        SpeakingPracticeHomeView()
            .environmentObject(userService)
            .environmentObject(speakingService)
            .environmentObject(wordService)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserService())
        .environmentObject(SpeakingPracticeService())
        .environmentObject(WordService())
}
