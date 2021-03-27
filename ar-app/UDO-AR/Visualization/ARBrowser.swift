//
//  ARBrowser.swift
//  UDO-AR
//
//  Created by CuiZihan on 2021/3/21.
//

import UIKit
import ARKit

protocol ARBrowserDelegate: class {
    func addBrowserNode(node : SCNNode)
    func removeBrowserNode(node : SCNNode)
    
}

class ARBrowser : NSObject {
    var webView : UIWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: 1080, height: 1920))
    
    var webViewARNode: SCNNode?
    
    weak var delegate: ARBrowserDelegate?
    
    init(delegate: ARBrowserDelegate) {
        self.delegate = delegate
    }
    
    func placeARWebView(in position: SCNVector3) {
        let browserPlane = SCNPlane(width: 1.2, height: 1.6)
        DispatchQueue.main.async {
            let url = URL(string: "http://192.168.1.108:3000")
            self.webView.loadRequest(URLRequest(url: url!))
        }
        
        browserPlane.firstMaterial?.diffuse.contents = webView
        browserPlane.firstMaterial?.isDoubleSided = true
        self.webViewARNode = SCNNode(geometry: browserPlane)
        self.webViewARNode?.position = SCNVector3(position.x + 1, position.y + 0.2, position.z - 0.2)
        
        self.delegate?.addBrowserNode(node: self.webViewARNode!)
    }
    
    func removeARWebView() {
        delegate?.removeBrowserNode(node: self.webViewARNode!)
    }
    
    
    func updateBrowserContent() {
        
    }
}
