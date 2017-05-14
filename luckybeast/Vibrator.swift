import UIKit
import AudioToolbox

class Vibrator {
    var isOn = false {
        didSet {
            if oldValue != isOn {
                if isOn {
                    startVibration()
                } else {
                    stopVibration()
                }
            }
        }
    }
    
    private var timer: Timer?
    private func startVibration() {
        debugPrint("Start vibration")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        })
    }
    
    private func stopVibration() {
        debugPrint("Stop vibration")
        timer?.invalidate()
        timer = nil
    }
    
}
