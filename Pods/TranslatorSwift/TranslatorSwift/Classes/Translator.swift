import UIKit
import Alamofire
import SWXMLHash
import enum Result.Result

public class Translator {
    struct API {
        static let issueTokenURL = "https://api.cognitive.microsoft.com/sts/v1.0/issueToken"
        static let translateURL = "https://api.microsofttranslator.com/v2/Http.svc/Translate"
    }
    
    public typealias TranslationResult = Result<String, NSError>
    
    public enum TokenStatus {
        case idle
        case available(String)
        case requesting
        case failure(Error)
    }
    
    public enum TranslationError: Error {
        case tokenUnavailable
        case unexpectedResponse(String)
    }
    
    public var tokenStatus: TokenStatus = .idle
    public init(subscriptionKey: String) {
        let headers = ["Ocp-Apim-Subscription-Key": subscriptionKey]
        
        tokenStatus = .requesting
        Alamofire.request(API.issueTokenURL, method: .post, headers: headers).responseString { (response) in
            switch response.result {
            case .success(let str):
                self.tokenStatus = .available(str)
            case .failure(let error):
                self.tokenStatus = .failure(error)
            }
        }
    }
    
    public func translate(input: String, to toLanguage: String, completion: @escaping (TranslationResult) -> ()) {
        switch tokenStatus {
        case .available(let token):
            Alamofire.request(API.translateURL, method: .get, parameters: ["text": input, "to": toLanguage], headers: ["Authorization": "Bearer \(token)"]).responseString(completionHandler: { (response) in
                switch response.result {
                case .success(let str):
                    let xml = SWXMLHash.parse(str)
                    guard let result = xml["string"].element?.text else {
                        completion(.failure(TranslationError.unexpectedResponse(str) as NSError))
                        return
                    }
                    
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error as NSError))
                }
            })
        case .idle, .requesting, .failure(_):
            completion(.failure(TranslationError.tokenUnavailable as NSError))
        }
        
    }
}
