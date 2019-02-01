//
//  Gun.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/22.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import SceneKit
import ARKit


class Missile: SCNNode {
    

    var object: SCNGeometry? = nil
    
    init(type: TYPE) {        
        super.init()
        
        switch type {
        case .smallMissile:
            let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 1)
            object = produceObject(color: .black, box: box)
            break;
        case .mediumMissile:
            let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 1)
            object = produceObject(color: .green, box: box)
            break;
        case .largeMissile:
            let box = SCNBox(width: 0.8, height: 0.8, length: 0.8, chamferRadius: 1)
            object = produceObject(color: .red, box: box)
            break;
        case .bomb:
            let box = SCNBox(width: 0.5, height: 0.5, length: 1.5, chamferRadius: 1)
            object = produceObject(color: .green, box: box)
            break;
        }
    }
    
    func add() {
        
    }

    private func produceObject(color: UIColor, box: SCNBox) -> SCNGeometry? {
        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionTypes.bulletPhysics.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.invaderPhysics.rawValue
        self.physicsBody?.contactTestBitMask = 1
        let material = SCNMaterial()
        material.diffuse.contents = color
        self.geometry?.materials  = [material]
        return self.geometry
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
