import SwiftUI

// MARK: - 口语练习主页
struct SpeakingPracticeHomeView: View {
    @EnvironmentObject private var speakingService: SpeakingPracticeService
    @EnvironmentObject private var userService: UserService
    @State private var selectedPhrase: SpeakingPhrase?
    @State private var showHistory = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    progressOverviewSection
                    featuredSection
                    scenarioSection
                    historySection
                }
                .padding()
            }
            .navigationTitle("口语练习室")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showHistory = true
                    } label: {
                        Label("历史记录", systemImage: "clock.arrow.circlepath")
                    }
                }
            }
            .navigationDestination(item: $selectedPhrase) { phrase in
                SpeakingPracticeSessionView(phrase: phrase)
            }
            .sheet(isPresented: $showHistory) {
                SpeakingHistoryView()
            }
            .onAppear {
                speakingService.refreshFeaturedPhrase()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hi, \(userService.currentUser?.username ?? "Learner")")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("每天 10 分钟，让口语更自然。")
                .font(.headline)
                .foregroundStyle(.secondary)
            if let xp = userService.currentUser?.totalXP {
                Text("累计 XP：\(xp)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var progressOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学习概览")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let summary = PracticeSummary(history: speakingService.practiceHistory, user: userService.currentUser) {
                SummaryMetricsGrid(summary: summary)
                if let xp = userService.currentUser?.totalXP {
                    Text("累计获得 \(xp) XP，继续坚持打卡吧！")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("完成第一句练习后，你的口语进步会显示在这里。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日练习")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("换一句") {
                    withAnimation(.easeInOut) {
                        speakingService.refreshFeaturedPhrase()
                    }
                }
                .buttonStyle(.bordered)
            }
            
            let phrase = speakingService.featuredPhrase
            SpeakingPhraseCard(phrase: phrase, highlight: true) {
                selectedPhrase = phrase
            }
        }
    }
    
    private var scenarioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("练习场景")
                .font(.title2)
                .fontWeight(.semibold)
            
            ForEach(speakingService.uniqueScenarios(), id: \.self) { scenario in
                VStack(alignment: .leading, spacing: 8) {
                    Text(scenario)
                        .font(.headline)
                    ForEach(speakingService.phrases(for: scenario)) { phrase in
                        SpeakingPhraseCard(phrase: phrase) {
                            selectedPhrase = phrase
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
            }
        }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最近练习")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let latest = speakingService.practiceHistory.first {
                SpeakingResultRow(result: latest)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
            } else {
                Text("还没有练习记录，立即开始第一句吧！")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - 练习卡片
struct SpeakingPhraseCard: View {
    let phrase: SpeakingPhrase
    var highlight: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(phrase.english)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: highlight ? "sparkles" : "mic.fill")
                        .foregroundStyle(highlight ? .orange : .blue)
                }
                
                Text(phrase.chinese)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                TagView(text: phrase.scenario, systemImage: "mappin.and.ellipse")
                TagView(text: phrase.focus, systemImage: "waveform")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(highlight ? Color.orange.opacity(0.1) : Color(.secondarySystemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 练习会话
struct SpeakingPracticeSessionView: View {
    @EnvironmentObject private var speakingService: SpeakingPracticeService
    @EnvironmentObject private var userService: UserService
    @EnvironmentObject private var wordService: WordService
    @Environment(\.dismiss) private var dismiss
    let phrase: SpeakingPhrase
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var pronunciationPlayer = PronunciationPlayer()
    @State private var latestResult: SpeakingResult?
    @State private var showTips = false
    @State private var isEvaluating = false
    @State private var selectedWordTranslation: WordTranslation?
    @State private var selectedPhraseWordIndex: Int?
    @State private var selectedTranscriptWordIndex: Int?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                phraseSection
                controlSection
                transcriptSection
                if let result = latestResult {
                    resultSection(result: result)
                }
                tipsSection
            }
            .padding()
        }
        .navigationTitle("开口练习")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("完成") {
                    pronunciationPlayer.stop()
                    dismiss()
                }
            }
        }
        .task {
            await speechRecognizer.requestPermissionsIfNeeded()
        }
        .onAppear {
            selectedWordTranslation = nil
            selectedPhraseWordIndex = nil
            selectedTranscriptWordIndex = nil
        }
        .onDisappear {
            pronunciationPlayer.stop()
            selectedWordTranslation = nil
            selectedPhraseWordIndex = nil
            selectedTranscriptWordIndex = nil
        }
    }
    
    private var phraseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SpokenTextView(
                text: phrase.english,
                highlightedRange: pronunciationPlayer.highlightedRange,
                wordMatches: latestResult?.wordMatches ?? [],
                selectedIndex: $selectedPhraseWordIndex,
                onWordTapped: { word, index in
                    selectedPhraseWordIndex = index
                    selectedTranscriptWordIndex = nil
                    selectedWordTranslation = WordTranslation(word: word, meaning: translation(for: word))
                }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title)
            .fontWeight(.bold)
            
            Text(phrase.chinese)
                .font(.title3)
                .foregroundStyle(.secondary)
            TagView(text: phrase.focus, systemImage: "lightbulb.fill")
            
            if let translation = selectedWordTranslation {
                TranslationBubble(translation: translation)
            }
        }
    }
    
    private var controlSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                toggleRecording()
            } label: {
                Label(
                    speechRecognizer.isRecording ? "点击停止" : "开始录音",
                    systemImage: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(speechRecognizer.isRecording ? .red : .blue)
            
            Button {
                if speechRecognizer.isRecording {
                    speechRecognizer.stopTranscribing()
                }
                selectedWordTranslation = nil
                selectedPhraseWordIndex = nil
                selectedTranscriptWordIndex = nil
                pronunciationPlayer.speak(phrase.english)
            } label: {
                Label(
                    pronunciationPlayer.isSpeaking ? "播放中…" : "播放示范",
                    systemImage: pronunciationPlayer.isSpeaking ? "waveform.circle.fill" : "speaker.wave.2.fill"
                )
                .font(.subheadline)
            }
            .buttonStyle(.bordered)
            
            if speechRecognizer.isRecording {
                Text("正在聆听，请自然地说出整句。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if pronunciationPlayer.isSpeaking && !speechRecognizer.isRecording {
                Text("听一遍示范，再跟读会更容易。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            if let error = speechRecognizer.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }
    
    private var transcriptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("录音转写")
                    .font(.headline)
                Spacer()
                if !speechRecognizer.transcript.isEmpty {
                    Button("清空") {
                        speechRecognizer.resetTranscript()
                        latestResult = nil
                        selectedWordTranslation = nil
                        selectedPhraseWordIndex = nil
                        selectedTranscriptWordIndex = nil
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            SpokenTextView(
                text: speechRecognizer.transcript.isEmpty ? "未捕捉到语音..." : speechRecognizer.transcript,
                highlightedRange: nil,
                wordMatches: latestResult?.wordMatches ?? [],
                selectedIndex: $selectedTranscriptWordIndex,
                onWordTapped: { word, index in
                    selectedTranscriptWordIndex = index
                    selectedPhraseWordIndex = nil
                    selectedWordTranslation = WordTranslation(word: word, meaning: translation(for: word))
                }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .animation(.easeInOut, value: speechRecognizer.transcript)
        }
    }
    
    private func resultSection(result: SpeakingResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("发音评分")
                    .font(.headline)
                Spacer()
                Text(result.scorePercentageText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(result.accuracy >= 0.85 ? .green : result.accuracy >= 0.6 ? .orange : .red)
            }
            
            Text(result.evaluationText)
                .font(.body)
            
            if !result.missingWords.isEmpty {
                TagList(title: "建议加强的词", items: result.missingWords, systemImage: "exclamationmark.circle")
            }
            
            if !result.extraWords.isEmpty {
                TagList(title: "多余的词", items: result.extraWords, systemImage: "arrowshape.turn.up.left")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var tipsSection: some View {
        DisclosureGroup(isExpanded: $showTips) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(phrase.tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "sparkle")
                            .foregroundStyle(.orange)
                        Text(tip)
                    }
                }
            }
            .padding(.top, 8)
        } label: {
            Text("发音建议")
                .font(.headline)
        }
    }
    
    private func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopTranscribing()
            pronunciationPlayer.stop()
            evaluateResult()
        } else {
            latestResult = nil
            pronunciationPlayer.stop()
            selectedWordTranslation = nil
            selectedPhraseWordIndex = nil
            selectedTranscriptWordIndex = nil
            speechRecognizer.startTranscribing()
        }
    }
    
    private func evaluateResult() {
        guard !speechRecognizer.transcript.isEmpty else {
            speechRecognizer.errorMessage = "没有捕捉到语音，再试一次。"
            return
        }
        isEvaluating = true
        pronunciationPlayer.stop()
        let result = speakingService.recordPractice(for: phrase, transcript: speechRecognizer.transcript)
        let xpReward = Int(result.accuracy * 20) + 5
        userService.addXP(xpReward)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            latestResult = result
        }
        isEvaluating = false
    }

    private func translation(for word: String) -> String {
        let normalized = normalizeWord(word)
        guard !normalized.isEmpty else { return "" }
        if let entry = wordService.words.first(where: { $0.english.lowercased() == normalized }) {
            return entry.chinese
        }
        return "暂无释义"
    }
    
    private func normalizeWord(_ word: String) -> String {
        word.trimmingCharacters(in: CharacterSet.punctuationCharacters.union(.whitespacesAndNewlines)).lowercased()
    }
}

