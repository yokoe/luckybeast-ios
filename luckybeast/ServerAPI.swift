import UIKit
import Alamofire
import enum Result.Result

enum ServerError: Error {
    case invalidWord
}

struct WordSummary {
    var word: String
    var summary: String
}

class ServerAPI: NSObject {
    private var endpointBase: String
    init(endpoint: String) {
        endpointBase = endpoint
    }
    
    func lookUp(_ word: String, completion: @escaping ((Result<WordSummary, NSError>) -> ())) {
        Alamofire.request("\(endpointBase)/wikipedia/search", parameters: ["word": word]).responseJSON { response in
            switch response.result {
            case .success(let json):
                if let dictionary = json as? [AnyHashable: Any], let summary = dictionary["summary"] as? String {
                    completion(.success(WordSummary(word: word, summary: summary)))
                } else {
                    completion(.failure(ServerError.invalidWord as NSError))
                }
            case .failure(let error):
                completion(.failure(error as NSError))
            }
        }
    }
}
