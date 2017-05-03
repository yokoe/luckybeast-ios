import UIKit

class BossCoreView: UIView {
    var mode: LuckyBeast.Mode = .idle {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.black.setFill()
        UIRectFill(bounds)
        
        switch mode {
        case .idle:
            UIColor.darkGray.setFill()
        case .launching:
            UIColor.yellow.setFill()
        case .listening:
            UIColor.lightGray.setFill()
        case .thinking:
            UIColor.blue.setFill()
        case .playing:
            UIColor.green.setFill()
        case .panic:
            UIColor.white.setFill()
        }
        
        UIBezierPath(ovalIn: bounds).fill()
    }

}