private struct TranslationBubble: View {
    let translation: WordTranslation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(translation.word)
                .font(.headline)
            Text(translation.meaning)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WordTranslation: Identifiable {
    let id = UUID()
    let word: String
    let meaning: String
}

// MARK: - 历史记录
struct SpeakingHistoryView: View {
    @EnvironmentObject private var speakingService: SpeakingPracticeService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if speakingService.practiceHistory.isEmpty {
                    ContentUnavailableView {
                        Label("暂无练习记录", systemImage: "mic.slash")
                    } description: {
                        Text("完成一次练习后，成绩会自动保存到这里。")
                    }
                } else {
                    Section {
                        ForEach(speakingService.practiceHistory) { result in
                            SpeakingResultRow(result: result)
                        }
                        .onDelete(perform: speakingService.removeHistory)
                    }
                }
            }
            .navigationTitle("练习历史")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !speakingService.practiceHistory.isEmpty {
                        EditButton()
                    }
                }
            }
        }
    }
}

// MARK: - 结果行
struct SpeakingResultRow: View {
    let result: SpeakingResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(result.phrase.english)
                    .font(.headline)
                Spacer()
                Text(result.scorePercentageText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(result.accuracy >= 0.85 ? .green : result.accuracy >= 0.6 ? .orange : .red)
            }
            
