//
//  ViewController.swift
//  FeaturePoints
//
//  Created by Harikrishna Keerthipati on 15/05/18.
//  Copyright © 2018 Avantari Technologies. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var pointCloudNode : SCNNode?
    var planes = [OverlayPlane] ()
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
      //  let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = SCNScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        registerGestureRecognizers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func registerGestureRecognizers()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(tapGesture:)))
        self.sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped(tapGesture: UITapGestureRecognizer)
    {
        for node in sceneView.scene.rootNode.childNodes
        {
            node.removeFromParentNode()
        }
        let location = tapGesture.location(in: self.sceneView)
        let results = self.sceneView.hitTest(location, types: .existingPlane)
        if !results.isEmpty{
        
            guard let result = results.first else{ return }

            let planeViewNode = createCirclePlaneNodeWith(width: 0.1, color: .white)
            planeViewNode.eulerAngles.x = Float(-Double.pi / 2)
            planeViewNode.position = SCNVector3Make(result.worldTransform.columns.3.x,  result.worldTransform.columns.3.y,  result.worldTransform.columns.3.z)
            
            let planeViewNode2 = createCirclePlaneNodeWith(width: 0.05, color: .white)
            planeViewNode2.position = SCNVector3Make(0, 0, 0.0001)

            self.sceneView.scene.rootNode.addChildNode(planeViewNode)
            planeViewNode.addChildNode(planeViewNode2)

            planeViewNode.runAction(SCNAction.scale(by: 10, duration: 1.2))
            planeViewNode.runAction(SCNAction.fadeOpacity(to: 0.0, duration: 1.2))
        }
    }
    
    func createCirclePlaneNodeWith(width: CGFloat, color: UIColor) -> SCNNode
    {
        let plane = SCNPlane(width: width, height: width)
        plane.cornerRadius = width/2
        plane.firstMaterial?.diffuse.contents = color
        let planeViewNode = SCNNode(geometry: plane)
        return planeViewNode
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        if !(anchor is ARPlaneAnchor)
        {
            return
        }
        removeFeaturePointNodes()
        sceneView.session.delegate = nil
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        print("===did add node===")
        node.addChildNode(plane)
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
    
    fileprivate func addCustomeFeaturePoints(_ frame: ARFrame) {
        
        let pointsCount = frame.rawFeaturePoints?.points.count
        count += 1
        if count%50 != 0
        {
            return
        }
        print("pointscount===\(String(describing: pointsCount))==\(count)")
        
        if pointsCount != nil {
            
            if pointCloudNode == nil
            {
                pointCloudNode = SCNNode()
                self.sceneView.scene.rootNode.addChildNode(pointCloudNode!)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.removeFeaturePointNodes()
            }
            var index: Int = 0
            while index < pointsCount!
            {
                let point = (frame.rawFeaturePoints?.points[index])!
                let vector = SCNVector3Make(point[0], point[1], point[2])
                
                let pointNode = SCNNode(geometry: featurePointPlane())
                pointNode.position = vector
                pointNode.rotation = SCNVector4Make(1, 0, 0, -.pi/2.0)
                pointCloudNode?.addChildNode(pointNode)
                pointNode.runAction(SCNAction.scale(by: 10.0, duration: 0.5))
                index = index + 4
            }
        }
    }
    
    func featurePointPlane() -> SCNSphere
    {
        let pointPlane = SCNSphere(radius: 0.0005)
        pointPlane.firstMaterial?.diffuse.contents = UIColor.white
        return pointPlane
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        addCustomeFeaturePoints(frame)
    }
    
    func removeFeaturePointNodes()
    {
        if let childNodes = pointCloudNode?.childNodes
        {
            for child in childNodes
            {
                child.runAction(SCNAction.scale(to: 0.000, duration: 1.0)) {
                    child.removeFromParentNode()
                }
            }
        }
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
