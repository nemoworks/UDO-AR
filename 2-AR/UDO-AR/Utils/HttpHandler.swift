//
//  HttpHandler.swift
//  UDO-AR
//
//  Created by 崔子寒 on 2021/3/16.
//

import UIKit

protocol HttpHandlerDelegate: class {
    func handleResponseStatus(statusCode:Int)
}

class HttpHandler: NSObject {
    
    weak var delegate: HttpHandlerDelegate?
    
    func sendRequest(to url: String, method: String, bodyData: Data?) {
        let requestUrl = URL(string: url)!
        var request = URLRequest(url: requestUrl)
        request.setValue("test auth token", forHTTPHeaderField: "Authorization")
        
        
        request.httpMethod = method
        request.httpBody = bodyData
        
        
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 3.0
        sessionConfig.timeoutIntervalForResource = 3.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                self.delegate?.handleResponseStatus(statusCode: 404)
                return
            }
            
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Stauts Code \(httpResponse.statusCode)")
                self.delegate?.handleResponseStatus(statusCode: httpResponse.statusCode)
            }
        }
        sleep(1)
        task.resume()
        
    }
    
    func sendTurnOnRequest() {
        
    }
    
    func sendTurnOffRequest() {
        
    }
    
    func fetchState() {
        
    }
}
