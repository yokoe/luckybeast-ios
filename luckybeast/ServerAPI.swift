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
    
    func lookUp(_ word: String, fromLanguage language: String?, completion: @escaping ((Result<WordSummary, NSError>) -> ())) {
        var params = ["word": word]
        if let language = language {
            params["from"] = language
        }
        Alamofire.request("\(endpointBase)/wikipedia/search", parameters: params).responseJSON { response in
            switch response.result {
            case .success(let json):
                if let dictionary = json as? [AnyHashable: Any], let summary = dictionary["summary"] as? String, let translatedWord = dictionary["word"] as? String {
                    completion(.success(WordSummary(word: translatedWord, summary: summary)))
                } else {
                    completion(.failure(ServerError.invalidWord as NSError))
                }
            case .failure(let error):
                completion(.failure(error as NSError))
            }
        }
    }
    
    func image(_ image: UIImage, completion: @escaping ((Result<WordSummary, NSError>) -> ())) {
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(UIImageJPEGRepresentation(image, 0.7)!, withName: "file", fileName: "captured.jpg", mimeType: "image/jpeg")
        }, to: "\(endpointBase)/wikipedia/from_image", encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        if let dictionary = json as? [AnyHashable: Any], let summary = dictionary["summary"] as? String, let translatedWord = dictionary["word"] as? String {
                            completion(.success(WordSummary(word: translatedWord, summary: summary)))
                        } else {
                            completion(.failure(ServerError.invalidWord as NSError))
                        }
                    case .failure(let error):
                        completion(.failure(error as NSError))
                    }
                }
            case .failure(let encodingError):
                completion(.failure(encodingError as NSError))
            }
        })
    }
}
