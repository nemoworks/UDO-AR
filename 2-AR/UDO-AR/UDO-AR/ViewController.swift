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
    
    var textNode: SCNNode? = nil
    var sphereNode: SCNNode? = nil
    let airParticleSystem = SCNParticleSystem(named: "air-particle.scnp", inDirectory: nil)
    
    var isRunning = false
    
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
        
        self.airParticleSystem?.particleColor = .cyan
        
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

            // 1. Add Text Node
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = SCNBillboardAxis.Y
            let arText = SCNText(string: "Xiaomi AirPurifier", extrusionDepth: 0.5)
            let font = UIFont(name: "System", size: 0.2)
            arText.font = font
            arText.firstMaterial?.diffuse.contents = UIColor.red
            arText.firstMaterial?.specular.contents = UIColor.white
            arText.firstMaterial?.isDoubleSided = true
            arText.chamferRadius = 0.2
            
            
            let (minBound, maxBound) = arText.boundingBox
            let textNode = SCNNode(geometry: arText)
            textNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x) / 2, minBound.y, 0.1)
            textNode.scale = SCNVector3(0.02, 0.02, 0.02)
            textNode.constraints = [billboardConstraint]
            
            let transform = anchor.transform
            textNode.position = SCNVector3(transform.columns.3.x, transform.columns.3.y + 0.15, transform.columns.3.z - 0.15)
            self.sceneView.scene.rootNode.addChildNode(textNode)
            self.textNode = textNode
            
            // 2. Add Sphere Node
            let sphere = SCNSphere(radius: 0.05)
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            sphereNode.geometry?.firstMaterial?.specular.contents = UIColor.white
            sphereNode.position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            self.sceneView.scene.rootNode.addChildNode(sphereNode)
            self.sphereNode = sphereNode
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        if touch.view == self.sceneView {
            let viewTouchLocation = touch.location(in: self.sceneView)
            let results = sceneView.hitTest(viewTouchLocation, options: nil)
            print(results)
            guard let result = results.first else {return}
            
            if let sphereNode = self.sphereNode,  sphereNode == result.node {
                if !isRunning {
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
        self.handleHttpRequest()
    }
    
    func turnOffAirPurifier() {
        self.handleHttpRequest()
    }
    
    func handleHttpRequest() {
        DispatchQueue.main.async {
            self.httpReqeustIndicator.startAnimating()
        }
        
        if !isRunning {
            self.httpHandler.sendTurnOnRequest()
        } else {
            self.httpHandler.sendTurnOffRequest()
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
            let text = self.textNode?.geometry as! SCNText
            isRunning = !isRunning
            if isRunning {
                DispatchQueue.main.async {
                    text.firstMaterial?.diffuse.contents = UIColor.green
                    self.sphereNode?.addParticleSystem(self.airParticleSystem!)
                }
            } else {
                DispatchQueue.main.async {
                    text.firstMaterial?.diffuse.contents = UIColor.red
                    self.sphereNode?.removeParticleSystem(self.airParticleSystem!)
                }
            }
        } else {
            let refreshAlert = UIAlertController(title: "Something wrong", message: "发送http请求失败" , preferredStyle: .alert)
            refreshAlert.addAction(UIAlertAction(title: "重试", style: .default){
                _ in
                self.handleHttpRequest()
            })
            
            refreshAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            
            DispatchQueue.main.async {
                self.present(refreshAlert, animated: true, completion: nil)
            }
        }
    }
    
    
}
