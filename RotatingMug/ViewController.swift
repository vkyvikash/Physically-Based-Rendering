//
//  ViewController.swift
//  RotatingMug
//
//  Created by Vikash Kumar on 09/09/18.
//  Copyright © 2018 Vikash Kumar. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var currentAngleY: Float = 0
    
    private var planes = [UUID: Plane]() // Dictionary of planes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints] // This is how you show feature points
        sceneView.antialiasingMode = .multisampling4X
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/CoffeeMug/model.dae")!
//        self.sceneView?.autoenablesDefaultLighting = true
//        self.sceneView.scene = scene
//
        //      TODO: Should be done like below line, instead of directly calling childNodes[0]
        // let shipNode = scene.rootNode.childNode(withName: "model", recursively: true)!
//        let mugNode = scene.rootNode.childNodes[0]
//        mugNode.scale = SCNVector3(0.01, 0.01, 0.01)
//
//        let (minVec, maxVec) = mugNode.boundingBox
//        mugNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, 0, (maxVec.z - minVec.z) / 2 + minVec.z)
        
        // TODO Fix rotate functionality
        let rotateGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateModels(_:)))
        sceneView.addGestureRecognizer(rotateGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScene(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapScene(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else {
            return
        }
        
        let point = sender.location(in: self.sceneView)
        let results = self.sceneView.hitTest(point, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        
        
        if let match = results.first {
            let scene = SCNScene(named: "art.scnassets/CoffeeMug/model.dae")!
        
            //      TODO: Should be done like below line, instead of directly calling childNodes[0]
            // let shipNode = scene.rootNode.childNode(withName: "model", recursively: true)!
            let mugNode = scene.rootNode.childNodes[0]
            let t = match.worldTransform
            mugNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
            mugNode.scale = SCNVector3(0.02, 0.02, 0.02)
            
            let (minVec, maxVec) = mugNode.boundingBox
            mugNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, 0, (maxVec.z - minVec.z) / 2 + minVec.z)
            
            // TODO remove this hack. You should be able to get the exact planeNode and remove that
            self.sceneView.scene.rootNode.enumerateChildNodes { (existingNode, _) in
                guard (existingNode.geometry as? SCNPlane) != nil else {
                    return
                }
                existingNode.removeFromParentNode()
            }
            self.sceneView.scene.rootNode.addChildNode(mugNode)
        }
    }
    
    @objc func rotateModels(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view!)
        var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
        newAngleY += currentAngleY
        
        DispatchQueue.main.async {
            self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                node.eulerAngles.y = newAngleY
            }
        }
        
        if(gesture.state == .ended) { currentAngleY = newAngleY }
    }
    
    func addAnimation(node: SCNNode) {
        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: 0, duration: 5.0)
        let repeatForever = SCNAction.repeatForever(rotateOne)
        node.runAction(repeatForever)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    // 3 renderers overwrite karne hn..
    // 1. when ARPlaneAnchor is added
    // 2. when ARPlaneAnchor is updated
    // 3. when Anchor is removed
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = Plane(anchor: planeAnchor)
        planes[planeAnchor.identifier] = plane
        node.addChildNode(plane)
        
        print("Found plane \(planeAnchor)")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
