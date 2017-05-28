import UIKit

class BossCoreView: UIView {
    private static let padding: CGFloat = 10
    private static let indicatorPadding: CGFloat = 10
    private static let indicatorDivisions = 20
    
    var mode: LuckyBeast.Mode = .idle {
        didSet {
            if mode == .thinking {
                startIndicatorTimer()
            } else {
                stopIndicatorTimer()
            }
            setNeedsDisplay()
        }
    }
    private var timerStartedAt: Date?
    
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
        UIBezierPath(ovalIn: bounds.insetBy(dx: BossCoreView.padding, dy: BossCoreView.padding)).fill()
    }

    private func drawIndicator() {
        let centerX = bounds.midX
        let centerY = bounds.midY
        let indicatorRadius = min(centerX, centerY) - BossCoreView.indicatorPadding - BossCoreView.padding
        
        let timeElapsed = -(timerStartedAt?.timeIntervalSinceNow ?? 0)
        let indicatorProgress = TimeInterval(Int(round(timeElapsed * 100)) % 100) * 0.01
        
        for i in 0...BossCoreView.indicatorDivisions {
            let alpha: CGFloat = indicatorProgress * 4 - TimeInterval(i) * 0.1 > 0 ? 1 : 0
            UIColor(white: 1, alpha: min(alpha, 1)).setStroke()
            
            let angle = CGFloat(i) / CGFloat(BossCoreView.indicatorDivisions) * 2 * CGFloat.pi - CGFloat.pi * 0.5
            let path = UIBezierPath()
            path.move(to: CGPoint(x: centerX + cos(angle) * indicatorRadius, y: centerY + sin(angle) * indicatorRadius))
            path.addLine(to: CGPoint(x: centerX + cos(angle) * indicatorRadius * 0.7, y: centerY + sin(angle) * indicatorRadius * 0.7))
            path.lineWidth = 10
            path.stroke()
        }
    }
    
    // Indicator timer
    private var indicatorTimer: Timer?
    private func startIndicatorTimer() {
        if indicatorTimer == nil {
            timerStartedAt = Date()
            indicatorTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                self.setNeedsDisplay()
            }
        }
    }
    
    private func stopIndicatorTimer() {
        indicatorTimer?.invalidate()
        indicatorTimer = nil
    }
}
