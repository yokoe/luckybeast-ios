import UIKit
import Alamofire
import enum Result.Result

class Detector: NSObject {
    static let errorDomain = "DetectorErrorDomain"
    struct ErrorCode {
        static let jsonError = 1
    }
    
    struct Annotation {
        let text: String
        let mid: String
        let score: Float
    }
    
    var cloudVisionAPIKey: String?
    private var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(cloudVisionAPIKey ?? "")")!
    }
    
    init(key: String) {
        cloudVisionAPIKey = key
    }
    
    func detectObjects(in image: UIImage, completion: @escaping ((Result<[Annotation], NSError>) -> ())) {
        let request: Parameters = [
            "requests": [
                "image": [
                    "content": image.base64String
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        let httpHeader: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? ""
        ]
        Alamofire.request(googleURL, method: .post, parameters: request, encoding: JSONEncoding.default, headers: httpHeader).validate(statusCode: 200..<300).responseJSON { response in
            switch response.result {
            case .success(let json):
                guard let dictionary = json as? [AnyHashable: Any], let response0 = (dictionary["responses"] as?[[AnyHashable: Any]])?.first, let labelAnnotations = response0["labelAnnotations"] as? [[AnyHashable: Any]] else {
                    completion(.failure(NSError(domain: Detector.errorDomain, code: Detector.ErrorCode.jsonError, userInfo: nil)))
                    return
                }
                
                completion(.success(labelAnnotations.map({ Annotation(text: $0["description"] as! String, mid: $0["mid"] as! String, score: $0["score"] as! Float) })))
            case .failure(let error):
                completion(.failure(error as NSError))
            }
        }
    }
}

fileprivate extension UIImage {
    var base64String: String {
        return UIImagePNGRepresentation(self)!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}
