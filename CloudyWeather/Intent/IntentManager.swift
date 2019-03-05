//
//  IntentManager.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/28.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation


class IntentManager {
    
    static let shared = IntentManager()
    
    let SpaceStopIntent = IntentService(intentname: "SpaceStopIntent")
    let RemoveInvaderIntent = IntentService(intentname: "RemoveInvaderIntent")
    let OtherWeaponsIntent = IntentService(intentname: "OtherWeaponsIntent")
    let MoreBulletIntent = IntentService(intentname: "MoreBulletIntent")
    let AircraftIntent = IntentService(intentname: "AircraftIntent")
    let ExplodeBombIntent = IntentService(intentname: "ExplodeBombIntent")
    
    func removeAllListeners() {
        [
            SpaceStopIntent,
            RemoveInvaderIntent,
            OtherWeaponsIntent,
            MoreBulletIntent,
            AircraftIntent
        ].forEach { (intentService) in
            intentService.stopListening()
        }
    }
}







