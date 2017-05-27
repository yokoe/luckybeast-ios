import UIKit

class BossCoreView: UIView {
    private static let indicatorPadding: CGFloat = 10
    private static let indicatorDivisions = 20
    
    var mode: LuckyBeast.Mode = .idle {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.black.setFill()
        UIRectFill(bounds)
        
        drawBackground()

        if mode == .thinking {
            drawIndicator()
        }
    }
    
    private func drawBackground() {
        switch mode {
        case .idle:
            UIColor.darkGray.setFill()
        case .launching:
            UIColor.yellow.setFill()
        case .listening, .thinking:
            UIColor.lightGray.setFill()
        case .playing:
            UIColor.green.setFill()
        case .panic:
            UIColor.white.setFill()
        }
        UIBezierPath(ovalIn: bounds).fill()
    }

    private func drawIndicator() {
        let centerX = bounds.midX
        let centerY = bounds.midY
        let indicatorRadius = min(centerX, centerY) - BossCoreView.indicatorPadding
        
        UIColor.darkGray.setFill()
        UIColor.darkGray.setStroke()
        
        for i in 0...BossCoreView.indicatorDivisions {
            let angle = CGFloat(i) / CGFloat(BossCoreView.indicatorDivisions) * 2 * CGFloat.pi
            let path = UIBezierPath()
            path.move(to: CGPoint(x: centerX + cos(angle) * indicatorRadius, y: centerY + sin(angle) * indicatorRadius))
            path.addLine(to: CGPoint(x: centerX + cos(angle) * indicatorRadius * 0.5, y: centerY + sin(angle) * indicatorRadius * 0.5))
            path.lineWidth = 10
            path.stroke()
        }
    }
}
