import UIKit

class Const: NSObject {
    private static func stringValue(forKey key: String) -> String {
        guard let plistURL = Bundle.main.url(forResource: "Keys", withExtension: "plist") else {
            fatalError("Keys.plist not found.")
        }
        
        guard let plist = NSDictionary(contentsOf: plistURL) else {
            fatalError("Cannot load Keys.plist")
        }
        
        guard let value = plist[key] as? String else {
            fatalError("\(key) is not set in Keys.plist")
        }
        
        return value
    }
    
    static var cloudVisionAPIKey: String {
        return stringValue(forKey: "GOOGLE_CLOUD_VISION_API_KEY")
    }
    
    static var translatorSubscriptionKey: String {
        return stringValue(forKey: "MICROSOFT_TRANSLATOR_SUBSCRIPTION_KEY")
    }
    
    static var luckyBeastServerAPIEndpoint: String {
        return stringValue(forKey: "LUCKYBEAST_SERVER_API_ENDPOINT")
    }
}
