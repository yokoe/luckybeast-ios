import UIKit
import Speech

protocol LuckyBeastDelegate: class {
    func luckyBeast(_ luckyBeast: LuckyBeast, didChangeMode mode: LuckyBeast.Mode)
    func luckyBeast(_ luckyBeast: LuckyBeast, didUpdateBestTranscription transcription: String?)
}
class LuckyBeast: NSObject {
    enum Mode {
        case idle
        case launching
        case listening(nameCalled: Bool)
        case thinking
        case playing
        case panic
        
        var isListening: Bool {
            switch self {
            case .listening(_):
                return true
            default:
                return false
            }
        }
    }
    
    weak var delegate: LuckyBeastDelegate?
    
    fileprivate var mode: Mode = .idle {
        didSet {
            if oldValue != mode {
                delegate?.luckyBeast(self, didChangeMode: mode)
                vibrator.isOn = mode == .panic
            }
        }
    }
    
    fileprivate let speaker = Speaker()
    fileprivate let api: ServerAPI
    private let listener = Listener()
    fileprivate let capturer: Capturer
    fileprivate let vibrator = Vibrator()
    
    init(luckyBeastServerAPIEndpoint: String) {
        api = ServerAPI(endpoint: luckyBeastServerAPIEndpoint)
        capturer = Capturer()
    }
    
    func launch() {
        speaker.delegate = self
        listener.delegate = self
        capturer.delegate = self
        
        listener.requestAuthorization()
        
        self.mode = .launching
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.speaker.speak("はじめまして。僕はラッキービーストだよ。よろしくね。") { _ in
                self.startMonitoring()
            }
        }
        
        capturer.start()
    }
    
    fileprivate func lookUp(_ word: String, fromLanguage language: String? = nil) {
        mode = .thinking
        debugPrint("Looking: ", word)
        api.lookUp(word, fromLanguage: language) { result in
            switch result {
            case .success(let wordSummary):
                self.speaker.speak(wordSummary.summary) {_ in
                    self.startMonitoring()
                }
            case .failure(let error):
                self.speaker.speak("あわわわ、あわわわ、あわわわ、あわわわ、わ、わ") {_ in
                    self.startMonitoring()
                }
                debugPrint(error)
                self.mode = .panic
            }
        }
    }
    
    fileprivate func startMonitoring() {
        if mode.isListening { return }
        do {
            try listener.startMonitoring()
            mode = .listening(nameCalled: false)
        } catch _ {
            mode = .idle
            speaker.speak("モニタリングの開始に失敗しました")
        }
    }
    
    fileprivate func describeObject(in image: UIImage) {
        api.image(image) { result in
            switch result {
            case .success(let wordSummary):
                self.speaker.speak("これは\(wordSummary.word)だね。\(wordSummary.summary)") {_ in
                    self.startMonitoring()
                }
            case .failure(let error):
                self.speaker.speak("あわわわ、あわわわ、あわわわ、あわわわ、わ、わ") {_ in
                    self.startMonitoring()
                }
                debugPrint(error)
                self.mode = .panic
            }
        }
    }
}

extension LuckyBeast: SpeakerDelegate {
    func speaker(_ speaker: Speaker, didUpdateStatus isSpeaking: Bool) {
        debugPrint("isSpeaking: ", isSpeaking)
    }
}

extension LuckyBeast: ListenerDelegate {
    func listener(_ listener: Listener, didUpdateRecognizerAuthorizationStatus status: SFSpeechRecognizerAuthorizationStatus) {
        switch status {
        case .authorized:
            debugPrint("Ready")
        default:
            debugPrint("SpeechRecognizer Not ready.")
        }
    }
    
    func listener(_ listener: Listener, didDetectWordToLookUp word: String) {
        if !mode.isListening { return }
        lookUp(word)
    }
    
    func listenerDidDetectCaptureRequest(_ listener: Listener) {
        if !mode.isListening { return }
        if mode == .thinking {
            debugPrint("BUSY")
            return
        }
        
        mode = .thinking
        capturer.capture()
    }
    
    func listener(_ listener: Listener, didUpdateBestTranscription transcription: String?) {
        delegate?.luckyBeast(self, didUpdateBestTranscription: transcription)
    }
    
    func listenerDidDetectNameCalled(_ listener: Listener) {
        if !mode.isListening { return }
        mode = .listening(nameCalled: true)
    }
}

extension LuckyBeast: CapturerDelegate {
    func capturer(_ capturer: Capturer, didCaptureImage image: UIImage) {
        describeObject(in: image)
    }
}

func ==(a: LuckyBeast.Mode, b: LuckyBeast.Mode) -> Bool {
    switch (a, b) {
    case (.idle, .idle),
         (.launching, .launching),
         (.thinking, .thinking),
         (.playing, .playing),
         (.panic, .panic):
        return true
    case (let .listening(nameCalled1), let .listening(nameCalled2)):
        return nameCalled1 == nameCalled2
    default:
        return false
    }
}
func !=(a: LuckyBeast.Mode, b: LuckyBeast.Mode) -> Bool {
    return !(a == b)
}
