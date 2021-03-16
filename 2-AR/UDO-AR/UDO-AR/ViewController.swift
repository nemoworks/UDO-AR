//
//  ViewController.swift
//  UDO-AR
//
//  Created by CuiZihan on 2021/3/15.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    var referenceObject: ARReferenceObject?
    
    var bubbleNode: SCNNode? = nil
    
    var isOff = true
    
    @IBOutlet weak var arSessionInfo: UILabel!
    
    @IBOutlet weak var blurView: UIView!
    
    @IBOutlet weak var httpReqeustIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.sceneView.delegate = self
        self.sceneView.session.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.showsStatistics = true
        
        arSessionInfo.text = "AR Session is initializing"
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = 20
        blurView.layer.cornerRadius = 20
        blurEffectView.frame = self.blurView.bounds
        blurView.addSubview(blurEffectView)
        
        self.httpReqeustIndicator.isHidden = true
        
    }
    
    let dispatchQueueAR = DispatchQueue(label: "cn.nju.nemoworks")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "ar-model", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        configuration.detectionObjects = referenceObjects
        sceneView.session.run(configuration, options: [.removeExistingAnchors,.resetTracking])
    }
    
    
    // MARK:- ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {
            print(objectAnchor.referenceObject.name!)
            let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.05 / 2))
            sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            let transform = anchor.transform
            sphereNode.position = SCNVector3(transform.columns.3.x, transform.columns.3.y + 0.02, transform.columns.3.z)
            self.sceneView.scene.rootNode.addChildNode(sphereNode)
            self.bubbleNode = sphereNode
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        if touch.view == self.sceneView {
            let viewTouchLocation = touch.location(in: self.sceneView)
            let results = sceneView.hitTest(viewTouchLocation, options: nil)
            print(results)
            guard let result = results.first else {return}
            
            if let bubble = bubbleNode,  bubble == result.node {
                if isOff {
                    dispatchQueueAR.async {
                        self.turnOnAirPurifier()
                    }
                } else {
                    dispatchQueueAR.async {
                        self.turnOffAirPurifier()
                    }
                }
            }
        }
    }
    
    // MARK:- Gesture handle
    
    func turnOnAirPurifier() {
        isOff = false
        self.handleGesture()
    }
    
    func turnOffAirPurifier() {
        isOff = true
        self.handleGesture()
    }
    
    func handleGesture() {
        self.httpReqeustIndicator.startAnimating()
        let sphere = self.bubbleNode?.geometry as! SCNSphere
        if !isOff {
            sphere.firstMaterial?.diffuse.contents = UIColor.green
            sendRequest(to: "http://192.168.124.4/api/v1/udo/turn-on", method: "GET")
            
        } else {
            sphere.firstMaterial?.diffuse.contents = UIColor.red
            sendRequest(to: "http://192.168.124.4/api/v1/udo/turn-off", method: "POST")
        }
    }
    
    func sendRequest(to url: String, method: String) {
        let requestUrl = URL(string: url)!
        var request = URLRequest(url: requestUrl)
        request.setValue("test auth token", forHTTPHeaderField: "Authorization")
        let body = ["entity_id" : "fan.mypurifier2"]
        let bodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        
        request.httpMethod = method
        request.httpBody = bodyData
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // MARK:- TODO
                } else {
                    
                }
            }
        }
        
        task.resume()
        
    }
    
    
    // MARK:- ARSessionDelegate

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        self.arSessionInfo.text = camera.trackingState.presentationString
    }
}

