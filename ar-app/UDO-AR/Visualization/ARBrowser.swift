//
//  ARBrowser.swift
//  UDO-AR
//
//  Created by CuiZihan on 2021/3/21.
//

import UIKit
import ARKit
import WebKit

protocol ARBrowserDelegate: AnyObject {
    func addBrowserNode(node : SCNNode)
    func removeBrowserNode(node : SCNNode)
    
}

class ARBrowser : NSObject, WKNavigationDelegate {
    var webView : WKWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 800, height: 1000), configuration: WKWebViewConfiguration())
    
    var webViewARNode: SCNNode?
    weak var delegate: ARBrowserDelegate?
    let browserPlane = SCNPlane(width: 1.2, height: 1.5)
    
    
    init(delegate: ARBrowserDelegate) {
        super.init()
        self.delegate = delegate
        self.webView.navigationDelegate = self
        DispatchQueue.main.async {
            let url = URL(string: "http://192.168.1.101:2200/")
            // let url = URL(string: "https://apple.com")
            self.webView.load(URLRequest(url: url!))
        }
        browserPlane.firstMaterial?.diffuse.contents = self.webView.screenshot()
        browserPlane.firstMaterial?.isDoubleSided = true
        self.webViewARNode = SCNNode(geometry: browserPlane)
        
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                self.browserPlane.firstMaterial?.diffuse.contents = self.webView.screenshot()
            }
        }
    }
    
    func placeARWebView(in position: SCNVector3) {
        self.webViewARNode?.position = SCNVector3(position.x + 1, position.y + 0.2, position.z - 0.2)
        
        self.delegate?.addBrowserNode(node: self.webViewARNode!)
    }
    
    func removeARWebView() {
        delegate?.removeBrowserNode(node: self.webViewARNode!)
    }
    
}

extension WKWebView {
    func screenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0);
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true);
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snapshotImage;
    }
}
