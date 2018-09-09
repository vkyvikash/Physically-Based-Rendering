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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/CoffeeMug/model.dae")!
        self.sceneView?.autoenablesDefaultLighting = true
        self.sceneView.scene = scene
        
//        let shipNode = scene.rootNode.childNode(withName: "model", recursively: true)!
        let mugNode = scene.rootNode.childNodes[0]
        mugNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        let (minVec, maxVec) = mugNode.boundingBox
        mugNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, 0, (maxVec.z - minVec.z) / 2 + minVec.z)
        
        let rotateGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateModels(_:)))
        sceneView.addGestureRecognizer(rotateGesture)
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
