import UIKit

class BackgroundView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        UIColor(red: 180 / 255, green: 223 / 255, blue: 214 / 255, alpha: 1).setFill()
        UIRectFill(bounds)
        
        UIColor.white.setFill()
        UIBezierPath(ovalIn: bounds.insetBy(dx: -240, dy: -40).offsetBy(dx: 0, dy: 160)).fill()
    }

}
