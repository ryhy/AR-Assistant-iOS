//
//  BubbleMissile.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/22.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import ARKit
import SceneKit


class BubbleMissile {
    
    static func add(sceneView: ARSCNView) {

        let bubble = SCNSphere(radius: 0.1);
        bubble.firstMaterial?.diffuse.contents = UIImage.init(named: "bubble.jpg")
        bubble.firstMaterial?.transparency = 0.5
        bubble.firstMaterial?.writesToDepthBuffer = false
        bubble.firstMaterial?.blendMode = .screen
        bubble.firstMaterial?.reflective.contents = UIImage.init(named: "bubble.jpg")
        
        let node = SCNNode(geometry: bubble)
        node.position = SCNVector3Make(0, 0.1, 0)
        
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        
        if let camera = sceneView.pointOfView {
            parentNode.position = camera.position
            
            // Animation like bubble
            let wait = SCNAction.wait(duration: 0.2)
            
            let speedsArray: [TimeInterval] = [0.5, 1.0, 1.5]
            let speed: TimeInterval = speedsArray[Int(arc4random_uniform(UInt32(speedsArray.count)))]
            
            let toPositionCamera = SCNVector3Make(0, 0, -2)
            let toPosition = camera.convertPosition(toPositionCamera, to: nil)
            
            let move = SCNAction.move(to: toPosition, duration: speed)
            move.timingMode = .easeOut
//            let waitFiveSeconds = SCNAction.wait(duration: 3)
//            let disappear = SCNAction.fadeOut(duration: 3)
            let group = SCNAction.sequence([wait, move])
            parentNode.runAction(group) {
                let rotate = SCNAction.rotateBy(x: 0, y: 0, z: 1, duration: 1)
                let roop = SCNAction.repeatForever(rotate)
                parentNode.runAction(roop)
            }
        }
        sceneView.scene.rootNode.addChildNode(parentNode)

    }
}
