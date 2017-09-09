import UIKit

class BackgroundView: UIView {
    enum Mode {
        case texture
        case plain
    }
    
    var mode: Mode = .texture {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        switch mode {
        case .texture:
            UIColor(red: 180 / 255, green: 223 / 255, blue: 214 / 255, alpha: 1).setFill()
            UIRectFill(bounds)
            
            UIColor.white.setFill()
            UIBezierPath(ovalIn: bounds.insetBy(dx: -240, dy: -40).offsetBy(dx: 0, dy: 160)).fill()
        case .plain:
            UIColor.white.setFill()
            UIRectFill(bounds)
        }
    }

}
