import UIKit

class EyeView: UIView {
    
    enum Status {
        case normal
        case white
        case shining
    }
    
    var status: Status = .normal {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = bounds.width * 0.5
        clipsToBounds = true
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        UIColor.black.setFill()
        UIRectFill(bounds)
        
        if status == .white {
            UIColor.white.setFill()
            UIBezierPath(roundedRect: bounds.insetBy(dx: 4, dy: 4), cornerRadius: 8).fill()
        }
        
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(x: 4, y: 8, width: 10, height: 10)).fill()
        
        if status == .shining {
            UIColor.blue.setStroke()
            let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 4, dy: 4), cornerRadius: 8)
            path.lineWidth = 3
            path.stroke()
        }
    }

}
