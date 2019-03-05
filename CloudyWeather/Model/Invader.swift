//
//  Invader.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/11.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import ARKit

class Invader: SCNNode {
    
    let controlNode = SCNNode()
    
    init(with points: [CGPoint]) {
        super.init()
        
        self.addChildNode(controlNode)
        points.forEach { (point) in
            let sphere = self.createSpaceship()!
            sphere.scale.x = 0.1;
            sphere.scale.y = 0.1;
            sphere.scale.z = 0.1;
            sphere.position = SCNVector3(Float(point.x), 0, Float(point.y))
            controlNode.addChildNode(sphere)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSphere(size: Float) -> SCNNode {
        let sphere = SCNSphere(radius: CGFloat(size))
        sphere.firstMaterial?.diffuse.contents = UIColor.green
        
        let node = SCNNode(geometry: sphere)
        return node
    }
    
    func createSpaceship() -> SCNNode? {
        let rocketship = SCNScene(named: "art.scnassets/ship.scn");
        if let ship = rocketship?.rootNode.childNode(withName: "ship", recursively: true) {
            return ship
        }
        return nil
    }
}
