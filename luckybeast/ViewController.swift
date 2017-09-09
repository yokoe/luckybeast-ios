import UIKit
import UIView_Shake

class ViewController: UIViewController {
    enum DisplayMode {
        case phone
        case costume
    }
    
    private let isSpeechRecognizerDebugEnabled = false
    fileprivate let boss = LuckyBeast(luckyBeastServerAPIEndpoint: Const.luckyBeastServerAPIEndpoint)

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var coreView: BossCoreView!
    @IBOutlet weak var leftEye: EyeView!
    @IBOutlet weak var rightEye: EyeView!
    @IBOutlet weak var beltView: UIView!
    
    private var displayMode: DisplayMode = .phone
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        boss.delegate = self
        boss.launch()
 
        label.isHidden = !isSpeechRecognizerDebugEnabled
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func onDoubleTapScreen(_ sender: Any) {
        displayMode = displayMode == .phone ? .costume : .phone
        
        guard let backgroundView: BackgroundView = view as? BackgroundView else {
            fatalError("view is not an instance of BackgroundView.")
        }
        
        switch displayMode {
        case .costume:
            leftEye.isHidden = true
            rightEye.isHidden = true
            beltView.isHidden = true
            backgroundView.mode = .plain
        case .phone:
            leftEye.isHidden = false
            rightEye.isHidden = false
            beltView.isHidden = false
            backgroundView.mode = .texture
        }
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
            self.view.shake(200, withDelta: 4.0)
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
