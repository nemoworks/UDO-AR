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
        let body = ["entity_id" : "fan.mypurifier2"]
        let bodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        
        self.sendRequest(to: "http://192.168.1.111:8000/api/v1/udo/turn-on", method: "POST", bodyData: bodyData)
    }
    
    func sendTurnOffRequest() {
        let body = ["entity_id" : "fan.mypurifier2"]
        let bodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        
        self.sendRequest(to: "http://192.168.1.111:8000/api/v1/udo/turn-off", method: "POST", bodyData: bodyData)
    }
    
    func fetchState() {
        // 需要发送带有JSON Body的GET请求，但是Swift的URLSession不支持发送带Body的GET
        // 需要修改后端的方法
    }
}
