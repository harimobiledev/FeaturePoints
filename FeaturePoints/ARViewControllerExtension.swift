//
//  ARControllerExtension.swift
//  FeaturePoints
//
//  Created by Harikrishna Keerthipati on 02/06/18.
//  Copyright © 2018 Avantari Technologies. All rights reserved.
//

import Foundation
import ARKit

enum ARState {
    
    case showingFeaturePoints
    case planeDetected
}

extension ARViewController: ARSCNViewDelegate, ARSessionDelegate
{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !(anchor is ARPlaneAnchor)
        {
            return
        }
        DispatchQueue.main.async {
            self.featurePointsNode?.removeFromParentNode()

            self.sceneView.session.delegate = nil
            let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
            self.planes.append(plane)
            node.addChildNode(plane)
            self.arState = .planeDetected
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = self.planes.filter { plane  in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        if arState == .showingFeaturePoints
        {
            featurePointsNode?.addCustomeFeaturePoints(frame)
        }
        else if arState == .planeDetected
        {
            bouncingCircle?.updatePosition()
        }
    }
}
