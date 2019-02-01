//
//  constant.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/11.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation



struct Constants {
    static let maxMeterorNums = 15
}


struct CollisionTypes : OptionSet {
    let rawValue: Int
    static let invaderPhysics  = CollisionTypes(rawValue: 1 << 0)
    static let otherPhysics = CollisionTypes(rawValue: 1 << 1)
    static let bulletPhysics = CollisionTypes(rawValue: 1 << 2)
}

enum SoundEffect: String {
    case explosion = "explosion"
    case collision = "collision"
    case missile = "missile"
    case thruster = "thruster"
    case alert = "alert"
}


enum TYPE {
    case smallMissile
    case mediumMissile
    case largeMissile
    case bomb
}
    

let phrases = ["よし、よくやった", "その調子だ", "いいぞ", "いい当たりた", "いいぞいいぞ、その調子だ"];
let timelimit_phrases = ["死者が増えている", "まだ敵がいるぞ"];
