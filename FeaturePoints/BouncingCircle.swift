//
//  BouncingCircle.swift
//  VuforiaSampleSwift
//
//  Created by Harikrishna Keerthipati on 02/06/18.
//  Copyright © 2018 AVANTARI. All rights reserved.
//

import UIKit
import ARKit

@available(iOS 11.0, *)

class BouncingCircle: SCNNode {

    var innerCircleNode: SCNNode!
    var outerCircleNode: SCNNode!
    var sceneView: VirtualObjectARView!
    var screenCenter: CGPoint {
        
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    init(scnView: VirtualObjectARView) {
        
        super.init()
        self.sceneView = scnView
        self.eulerAngles.x = Float(-Double.pi / 2)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup()
    {
        outerCircleNode = createCirclePlaneNodeWith(width: 0.3, color: .white)
        outerCircleNode.geometry?.firstMaterial?.transparency = 0.7
        outerCircleNode.name = "circle node"
        
        innerCircleNode = createCirclePlaneNodeWith(width: 0.15, color: .white)
        innerCircleNode.position = SCNVector3Make(0, 0, 0.001)
        innerCircleNode.name = "circle node"
        
        self.addChildNode(outerCircleNode)
        self.addChildNode(innerCircleNode)
        
        outerCircleNode.runAction(scaleAction())
    }
    
    func startTapAnimation()
    {
        outerCircleNode.runAction(SCNAction.scale(by: 10, duration: 1.2))
        outerCircleNode.runAction(SCNAction.fadeOpacity(to: 0.0, duration: 1.2))
        
        innerCircleNode.runAction(SCNAction.scale(by: 10, duration: 1.2))
        innerCircleNode.runAction(SCNAction.fadeOpacity(to: 0.0, duration: 1.2))
    }
    
    func updatePosition()
    {
        DispatchQueue.main.async {
            
            if let camera = self.sceneView.session.currentFrame?.camera, case .normal = camera.trackingState, let result = self.sceneView.smartHitTest(self.screenCenter)
            {
                SCNTransaction.begin()
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                SCNTransaction.animationDuration = 0.2
                self.position = SCNVector3(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y, z: result.worldTransform.columns.3.z)
                SCNTransaction.commit()
            }
        }
    }
    
    func scaleAction() -> SCNAction
    {
        let action = SCNAction.scale(by: 1.2, duration: 0.5)
        let reverseAction = SCNAction.sequence([action.reversed()])
        let sequence = SCNAction.sequence([action, reverseAction]);
        let repeatActions = SCNAction.repeatForever(sequence)
        
        action.timingMode = .easeInEaseOut
        reverseAction.timingMode = .easeInEaseOut
        return repeatActions
    }
    
    func createCirclePlaneNodeWith(width: CGFloat, color: UIColor) -> SCNNode
    {
        let plane = SCNPlane(width: width, height: width)
        plane.cornerRadius = width/2
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.diffuse.contents = color
        let planeViewNode = SCNNode(geometry: plane)
        return planeViewNode
    }
}


