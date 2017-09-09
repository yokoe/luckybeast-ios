import UIKit

class AppSettings {
    struct Key {
        static let displayMode: String = "DisplayMode"
    }
    
    static let shared = AppSettings()
    
    var displayMode: DisplayMode? {
        set(value) {
            UserDefaults.standard.set(value?.rawValue, forKey: Key.displayMode)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let object = UserDefaults.standard.object(forKey: Key.displayMode) as? String else {
                return nil
            }
            
            return DisplayMode(rawValue: object)
        }
    }
}
