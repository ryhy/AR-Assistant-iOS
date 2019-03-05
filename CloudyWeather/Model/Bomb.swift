//
//  Bomb.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/03/05.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import ARKit

class Bomb: SCNNode {
    
    override init () {
        super.init()
        
        let sphere = SCNSphere(radius: 0.2)
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionTypes.bombPhysics.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.invaderPhysics.rawValue
        self.physicsBody?.contactTestBitMask = 1
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        self.geometry?.materials  = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func add(sceneView: ARSCNView) {
        
        let bubble = SCNSphere(radius: 0.1);
        bubble.firstMaterial?.diffuse.contents = UIColor.black
        bubble.firstMaterial?.transparency = 0.5
        bubble.firstMaterial?.writesToDepthBuffer = false
        bubble.firstMaterial?.blendMode = .screen
        
        let node = SCNNode(geometry: bubble)
        node.position = SCNVector3Make(0, 0.1, 0)
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        if let camera = sceneView.pointOfView {
            parentNode.position = camera.position
            let toPositionCamera = SCNVector3Make(0, 0, -2)
            let toPosition = camera.convertPosition(toPositionCamera, to: nil)
        }
        sceneView.scene.rootNode.addChildNode(parentNode)
        
    }
    
}
