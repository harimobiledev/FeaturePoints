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

class ARViewController: UIViewController {

    @IBOutlet var sceneView: VirtualObjectARView!
    
    var featurePointsNode : FeaturePointsNode?
    var bouncingCircle: BouncingCircle?
    var arState = ARState.showingFeaturePoints
    var planes = [OverlayPlane] ()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.scene = SCNScene()
        featurePointsNode = FeaturePointsNode()
        self.sceneView.scene.rootNode.addChildNode(featurePointsNode!)
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
    
    fileprivate func registerGestureRecognizers()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(tapGesture:)))
        self.sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped(tapGesture: UITapGestureRecognizer)
    {
        let location = tapGesture.location(in: self.sceneView)
        let results = self.sceneView.hitTest(location, types: .existingPlane)
        if !results.isEmpty{
            if let result = results.first
            {
                removePlaneNode()
                doBounceAnimation(result)
            }
        }
    }
    
    fileprivate func removePlaneNode()
    {
        for node in sceneView.scene.rootNode.childNodes
        {
            node.removeFromParentNode()
        }
    }
    
    fileprivate func doBounceAnimation(_ result: ARHitTestResult) {
        let bouncingCircle = BouncingCircle(scnView: self.sceneView)
        bouncingCircle.position = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
        self.sceneView.scene.rootNode.addChildNode(bouncingCircle)
        bouncingCircle.startTapAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