            Text(result.transcript.isEmpty ? "无有效录音" : result.transcript)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            Text(result.practicedAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Tag 视图
struct TagView: View {
    let text: String
    var systemImage: String = "tag"
    
    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .foregroundStyle(.blue)
            .clipShape(Capsule())
    }
}

struct TagList: View {
    let title: String
    let items: [String]
    let systemImage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                ForEach(items, id: \.self) { item in
                    TagView(text: item, systemImage: "textformat")
                }
            }
        }
    }
}

// MARK: - 概览数据
private struct SummaryMetricsGrid: View {
    let summary: PracticeSummary
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            SummaryMetricCard(
                title: "总练习",
                value: "\(summary.totalSessions)",
                caption: "累计完成次数",
                icon: "mic.fill",
                color: .blue
            )
            SummaryMetricCard(
                title: "平均准确率",
                value: summary.averageAccuracyText,
                caption: "最近所有练习",
                icon: "chart.bar.fill",
                color: .green
            )
            SummaryMetricCard(
                title: "最佳成绩",
                value: summary.bestAccuracyText,
                caption: "历史最高分",
                icon: "star.fill",
                color: .yellow
            )
            SummaryMetricCard(
                title: "当前连击",
                value: "\(summary.currentStreak)",
                caption: "连续练习天数",
                icon: "flame.fill",
                color: .orange
            )
        }
    }
}

private struct SummaryMetricCard: View {
    let title: String
    let value: String
    let caption: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(.headline)
            
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

private struct PracticeSummary {
    let totalSessions: Int
    let averageAccuracy: Double
    let bestAccuracy: Double
    let currentStreak: Int
    
    var averageAccuracyText: String {
        String(format: "%.0f%%", averageAccuracy * 100)
    }
    
    var bestAccuracyText: String {
        String(format: "%.0f%%", bestAccuracy * 100)
    }
    
    init?(history: [SpeakingResult], user: User?) {
        guard let user else {
            return nil
        }
        totalSessions = history.count
        if history.isEmpty {
            averageAccuracy = 0
            bestAccuracy = 0
        } else {
            let total = history.reduce(0.0) { $0 + $1.accuracy }
            averageAccuracy = total / Double(history.count)
            bestAccuracy = history.map { $0.accuracy }.max() ?? 0
        }
        currentStreak = user.studyStats.currentStreak
    }
}

#Preview {
    SpeakingPracticeHomeView()
        .environmentObject(UserService())
        .environmentObject(SpeakingPracticeService())
}
