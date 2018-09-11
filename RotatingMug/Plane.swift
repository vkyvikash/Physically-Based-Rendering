//
//  Plane.swift
//  RotatingMug
//
//  Created by Vikash Kumar on 09/09/18.
//  Copyright © 2018 Vikash Kumar. All rights reserved.
//

import Foundation
import ARKit

class Plane: SCNNode {
    var plane: SCNPlane
    
    init(anchor: ARPlaneAnchor) {
        plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        super.init()
        
        plane.cornerRadius = 0.005
        
        // ab build and add an SCNode using this plane
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.eulerAngles.x = -Float.pi/2
        planeNode.opacity = 0.15
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Code which is called whenever the anchor updates
    func updateWith(anchor: ARPlaneAnchor) {
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
    
    func hidePlane() {
        // TODO implement this
//        planeNode.geometry?.materials.first?.diffuse.contents = UIColor(white: 1, alpha: 0)
    }
}
