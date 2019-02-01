//
//  Gun.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/11.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import SceneKit

// Spheres that are shot at the "ships"
class Bullet: SCNNode {
    
    override init () {
        super.init()
        
        let sphere = SCNSphere(radius: 0.01)
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionTypes.bulletPhysics.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.invaderPhysics.rawValue
        self.physicsBody?.contactTestBitMask = 1
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        self.geometry?.materials  = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
