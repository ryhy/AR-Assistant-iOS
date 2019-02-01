//
//  Army.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/21.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import SceneKit

// Spheres that are shot at the "ships"
class Army: SCNNode {
    
    override init () {
        super.init()
        
        let box = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 1)
        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionTypes.otherPhysics.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.invaderPhysics.rawValue
        self.physicsBody?.contactTestBitMask = 2
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        self.geometry?.materials  = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
