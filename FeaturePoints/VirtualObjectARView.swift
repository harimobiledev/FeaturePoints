/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A custom `ARSCNView` configured for the requirements of this project.
*/

import Foundation
import ARKit

@available(iOS 11.0, *)
class VirtualObjectARView: ARSCNView {
	
    func smartHitTest(_ point: CGPoint,
                      infinitePlane: Bool = false,
                      objectPosition: float3? = nil,
                      allowedAlignments: [ARPlaneAnchor.Alignment] = [.horizontal]) -> ARHitTestResult? {
		
		// Perform the hit test.
		let results = hitTest(point, types: [.estimatedHorizontalPlane])
		
		// 1. Check for a result on an existing plane using geometry.
        if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingExtent }),
            let planeAnchor = existingPlaneUsingGeometryResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
            return existingPlaneUsingGeometryResult
		}

		if infinitePlane {
			
			// 2. Check for a result on an existing plane, assuming its dimensions are infinite.
			//    Loop through all hits against infinite existing planes and either return the
			//    nearest one (vertical planes) or return the nearest one which is within 5 cm
			//    of the object's position.
			let infinitePlaneResults = hitTest(point, types: .existingPlane)
            
            for infinitePlaneResult in infinitePlaneResults {
                if let planeAnchor = infinitePlaneResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {

                    // For horizontal planes we only want to return a hit test result
                    // if it is close to the current object's position.
                    if let objectY = objectPosition?.y {
                        let planeY = infinitePlaneResult.worldTransform.translation.y
                        if objectY > planeY - 0.05 && objectY < planeY + 0.05 {
                            return infinitePlaneResult
                        }
                    } else {
                        return infinitePlaneResult
                    }
                }
            }
		}
		let hResult = results.first(where: { $0.type == .estimatedHorizontalPlane })
        return hResult
	}
}
