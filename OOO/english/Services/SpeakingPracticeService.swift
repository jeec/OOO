import Foundation
import Combine
import Combine

// MARK: - 口语练习服务
@MainActor
final class SpeakingPracticeService: ObservableObject {
    @Published private(set) var phrases: [SpeakingPhrase]
    @Published private(set) var practiceHistory: [SpeakingResult] = []
    @Published private(set) var featuredPhrase: SpeakingPhrase
    
    private let historyKey = "speakingPracticeHistory"
    private let userDefaults: UserDefaults
    
    init(phrases: [SpeakingPhrase] = SpeakingPhrase.samplePhrases,
         userDefaults: UserDefaults = .standard) {
        self.phrases = phrases
        self.userDefaults = userDefaults
        self.featuredPhrase = phrases.randomElement() ?? phrases.first!
        loadHistory()
    }
    
    func refreshFeaturedPhrase() {
        featuredPhrase = phrases.randomElement() ?? featuredPhrase
    }
    
    func phrases(for scenario: String) -> [SpeakingPhrase] {
        phrases.filter { $0.scenario == scenario }
    }
    
    func uniqueScenarios() -> [String] {
        Array(Set(phrases.map { $0.scenario })).sorted()
    }
    
    func recordPractice(for phrase: SpeakingPhrase, transcript: String) -> SpeakingResult {
        let evaluation = evaluate(transcript: transcript, expected: phrase.english)
        let result = SpeakingResult(
            phrase: phrase,
            transcript: transcript,
            accuracy: evaluation.accuracy,
            missingWords: evaluation.missingWords,
            extraWords: evaluation.extraWords,
            evaluationText: evaluation.feedback,
            wordMatches: evaluation.matches
        )
        practiceHistory.insert(result, at: 0)
        trimHistoryIfNeeded()
        saveHistory()
        return result
    }
    
    func removeHistory(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            guard practiceHistory.indices.contains(index) else { continue }
            practiceHistory.remove(at: index)
        }
        saveHistory()
    }
    
    private func evaluate(transcript: String, expected: String) -> (accuracy: Double, missingWords: [String], extraWords: [String], feedback: String, matches: [WordMatch]) {
        let expectedWords = sanitizedWords(from: expected)
        let spokenWords = sanitizedWords(from: transcript)
        guard !expectedWords.isEmpty else {
            return (0, [], spokenWords, "没有找到可以对比的目标句。", [])
        }
        guard !spokenWords.isEmpty else {
            return (0, expectedWords, [], "没有捕捉到语音，请大声一些再试一次。", [])
        }

        let expectedSet = Set(expectedWords)
        let spokenSet = Set(spokenWords)
        
        let matched = expectedSet.intersection(spokenSet)
        let missing = Array(expectedSet.subtracting(spokenSet)).sorted()
        let extra = Array(spokenSet.subtracting(expectedSet)).sorted()
        let matches = expectedWords.enumerated().map { index, word -> WordMatch in
            let isCorrect = spokenSet.contains(word)
            let spokenWord = spokenWords.first(where: { $0 == word })
            return WordMatch(index: index, expected: word, spoken: spokenWord, isCorrect: isCorrect)
        }
        
        let accuracy = Double(matched.count) / Double(expectedSet.count)
        let feedback: String
        
        switch accuracy {
        case 0.85...:
            feedback = "发音非常接近原句，保持这种流畅度！"
        case 0.6..<0.85:
            feedback = "整体不错，再强调一下关键词：\(missing.joined(separator: ", "))。"
        default:
            feedback = "我们再练一次，注意句子里的关键词和语调。"
        }
        
        return (accuracy, missing, extra, feedback, matches)
    }
    
    private func sanitizedWords(from string: String) -> [String] {
        guard !string.isEmpty else { return [] }
        let normalized = string
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "‘", with: "'")
        let pattern = "[A-Za-z']+"
        guard let expression = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        let nsString = normalized as NSString
        let range = NSRange(location: 0, length: nsString.length)
        return expression.matches(in: normalized, range: range).compactMap { match in
            Range(match.range, in: normalized).map { substring in
                normalized[substring].lowercased()
            }
        }
    }
    
    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey) else { return }
        if let results = try? JSONDecoder().decode([SpeakingResult].self, from: data) {
            practiceHistory = results
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(practiceHistory) {
            userDefaults.set(data, forKey: historyKey)
        }
    }
    
    private func trimHistoryIfNeeded() {
        let maxRecords = 50
        if practiceHistory.count > maxRecords {
            practiceHistory = Array(practiceHistory.prefix(maxRecords))
        }
    }
}
