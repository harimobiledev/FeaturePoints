//
//  OverlayNode.swift
//  HelloAR
//
//  Created by Harikrishna Keerthipati on 03/04/18.
//  Copyright © 2018 Avantari Technologies. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum BodyType : Int {
    case box = 1
    case plane = 2
    case car = 3
}

class OverlayPlane: SCNNode {

    var previousX: Float!
    var previousZ: Float!
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!
    let dotSize = 0.03
    let gapSize = 0.06
    init(anchor: ARPlaneAnchor) {
        
        self.anchor = anchor
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor)
    {
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        let planeNode = self.childNodes.first!
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        addDots(anchor: anchor)
    }
    
    func addDots(anchor: ARPlaneAnchor)
    {
        if previousX != anchor.extent.x, previousZ != anchor.extent.z
        {
            for node in self.childNodes
            {
                if node.name == "dot node"
                {
                    node.removeFromParentNode()
                }
            }
            let x = anchor.extent.x
            let z = anchor.extent.z
            let eachDotSizeWithGap = dotSize + gapSize
            previousX = x
            previousZ = z
            let dotsInXDirection = Int(x/Float(eachDotSizeWithGap))
            let dotsInZDirection = Int(z/Float(eachDotSizeWithGap))
            for zIndex in 0...Int(dotsInZDirection)
            {
                for xIndex in 0...Int(dotsInXDirection)
                {
                    let plane = SCNPlane(width: CGFloat(dotSize), height: CGFloat(dotSize))
                    plane.firstMaterial?.diffuse.contents = UIColor.white
                    plane.cornerRadius = plane.width/2
                    let node = SCNNode(geometry: plane)
                    node.name = "dot node"
                    node.rotation = SCNVector4Make(1, 0, 0, -.pi/2.0)
                    let zPosition = Double((Float(zIndex)*Float(eachDotSizeWithGap)) - Float(self.planeGeometry.height/2))
                    var xPosition = (Float(xIndex)*Float(eachDotSizeWithGap)) - Float(self.planeGeometry.width/2)
                    if zIndex%2 == 0
                    {
                        xPosition = xPosition + Float(eachDotSizeWithGap/2.0)
                    }
                    if xIndex == 1 || zIndex == 1 || xIndex == dotsInXDirection - 1 || zIndex == dotsInZDirection - 1
                    {
                        plane.firstMaterial?.transparency = 0.4
                    }
                    else if xIndex == 0 || zIndex == 0 || xIndex == dotsInXDirection || zIndex == dotsInZDirection
                    {
                        plane.firstMaterial?.transparency = 0.1
                    }
                    node.position = SCNVector3Make(Float(xPosition + 0.1), 0.01, Float(zPosition + 0.1))
                    self.addChildNode(node)
                }
            }
        }
    }
    
    private func setup()
    {
        self.planeGeometry = SCNPlane(width: CGFloat(self.anchor.extent.x), height: CGFloat(self.anchor.extent.z))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.transparency = 0.0
        self.planeGeometry.materials = [material]
        let planeNode = SCNNode(geometry: self.planeGeometry)

        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask =  BodyType.plane.rawValue

        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
        self.addChildNode(planeNode)
    }
}
