import Foundation

// MARK: - 口语练习短语
struct SpeakingPhrase: Identifiable, Hashable, Codable {
    let id: UUID
    let english: String
    let chinese: String
    let scenario: String
    let focus: String
    let tips: [String]
    
    init(id: UUID = UUID(), english: String, chinese: String, scenario: String, focus: String, tips: [String]) {
        self.id = id
        self.english = english
        self.chinese = chinese
        self.scenario = scenario
        self.focus = focus
        self.tips = tips
    }
}

// MARK: - 练习结果
struct SpeakingResult: Identifiable, Codable {
    let id: UUID
    let phrase: SpeakingPhrase
    let transcript: String
    let accuracy: Double
    let missingWords: [String]
    let extraWords: [String]
    let evaluationText: String
    let practicedAt: Date
    let wordMatches: [WordMatch]
    
    init(id: UUID = UUID(),
         phrase: SpeakingPhrase,
         transcript: String,
         accuracy: Double,
         missingWords: [String],
         extraWords: [String],
         evaluationText: String,
         practicedAt: Date = Date(),
         wordMatches: [WordMatch]) {
        self.id = id
        self.phrase = phrase
        self.transcript = transcript
        self.accuracy = accuracy
        self.missingWords = missingWords
        self.extraWords = extraWords
        self.evaluationText = evaluationText
        self.practicedAt = practicedAt
        self.wordMatches = wordMatches
    }
    
    enum CodingKeys: String, CodingKey {
        case id, phrase, transcript, accuracy, missingWords, extraWords, evaluationText, practicedAt, wordMatches
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        phrase = try container.decode(SpeakingPhrase.self, forKey: .phrase)
        transcript = try container.decode(String.self, forKey: .transcript)
        accuracy = try container.decode(Double.self, forKey: .accuracy)
        missingWords = try container.decode([String].self, forKey: .missingWords)
        extraWords = try container.decode([String].self, forKey: .extraWords)
        evaluationText = try container.decode(String.self, forKey: .evaluationText)
        practicedAt = try container.decodeIfPresent(Date.self, forKey: .practicedAt) ?? Date()
        wordMatches = try container.decodeIfPresent([WordMatch].self, forKey: .wordMatches) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(phrase, forKey: .phrase)
        try container.encode(transcript, forKey: .transcript)
        try container.encode(accuracy, forKey: .accuracy)
        try container.encode(missingWords, forKey: .missingWords)
        try container.encode(extraWords, forKey: .extraWords)
        try container.encode(evaluationText, forKey: .evaluationText)
        try container.encode(practicedAt, forKey: .practicedAt)
        try container.encode(wordMatches, forKey: .wordMatches)
    }
    
    var scorePercentageText: String {
        String(format: "%.0f%%", accuracy * 100)
    }
}

struct WordMatch: Codable {
    let index: Int
    let expected: String
    let spoken: String?
    let isCorrect: Bool
}

