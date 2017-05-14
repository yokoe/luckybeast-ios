import UIKit

class ViewController: UIViewController {
    private let isSpeechRecognizerDebugEnabled = false
    fileprivate let boss = LuckyBeast(cloudVisionAPIKey: Const.cloudVisionAPIKey, luckyBeastServerAPIEndpoint: Const.luckyBeastServerAPIEndpoint)

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var coreView: BossCoreView!
    @IBOutlet weak var leftEye: EyeView!
    @IBOutlet weak var rightEye: EyeView!
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        boss.delegate = self
        boss.launch()
 
        label.isHidden = !isSpeechRecognizerDebugEnabled
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}



extension ViewController: LuckyBeastDelegate {
    func luckyBeast(_ luckyBeast: LuckyBeast, didChangeMode mode: LuckyBeast.Mode) {
        let status: EyeView.Status
        switch mode {
        case .idle, .launching, .playing, .thinking:
            status = .normal
        case .panic:
            status = .white
        case .listening(let isNameCalled):
            status = isNameCalled ? .shining : .normal
        }
        
        leftEye.status = status
        rightEye.status = status
        
        coreView.mode = mode
    }
    
    func luckyBeast(_ luckyBeast: LuckyBeast, didUpdateBestTranscription transcription: String?) {
        label.text = transcription
    }
}
