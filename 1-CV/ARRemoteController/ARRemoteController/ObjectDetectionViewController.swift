//
//  ViewController.swift
//  ARRemoteController
//
//  Created by 崔子寒 on 2021/3/8.
//

import UIKit
import ARKit
import CoreML
import Vision

class ObjectDetectionViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    
    private var viewportSize: CGSize!
    
    override var shouldAutorotate: Bool {return false}
    
    var boundingBox = CAShapeLayer()
    
    var frameCount = 0
    
    var detectAirPurifier:Bool = true
    
    var control : SCNNode? = nil
    
    var bubbleNode: SCNNode? = nil
    
    var isOff = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sceneView.delegate = self
        sceneView.showsStatistics = true
        self.viewportSize = self.sceneView.frame.size
        self.setupBoundingBox()
        self.setupLight()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        sceneView.session.run(configuration, options: [.removeExistingAnchors,.resetTracking])
        detectAirPurifier = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Setup
    
    func setupBoundingBox() {
        sceneView.layer.addSublayer(boundingBox)
        self.boundingBox.strokeColor = UIColor.green.cgColor
        self.boundingBox.fillColor = UIColor.clear.cgColor
        self.boundingBox.lineWidth = 5
    }
    
    
    func dispalyBoundingBox(box: CGRect) {
        DispatchQueue.main.async {
            print("Will display box: \(box)")
            let x = box.minX * self.sceneView.bounds.width
            let y = box.minY * self.sceneView.bounds.height
            let width = box.width * self.sceneView.bounds.width
            let height = box.height * self.sceneView.bounds.height
            self.boundingBox.path = UIBezierPath(roundedRect: CGRect(x: x , y: y , width: width, height: height), cornerRadius: 4).cgPath
        }
    }
    
    func setupLight() {
        sceneView.autoenablesDefaultLighting = true
    }
    
    
    // MARK: - CoreML
    
    lazy var objectDetectionRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: AirPurifierDetectorV5(configuration: MLModelConfiguration()).model)
            let request = VNCoreMLRequest(model: model) {
                [weak self] request, error in
                self?.processDetections(for: request, error: error)
            }
            return request
        } catch {
            fatalError("Failed to load Vision ML model.")
        }
    }()
    
    // Porcess detection results, generate bounding box and the anchor to put AR content.
    func processDetections(for request: VNRequest, error: Error?) {
        guard error == nil else {
            print("Object detection error: \(error!.localizedDescription)")
            return
        }
        
        guard let results = request.results else {return}
        
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {continue}
            let topLabelObservation = objectObservation.labels.first!
    
            if topLabelObservation.identifier == "air-purifier" {
                // print("Find a air purifier at \(objectObservation.boundingBox)")
                
                // guard let currentFrame = sceneView.session.currentFrame else {continue}
                
            
                self.dispalyBoundingBox(box: objectObservation.boundingBox)
                let t = CGAffineTransform(scaleX: viewportSize.width, y: viewportSize.height)
                let viewBoundingBox = objectObservation.boundingBox.applying(t)
                let midPoint = CGPoint(x: viewBoundingBox.midX, y: viewBoundingBox.midY)
                
                let hitTestResults = sceneView.hitTest(midPoint, types: .featurePoint)
                guard let hitTestResult = hitTestResults.first else {continue}
                displayARContent(in: hitTestResult.worldTransform)
                detectAirPurifier = false
            }
        }
        
    }
    
    // MARK: - ARKit
    
    // Perform the request at every beginning of the render loop.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        frameCount += 1
        frameCount %= (Int(INT_MAX) - 1)
        
        if frameCount % 5 == 4 {
            self.boundingBox.path = nil
            return
        }
        
        if frameCount % 5 != 0 {
            return
        }
        
        if !detectAirPurifier {
            return
        }
        
        guard let capturedImage = sceneView.session.currentFrame?.capturedImage else {return}
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: capturedImage, options: [:])
        do {
            try imageRequestHandler.perform([self.objectDetectionRequest])
        } catch {
            print("Failed to perform image request. ")
        }
    }
    
    
    // Display AR content
    func displayARContent(in transform: matrix_float4x4) {
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.002))
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.cyan
        sphereNode.worldPosition = SCNVector3(transform.columns.3.x, transform.columns.3.y - 0.003, transform.columns.3.z)
        sphereNode.name = "mark"
        
        let bubble = createBubble()
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        bubbleNode.position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        bubbleNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x)/2, minBound.y, 0.015 / 2)
        bubbleNode.scale = SCNVector3(0.2, 0.2, 0.2)
        bubbleNode.name = "text"
        
        self.control = sphereNode
        self.bubbleNode = bubbleNode
        
        sceneView.scene.rootNode.addChildNode(sphereNode)
        sceneView.scene.rootNode.addChildNode(bubbleNode)
    }
    
    func createBubble()->SCNText{
        if isOff {
            let bubble = SCNText(string: "Air Purifier: Off", extrusionDepth: 0.015)
            let font = UIFont(name: "Futura", size: 0.1)
            bubble.font = font
            bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            bubble.firstMaterial?.diffuse.contents = UIColor.red
            bubble.firstMaterial?.specular.contents = UIColor.white
            bubble.firstMaterial?.isDoubleSided = true
            bubble.chamferRadius = CGFloat(0.002)
            return bubble
        } else {
            let bubble = SCNText(string: "Air Purifier: On", extrusionDepth: 0.015)
            let font = UIFont(name: "Futura", size: 0.1)
            bubble.font = font
            bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            bubble.firstMaterial?.diffuse.contents = UIColor.green
            bubble.firstMaterial?.specular.contents = UIColor.white
            bubble.firstMaterial?.isDoubleSided = true
            bubble.chamferRadius = CGFloat(0.002)
            return bubble
        }
            
    }

 
    
    // MARK: - Handler
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        if touch.view == self.sceneView {
            let viewTouchLocation = touch.location(in: self.sceneView)
            guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {return}
            
            if let control = control, let bubble = bubbleNode, control == result.node || bubble == result.node {
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