// MARK: - 示例数据
extension SpeakingPhrase {
    static let samplePhrases: [SpeakingPhrase] = [
        SpeakingPhrase(
            english: "Could you repeat that more slowly?",
            chinese: "请你再慢一点说好吗？",
            scenario: "职场会议",
            focus: "礼貌提问，连读和语调",
            tips: [
                "注意连读：could you → couldju",
                "句尾的升调让语气更礼貌",
                "slowly 中的 L 需要舌尖抵上颚"
            ]
        ),
        SpeakingPhrase(
            english: "I'm looking for a cozy coffee shop nearby.",
            chinese: "我在找附近一家舒适的咖啡店。",
            scenario: "旅行出行",
            focus: "连读与情绪表达",
            tips: [
                "cozy 的发音 /ˈkoʊzi/，句子整体保持轻松语气",
                "nearby 放在句尾时语调要略微上扬",
                "注意 looking for 的连读"
            ]
        ),
        SpeakingPhrase(
            english: "Let's schedule a quick call to confirm the details.",
            chinese: "我们安排一个简短的电话确认细节。",
            scenario: "远程办公",
            focus: "商务沟通",
            tips: [
                "schedule 在美音中读作 /ˈskedʒuːl/",
                "confirm the details 时重音落在 confirm 和 details 上",
                "整体语气保持坚定且礼貌"
            ]
        ),
        SpeakingPhrase(
            english: "I didn't catch that, could you say it again?",
            chinese: "我刚刚没听清，可以再说一次吗？",
            scenario: "日常对话",
            focus: "听力反馈",
            tips: [
                "didn't catch that 是很地道的口语表达",
                "注意结尾 again 的降调让语气更自然",
                "使用微笑语气，让请求更友好"
            ]
        ),
        SpeakingPhrase(
            english: "What strategies have worked well for your team?",
            chinese: "有哪些策略对你们团队很有效？",
            scenario: "团队协作",
            focus: "开放式提问",
            tips: [
                "strategies 中间的发音 /ˈstrætədʒiːz/",
                "句子整体保持开放和好奇的语气",
                "注意 for your 的连读"
            ]
        ),
        SpeakingPhrase(
            english: "Could you recommend a good place for local food?",
            chinese: "你能推荐一家当地美食的好地方吗？",
            scenario: "旅行问路",
            focus: "场景词汇",
            tips: [
                "recommend 中重音在第三个音节 /ˌrekəˈmend/",
                "local food 需要清晰发出 L 和 F",
                "意图是寻求建议，语气要友好"
            ]
        ),
        SpeakingPhrase(
            english: "I'd love to hear more about your experience with remote teams.",
            chinese: "我想多了解一些你远程团队的经验。",
            scenario: "远程办公",
            focus: "深入提问",
            tips: [
                "I'd love to hear 发音要连读，保持轻松友好语气",
                "experience with remote teams 重音在 experience 与 remote",
                "句尾保持上扬表示期待对方分享"
            ]
        ),
        SpeakingPhrase(
            english: "Let's circle back to this topic after we gather more data.",
            chinese: "等我们收集到更多数据后，再回到这个话题。",
            scenario: "职场会议",
            focus: "会议管理",
            tips: [
                "circle back 是常见职场表达，注意 back 的爆破音",
                "gather more data 中的 gather 发音 /ˈɡæðər/",
                "保持冷静自信语气，体现推进会议的能力"
            ]
        ),
        SpeakingPhrase(
            english: "What challenges are you facing with your pronunciation practice?",
            chinese: "你在练习发音时遇到了什么挑战？",
            scenario: "学习辅导",
            focus: "共情提问",
            tips: [
                "challenges 中的 ch 发 /tʃ/，后半部分要柔和",
                "facing with your 发音要连读",
                "语气真诚，注意句尾略微下降显示关心"
            ]
        ),
        SpeakingPhrase(
            english: "Could you clarify what you mean by 'scalable solution'?",
            chinese: "你说的“可扩展解决方案”具体指什么？",
            scenario: "团队协作",
            focus: "澄清观点",
            tips: [
                "clarify 与 scalable 的重音位置要准",
                "引用词语时可略微放慢速度强调",
                "保持礼貌语气，避免质疑感"
            ]
        ),
        SpeakingPhrase(
            english: "Thanks for the invitation, let me check my schedule.",
            chinese: "谢谢邀请，我确认一下我的时间安排。",
            scenario: "社交活动",
            focus: "礼貌回应",
            tips: [
                "Thanks for the invitation 要连读 for the",
                "let me check 可发作 “lemme check” 更自然",
                "句尾 schedule 美音读 /ˈskedʒuːl/"
            ]
        ),
        SpeakingPhrase(
            english: "Is there anything else I can help you with today?",
            chinese: "今天还有什么我可以帮你的？",
            scenario: "客户支持",
            focus: "服务用语",
            tips: [
                "anything else 重音在 else",
                "help you with 中的 with 结尾清晰发音",
                "整体保持微笑语气，句尾轻微上扬"
            ]
        ),
        SpeakingPhrase(
            english: "I'm currently focusing on improving my listening comprehension.",
            chinese: "我目前专注在提升听力理解。",
            scenario: "自我介绍",
            focus: "学习目标",
            tips: [
                "currently focusing on 连读，自然过渡",
                "listening comprehension 要分清音节",
                "保持自信语气，体现积极学习态度"
            ]
        ),
        SpeakingPhrase(
            english: "Could you give me a quick rundown of the project timeline?",
            chinese: "能给我简单讲一下项目时间线吗？",
            scenario: "项目沟通",
            focus: "信息请求",
            tips: [
                "give me 可读成 gimme，更口语化",
                "rundown 是常用商务词，重音在 run",
                "语速可以稍快，突出“quick”体现效率"
            ]
        ),
        SpeakingPhrase(
            english: "I'm happy to schedule a follow-up session this Thursday.",
            chinese: "我很乐意在本周四安排一次跟进会议。",
            scenario: "时间安排",
            focus: "确认计划",
            tips: [
                "happy to schedule 中 to 可弱读",
                "follow-up 注意连字符词的节奏",
                "this Thursday 重音在 Thursday，并清晰发 th"
            ]
        ),
        SpeakingPhrase(
            english: "It sounds like a great opportunity to practice with native speakers.",
            chinese: "听起来是个和母语者练习的好机会。",
            scenario: "学习讨论",
            focus: "表达积极反馈",
            tips: [
                "sounds like 常见搭配，连读为 soundz like",
                "native speakers 注意 /ˈneɪtɪv/",
                "语气放松，表达真诚兴趣"
            ]
        ),
        SpeakingPhrase(
            english: "Before we wrap up, could you share your key takeaway?",
            chinese: "在结束前，你能分享一下你的主要收获吗？",
            scenario: "会议总结",
            focus: "总结引导",
            tips: [
                "wrap up 发音 /ræp/, p 要轻微爆破",
                "key takeaway 是常用短语，重音在 key 和 take",
                "语气坚定但友好，鼓励对方回应"
            ]
        )
    ]
}
