//
//  ARService.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/21.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import ARKit



class ARService {
    
    var sceneView: ARSCNView
    
    let animation = AnimationService.init();
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView;
    }
    
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43);
            // location of camera in world space
            return (dir, pos);
        }
        return (SCNVector3(0, 0, 0), SCNVector3(0, 0, -0.2))
    }
    
    
    func detectRunaway(callback: (() -> Void)) {
        let ships = self.sceneView.scene.rootNode.childNodes.filter({$0.name == "ship"})
        for ship in ships {
            if let camera = (sceneView.session.currentFrame?.camera.transform.columns.3) {
                let distance = simd_distance(ship.simdTransform.columns.3, camera);
                if (distance > 4.5) {
                    print("ships are running away!! ", distance)
                    callback()
                }
            }
        }
    }
    
    
    func addBullet() {
        let bulletsNode = Bullet()
        let (direction, position) = self.getUserVector()
        bulletsNode.position.x = position.x // SceneKit/AR coordinates are in meters
        bulletsNode.position.y = position.y // SceneKit/AR coordinates are in meters
        bulletsNode.position.z = position.z // SceneKit/AR coordinates are in meters
        bulletsNode.name = "bullet"
        bulletsNode.physicsBody?.applyForce(direction, asImpulse: true)
        bulletsNode.physicsBody?.velocity.x = direction.x * Float(5.0)
        bulletsNode.physicsBody?.velocity.y = direction.y * Float(5.0)
        bulletsNode.physicsBody?.velocity.z = direction.z * Float(5.0)
        self.sceneView.scene.rootNode.addChildNode(bulletsNode)
    }
    
    
    func addBomb() {
        let bulletsNode = Bomb()
        let (_, position) = self.getUserVector()
        bulletsNode.position.x = position.x // SceneKit/AR coordinates are in meters
        bulletsNode.position.y = position.y // SceneKit/AR coordinates are in meters
        bulletsNode.position.z = position.z - 0.3 // SceneKit/AR coordinates are in meters
        bulletsNode.name = "bomb"
        self.sceneView.scene.rootNode.addChildNode(bulletsNode)
    }
    
    
    func addArmy(to spacechipnode: SCNNode) {
        let army = Army.init()
        army.position.x = spacechipnode.position.x
        army.position.y = spacechipnode.position.y
        army.position.z = spacechipnode.position.z
        army.name = "army"
        self.sceneView.scene.rootNode.addChildNode(army)
    }

    
    func startLaserBean(sceneView: ARSCNView) {
        let laser = Laser(arScnView: sceneView)
        laser.on()
    }
    
    
    func stopLaserBean(sceneView: ARSCNView) {
        let laser = Laser(arScnView: sceneView)
        laser.off()
    }

    
    func createShips(number: Int) {
        for i in 0...Int(number) {
            let rocketship = SCNScene(named: "art.scnassets/ship.scn");
            if let ship = rocketship?.rootNode.childNode(withName: "ship", recursively: true) {
                let pos = floatBetween(Float(Int.random(in: -1...1)), and: Float(Int.random(in: -2...2)))
                let ypos = floatBetween(0, and: 1)
                ship.name = "ship_\(i)"
                ship.position = SCNVector3(pos, ypos, floatBetween(-0.5, and: -1));
                ship.scale.x = 0.2;
                ship.scale.y = 0.2;
                ship.scale.z = 0.2;
                let body = SCNPhysicsBody(type: .static, shape: nil);
                body.contactTestBitMask = CollisionTypes.bulletPhysics.rawValue | CollisionTypes.otherPhysics.rawValue
                body.collisionBitMask = CollisionTypes.bulletPhysics.rawValue | CollisionTypes.otherPhysics.rawValue
                body.categoryBitMask = CollisionTypes.invaderPhysics.rawValue
                ship.physicsBody = body
                ship.physicsBody?.isAffectedByGravity = false;
                let rand = CGFloat(Float.random(in: -0.2...0.2))
                self.animation.animateObjectsInSpace(node: ship, rand: rand)
                self.animation.animateObjectsInSpace(node: ship, rand: -rand)
                self.sceneView.scene.rootNode.addChildNode(ship)
            }
        }
    }
}
