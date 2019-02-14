//
//  FeaturePointsNode.swift
//  FeaturePoints
//
//  Created by Harikrishna Keerthipati on 02/06/18.
//  Copyright © 2018 Avantari Technologies. All rights reserved.
//

import UIKit
import ARKit

class FeaturePointsNode: SCNNode {

    var count = 0
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCustomeFeaturePoints(_ frame: ARFrame) {
        
        let pointsCount = frame.rawFeaturePoints?.points.count
        count += 1
        if count%50 != 0
        {
            return
        }
        if pointsCount != nil {
            
            self.removeFeaturePointNodes()
            var index: Int = 0
            while index < pointsCount!
            {
                let point = (frame.rawFeaturePoints?.points[index])!
                let vector = SCNVector3Make(point[0], point[1], point[2])
                
                let pointNode = SCNNode(geometry: featurePointPlane())
                pointNode.position = vector
                pointNode.rotation = SCNVector4Make(1, 0, 0, -.pi/2.0)
                self.addChildNode(pointNode)
                pointNode.runAction(SCNAction.scale(by: 10.0, duration: 0.5))
                index = index + 4
            }
        }
    }
    
    fileprivate func featurePointPlane() -> SCNSphere
    {
        let pointPlane = SCNSphere(radius: 0.0005)
        pointPlane.firstMaterial?.diffuse.contents = UIColor.white
        return pointPlane
    }
    
    fileprivate func removeFeaturePointNodes()
    {
        for child in childNodes
        {
            child.runAction(SCNAction.scale(to: 0.000, duration: 0.2)) {
                child.removeFromParentNode()
            }
        }
    }
}
