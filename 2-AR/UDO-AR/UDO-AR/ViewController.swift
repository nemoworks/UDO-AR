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
    
    var httpHandler = HttpHandler()
    
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
        
        self.httpHandler.delegate = self
        
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
        DispatchQueue.main.async {
            self.httpReqeustIndicator.startAnimating()
        }
        let sphere = self.bubbleNode?.geometry as! SCNSphere
        if !isOff {
            sphere.firstMaterial?.diffuse.contents = UIColor.green
            let body = ["entity_id" : "fan.mypurifier2"]
            let bodyData = try? JSONSerialization.data(
                withJSONObject: body,
                options: []
            )
            self.httpHandler.sendRequest(to: "http://192.168.124.4:8000/api/v1/udo/turn-on", method: "POST", bodyData: bodyData)
            
        } else {
            sphere.firstMaterial?.diffuse.contents = UIColor.red
            let body = ["entity_id" : "fan.mypurifier2"]
            let bodyData = try? JSONSerialization.data(
                withJSONObject: body,
                options: []
            )
            self.httpHandler.sendRequest(to: "http://192.168.124.4:8000/api/v1/udo/turn-off", method: "POST", bodyData: bodyData)
        }
    }
    
    
    
    
    // MARK:- ARSessionDelegate

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        self.arSessionInfo.text = camera.trackingState.presentationString
    }
}

extension ViewController: HttpHandlerDelegate {
    func handleResponseStatus(statusCode: Int) {
        DispatchQueue.main.async {
            self.httpReqeustIndicator.stopAnimating()
        }
        if statusCode == 200 {
            // MARK:- TODO
        } else {
            
        }
    }
    
    
}
