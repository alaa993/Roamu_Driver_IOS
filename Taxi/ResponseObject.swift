//
//  ResponseObject.swift
//  Taxi
//
//  Created by Bhavin
//  skype : bhavin.bhadani
//

import UIKit
import Alamofire

final class ResponseObject: NSObject, ResponseObjectSerializable {
    var status: Bool?
    var message: String?
    var data: Any?
    
    internal init?(response: HTTPURLResponse, representation: Any) {
        guard let res = representation as? [String:Any] else {
            self.status = false
            self.message = "Something goes wrong."
            return
        }
        
        if let stat = res["status"] as? String {
            if stat == "success" {
                self.status = true
            } else {
                self.status = false
            }
        } else {
            self.status = false
        }
        
        if let err = res["error"] as? String{
            self.message = err
        }
        
        if let str = res["data"] as? String {
            self.message = str
        } else if let data = res["data"] {
            self.data = data
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------------------
// MARK:- APIRequestManager
//----------------------------------------------------------------------------------------------------------------------------------------------
class APIRequestManager:NSObject {
    class func request(apiRequest:URLRequestConvertible,
                       success:@escaping (Any) -> Void, failure:@escaping (String) -> Void, error:@escaping (Error) -> Void) {
        _ = Alamofire.request(apiRequest).responseObject(completionHandler: { (response: DataResponse<ResponseObject>) in
            if response.result.isSuccess{
                if let result = response.value {
                    if result.status == true {
                        if let message = result.message {
                            success(message as Any)
                        } else {
                            success(result.data as Any)
                        }
                    }
                    else{
                        if result.message != nil {
                            failure(result.message!)
                        }
                        else{
                            failure("Something goes wrong.")
                        }
                    }
                }
            }
            else{
                error(response.result.error!)
            }
        })
    }
    
    class func upload(with urlString:String, parameters:[String:String], headers:[String:String], image:UIImage, imgName:String,
                      success:@escaping (Any) -> Void, error:@escaping (Error) -> Void){
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let imageData = image.jpegData(compressionQuality: 1) {
                multipartFormData.append(imageData, withName: imgName, fileName: "file.jpeg", mimeType: "image/jpeg")
            }
            
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: .utf8))!, withName: key)
            }
        }, to: urlString, method: .post, headers: headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    success(response.value as Any)
                }
            case .failure(let encodingError):
                error(encodingError)
            }
        })
    }
    
}
