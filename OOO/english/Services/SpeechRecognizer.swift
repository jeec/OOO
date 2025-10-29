import AVFoundation
import Foundation
import Speech
import Combine

// MARK: - 语音识别器
@MainActor
final class SpeechRecognizer: ObservableObject {
    enum PermissionState {
        case notDetermined
        case denied
        case authorized
    }
    
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var permissionState: PermissionState = .notDetermined
    @Published var errorMessage: String?
    
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer?
    
    init(locale: Locale = Locale(identifier: "en-US")) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
        self.permissionState = Self.currentPermissionState()
    }
    
    func requestPermissionsIfNeeded() async {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        if speechStatus == .notDetermined {
            let newStatus = await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status)
                }
            }
            updatePermissionState(with: newStatus)
        } else {
            updatePermissionState(with: speechStatus)
        }
        
        if permissionState == .authorized {
            let microphoneGranted = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
            if !microphoneGranted {
                permissionState = .denied
                errorMessage = "麦克风权限未开启，请到系统设置中允许访问。"
            }
        }
    }
    
    func startTranscribing() {
        Task {
            if permissionState != .authorized {
                await requestPermissionsIfNeeded()
            }
            guard permissionState == .authorized else {
                if errorMessage == nil {
                    errorMessage = "需要麦克风与语音识别权限才能开始练习。"
                }
                return
            }
            
            do {
                try beginTranscriptionSession()
            } catch {
                errorMessage = "无法启动语音识别：\(error.localizedDescription)"
                stopTranscribing()
            }
        }
    }
    
    func stopTranscribing() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // 静默处理
        }
    }
    
    func resetTranscript() {
        transcript = ""
        errorMessage = nil
    }
    
    private func beginTranscriptionSession() throws {
        guard speechRecognizer?.isAvailable ?? false else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(kAudioSessionNotActiveError), userInfo: [
                NSLocalizedDescriptionKey: "语音识别服务暂时不可用，请稍后重试。"
            ])
        }
        
        stopTranscribing()
        resetTranscript()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(kAudioSessionNoError), userInfo: [
                NSLocalizedDescriptionKey: "无法创建语音识别请求。"
            ])
        }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] result, error in
            guard let self else { return }
            if let result = result {
                Task { @MainActor in
                    self.transcript = result.bestTranscription.formattedString
                }
                if result.isFinal {
                    Task { @MainActor in
                        self.stopTranscribing()
                    }
                }
            }
            
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "语音识别中断：\(error.localizedDescription)"
                    self.stopTranscribing()
                }
            }
        })
        
        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
    }
    
    private func updatePermissionState(with status: SFSpeechRecognizerAuthorizationStatus) {
        switch status {
        case .authorized:
            permissionState = .authorized
            errorMessage = nil
        case .denied, .restricted:
            permissionState = .denied
            errorMessage = "语音识别权限被拒绝，请到系统设置开启。"
        case .notDetermined:
            permissionState = .notDetermined
        @unknown default:
            permissionState = .denied
        }
    }
    
    private static func currentPermissionState() -> PermissionState {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return .authorized
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }
}
