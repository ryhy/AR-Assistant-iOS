//
//  GunService.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/22.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import ARKit


class MissileService {
    
    var currentMissileState: TYPE = .smallMissile;
    
    let maxBullet = 50;
    
    
    init() {
        
    }
    
    
    func createObject() -> SCNGeometry? {
        let missile = Missile.init(type: self.currentMissileState)
        return missile.object
    }
    
    func changeMissile(type: TYPE) {
        self.currentMissileState = type
    }
    
    
}
