import UIKit
import AVFoundation

protocol SpeakerDelegate: class {
    func speaker(_ speaker: Speaker, didUpdateStatus isSpeaking: Bool)
}

class Speaker: NSObject {
    typealias CompletionBlock = ((Bool) -> ())
    private let synthesizer = AVSpeechSynthesizer()
    
    var isSpeaking = false {
        didSet {
            delegate?.speaker(self, didUpdateStatus: isSpeaking)
        }
    }
    weak var delegate: SpeakerDelegate?
    var completionBlock: CompletionBlock?
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(_ message: String, completion: CompletionBlock? = nil) {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSessionCategoryAmbient)
        synthesizer.stopSpeaking(at: .immediate)
        completionBlock?(false)
        
        completionBlock = completion
        
        let utterance = AVSpeechUtterance(string: message)
        utterance.pitchMultiplier = 1.2
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        
        debugPrint("Speak: ", message)
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        completionBlock?(true)
        completionBlock = nil
    }
}
