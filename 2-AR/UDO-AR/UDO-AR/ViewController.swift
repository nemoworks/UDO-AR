//
//  ViewController.swift
//  UDO-AR
//
//  Created by CuiZihan on 2021/3/15.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    var referenceObject: ARReferenceObject?
    
    var bubbleNode: SCNNode? = nil
    
    var isOff = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "ar-model", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        configuration.detectionObjects = referenceObjects
        sceneView.session.run(configuration, options: [.removeExistingAnchors,.resetTracking])
    }
    
    
    // MARK:- ARKit
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {
            print(objectAnchor.referenceObject.name!)
            let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.005))
            sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.cyan
            node.addChildNode(sphereNode)
            
            if objectAnchor.referenceObject.name! == "air-purifier" {
                let billboardConstraint = SCNBillboardConstraint()
                billboardConstraint.freeAxes = SCNBillboardAxis.Y
                let bubble = SCNText(string: "Air Purifier: Off", extrusionDepth: 0.015)
                let font = UIFont(name: "Futura", size: 0.1)
                bubble.font = font
                bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
                bubble.firstMaterial?.diffuse.contents = UIColor.red
                bubble.firstMaterial?.specular.contents = UIColor.white
                bubble.firstMaterial?.isDoubleSided = true
                bubble.chamferRadius = CGFloat(0.002)
                
                let (minBound, maxBound) = bubble.boundingBox
                let bubbleNode = SCNNode(geometry: bubble)
                bubbleNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x)/2, minBound.y, 0.015 / 2)
                bubbleNode.scale = SCNVector3(0.5, 0.5, 0.5)
                bubbleNode.name = "text"
                bubbleNode.constraints = [billboardConstraint]
                node.addChildNode(bubbleNode)
                self.bubbleNode = bubbleNode
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        if touch.view == self.sceneView {
            let viewTouchLocation = touch.location(in: self.sceneView)
            guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {return}
            
            if let bubble = bubbleNode,  bubble == result.node {
                if isOff {
                    turnOnAirPurifier()
                } else {
                    turnOffAirPurifier()
                }
            }
        }
    }
    
    func turnOnAirPurifier() {
        isOff = false
        if let textGeometry = self.bubbleNode?.geometry as? SCNText {
            textGeometry.string = "Air Purifier: On"
            textGeometry.firstMaterial?.diffuse.contents = UIColor.green
        }
        
        // MARK: - TODO
    }
    
    func turnOffAirPurifier() {
        isOff = true
        if let textGeometry = self.bubbleNode?.geometry as? SCNText {
            textGeometry.string = "Air Purifier: Off"
            textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        }
    }
    

}

