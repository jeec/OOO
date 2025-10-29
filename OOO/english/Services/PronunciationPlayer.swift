import AVFoundation
import Combine
import Foundation

@MainActor
final class PronunciationPlayer: NSObject, ObservableObject {
    @Published private(set) var isSpeaking = false
    @Published private(set) var highlightedRange: Range<String.Index>?
    
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    private var baseString: String = ""
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(_ text: String, language: String = "en-US") {
        guard !text.isEmpty else { return }
        stop()
        baseString = text
        highlightedRange = nil
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        if let naturalVoice = preferredVoice(for: language) {
            utterance.voice = naturalVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        }
        utterance.rate = 0.43
        utterance.pitchMultiplier = 1.08
        utterance.preUtteranceDelay = 0.12
        utterance.postUtteranceDelay = 0.08
        utterance.volume = 1.0
        
        currentUtterance = utterance
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        deactivateSessionIfNeeded()
        isSpeaking = false
        highlightedRange = nil
        currentUtterance = nil
        baseString = ""
    }
    
    private func deactivateSessionIfNeeded() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    private func preferredVoice(for language: String) -> AVSpeechSynthesisVoice? {
        let siriVoices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.name.lowercased().contains("siri") && $0.language == language
        }
        if let voice = siriVoices.first {
            return voice
        }
        return AVSpeechSynthesisVoice(language: language)
    }
}

extension PronunciationPlayer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        deactivateSessionIfNeeded()
        isSpeaking = false
        highlightedRange = nil
        currentUtterance = nil
        baseString = ""
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        deactivateSessionIfNeeded()
        isSpeaking = false
        highlightedRange = nil
        currentUtterance = nil
        baseString = ""
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        guard utterance == currentUtterance,
              let range = Range(characterRange, in: baseString) else {
            highlightedRange = nil
            return
        }
        highlightedRange = range
    }
}
