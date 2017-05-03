import UIKit
import Speech

protocol ListenerDelegate: class {
    func listener(_ listener: Listener, didUpdateRecognizerAuthorizationStatus status: SFSpeechRecognizerAuthorizationStatus)
    func listener(_ listener: Listener, didDetectWordToLookUp word: String)
    func listenerDidDetectCaptureRequest(_ listener: Listener)
    func listenerDidDetectNameCalled(_ listener: Listener)
    func listener(_ listener: Listener, didUpdateBestTranscription transcription: String?)
}

class Listener: NSObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    fileprivate let audioEngine = AVAudioEngine()
    
    weak var delegate: ListenerDelegate?
    var bestTranscriptionString: String? {
        didSet {
            delegate?.listener(self, didUpdateBestTranscription: bestTranscriptionString)
        }
    }
    
    private var isMonitoring = false
    
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined {
        didSet {
            delegate?.listener(self, didUpdateRecognizerAuthorizationStatus: authorizationStatus)
        }
    }
    
    override init() {
        super.init()
        speechRecognizer.delegate = self
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                self.authorizationStatus = authStatus
            }
        }
    }
    
    private var isNameCalled = false
    
    func startMonitoring() throws {
        if isMonitoring { return }
        isMonitoring = true
        isNameCalled = false
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let `self` = self else { return }
            
            var isFinal = false
            
            if let result = result {
                let input = result.bestTranscription.formattedString
                isFinal = result.isFinal
                self.bestTranscriptionString = input
                
                if !self.isNameCalled && input.lastIndex(of: "ボス") != nil {
                    self.delegate?.listenerDidDetectNameCalled(self)
                    self.isNameCalled = true
                }
                
                ["ってなんですか", "てなんですか", "って何", "ってなに", "わかりますか", "なに", "なんですか"].forEach({ (suffix) in
                    if input.hasSuffix(suffix) {
                        isFinal = true
                        var word = input.replacingOccurrences(of: suffix, with: "")
                        self.recognitionRequest?.endAudio()
                        
                        if let index = word.lastIndex(of: "ボス") {
                            word = word.substring(from: word.index(word.startIndex, offsetBy: index)).replacingOccurrences(of: "ボス", with: "")
                        }
                        
                        if word.hasPrefix("これ") {
                            self.delegate?.listenerDidDetectCaptureRequest(self)
                        } else {
                            self.delegate?.listener(self, didDetectWordToLookUp: word)
                        }
                    }
                })
            }
            
            // TODO: 60秒以上経過した場合の処理
            if error != nil || isFinal {
                self.isMonitoring = false
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
}

extension Listener: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        debugPrint("SpeechRecognizer availabile: ", available)
    }
}
