//
//  AnimationService.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/21.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import ARKit
import UIKit



class AnimationService {
    
    init() { }
    
    func bounceButton(sender: UIButton) {
        
        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6);
        
        UIView.animate(
            withDuration: 2.0, delay: 0, usingSpringWithDamping: CGFloat(0.20),
            initialSpringVelocity: CGFloat(6.0), options: UIView.AnimationOptions.allowUserInteraction,
            animations: {
                sender.transform = CGAffineTransform.identity
        }, completion: { _ in print("UIButton is bouncing!!")} );
    
        
    }
    
    func addAnimation(node: SCNNode) {
        let a = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: 0, duration: 1)
        let b = SCNAction.rotateBy(x: CGFloat(Float.pi), y: 0, z: 0, duration: 1)
        let c = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(Float.pi), duration: 1)
        let d = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: CGFloat(Float.pi), duration: 1)
        let e = SCNAction.rotateBy(x: CGFloat(Float.pi), y: CGFloat(Float.pi), z: 0, duration: 1)
        let f = SCNAction.rotateBy(x: CGFloat(Float.pi), y: 0, z: CGFloat(Float.pi), duration: 1)
        let g = SCNAction.rotateBy(x: CGFloat(Float.pi), y: CGFloat(Float.pi), z: CGFloat(Float.pi), duration: 1)
        if let random = [a,b,c,d,e,f,g].shuffled().randomElement() {
            let repeatForever = SCNAction.repeatForever(random)
            node.runAction(repeatForever)
        }
    }
    
    func animateObjectsInSpace(node : SCNNode, rand: CGFloat) {
        
        let x = SCNAction.moveBy(x: rand, y: 0, z: 0, duration: 1);
        let y = SCNAction.moveBy(x: 0, y: rand, z: 0.1, duration: 1);
        
        let a = SCNAction.moveBy(x: rand, y: 0, z: 0, duration: 1);
        let b = SCNAction.moveBy(x: rand, y: 0, z: 0.1, duration: 1);
        let c = SCNAction.moveBy(x: rand, y: 0, z: 0.1, duration: 1);
        let d = SCNAction.moveBy(x: rand, y: 0, z: 0, duration: 1);
        let e = SCNAction.moveBy(x: rand, y: 0, z: 0.1, duration: 1);

        let f = SCNAction.group([x, y].shuffled());
        
        let movementTypes = [a, b, c, d, e, f];
        movementTypes.forEach { (action) in action.timingMode = .easeInEaseOut };
        let randomOrderedActions = movementTypes.shuffled();
        let moveSequence = SCNAction.sequence(randomOrderedActions);
        let moveLoopForever = SCNAction.repeatForever(moveSequence);
        node.runAction(moveLoopForever, forKey: "moving");
    }
    
    func reversed() { }
    
    func addHitAnimation(_ node: SCNNode, from sceneView: ARSCNView) {
        if let particleSystem = SCNParticleSystem(named: "smoke.scnp", inDirectory: nil) {
            particleSystem.particleColor = .white
            particleSystem.particleSize = 100
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem)
            systemNode.position = node.position
            print("SMOKE!")
            sceneView.scene.rootNode.addChildNode(systemNode)
        }
    }
}
