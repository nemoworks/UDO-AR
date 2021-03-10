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
    
    var MAX_NUM_OF_OBJECTS: Int = 5
    
    var boundingBox = CAShapeLayer()
    var contentNodes = [SCNNode]()
    
    var frameCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sceneView.delegate = self
        self.viewportSize = self.sceneView.frame.size
        self.setupBoundingBox()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        sceneView.session.run(configuration, options: [.removeExistingAnchors])
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
    
    func clearAllContentNodes() {
        for node in contentNodes {
            node.removeFromParentNode()
        }
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
    
    
    // MARK: - CoreML
    
    lazy var objectDetectionRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: AirPurifierDetectorV2(configuration: MLModelConfiguration()).model)
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
        
        // print(results)
        
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {continue}
            let topLabelObservation = objectObservation.labels.first!
    
            if topLabelObservation.identifier == "air-purifier" {
                // print("Find a air purifier at \(objectObservation.boundingBox)")
                
                // guard let currentFrame = sceneView.session.currentFrame else {continue}
                
            
                self.dispalyBoundingBox(box: objectObservation.boundingBox)
            }
        }
        
    }
    
    // MARK: - ARKit
    
    // Perform the request at every beginning of the render loop.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if frameCount % 10 == 9 {
            self.boundingBox.path = nil
            return
        }
        
        if frameCount % 10 != 0 {
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
    
    
    // Remove outdated anchor
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }


}

