//
//  Utils.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/09.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit
import ARKit
import AVFoundation

class Utils {
    
    static func showProgress() {
        SVProgressHUD.show()
    }
    
    static func dismissProgress() {
        SVProgressHUD.dismiss()
    }
    
}

func playSound(name: String, ext: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
        print("File loading error")
        return
    }
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
        let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
        /* iOS 10 and earlier require the following line:
         player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
        player.play()
    } catch let error {
        print(error.localizedDescription)
    }
}


//let kCustomURLScheme = "HIT THE HIDDEN://"
let kCustomURLScheme = "googleassistant://"

func openGoogleAssistant() {
    if let url = URL(string: kCustomURLScheme) {
        print("hi")
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            print("ya you opened!")
        } else {
            print("Can't open your app")
        }
        
    } else {
        print("yo")
    }
}


func popAlert(to: UIViewController, title: String, message: String?, actionTitle: String = "了解", callback: @escaping (() -> Void)) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
    let ok = UIAlertAction(title: actionTitle, style: .default) { (_) in
        callback()
    }
    alert.addAction(ok)
    to.present(alert, animated: true, completion: nil)
}

func popAlert(to: UIViewController, title: String, message: String?, callback: @escaping (() -> Void)) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
    let home = UIAlertAction(title: "Google Home", style: .default) { (_) in
    }
    let assistant = UIAlertAction(title: "Google Assistantアプリ", style: .default) { (_) in
        callback()
    }
    alert.addAction(assistant)
    alert.addAction(home)
    to.present(alert, animated: true, completion: nil)
}

func floatBetween(_ first: Float,  and second: Float) -> Float {
    return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
}

protocol PointGenerator {
    mutating func generatePoints(numPoints: Int, maxWidth: Float, maxLength: Float) -> [CGPoint]
}

struct VogelPointGenerator: PointGenerator {
    mutating func generatePoints(numPoints: Int, maxWidth: Float, maxLength: Float) -> [CGPoint] {
        var points = [CGPoint]()
        let cc: Float = 0.0
        
        let it: Float = 0.1
        for p in 0..<numPoints {
            // Calculating polar coordinates theta (t) and radius (r)
            let t = it * Float(p)
            let r: Float = sqrtf( Float(p) / Float(numPoints))
            // Converting to the Cartesian coordinates x, y
            let x = r * cosf(t) + cc
            let y = r * sinf(t) + cc
            
            let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
            points.append(point)
        }
        
        return points
    }
}
//struct RandomPointGenerator: PointGenerator {
//    mutating func generatePoints(numPoints: Int, maxWidth: Float, maxLength: Float) -> [CGPoint] {
//        var points = [CGPoint]()
//
//        for _ in 0..<numPoints {
//            let a = Float.
//            let x = Float.random(min: -maxWidth/2, max: maxWidth/2)
//            let y = Float.random(min: -maxLength/2, max: maxLength/2)
//
//            let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
//            points.append(point)
//        }
//
//        return points
//    }
//}
//
//
//struct MitchellPointGenerator: PointGenerator {
//    var radius: Float = 0.3
//    let pos: SCNVector3 = SCNVector3Zero
//    var points = [CGPoint]()
//    var width: Float = 4
//    var height: Float = 4
//
//    mutating func generatePoints(numPoints: Int, maxWidth: Float, maxLength: Float) -> [CGPoint] {
//        self.width = maxWidth
//        self.height = maxLength
//
//        for _ in 0..<numPoints {
//
//            let pointSample = sample(anchorPos: CGPoint(x: CGFloat(pos.x), y: CGFloat(pos.z)))
//            points.append(pointSample)
//        }
//
//        return points
//
//    }
//
//    func sample(anchorPos: CGPoint) -> CGPoint {
//        var bestCandidate: CGPoint = CGPoint(x: 0, y: 0)
//        var bestDistance: Float = 0
//        let numCandidates = 20
//        let anchorX = Float(anchorPos.x)
//        let anchorZ = Float(anchorPos.y)
//        for _ in 0..<numCandidates {
//            let xVal = CGFloat(Float.random(min: anchorX - radius, max: anchorX + radius) * width)
//            let zVal = CGFloat(Float.random(min: anchorZ - radius, max: anchorZ + radius) * height)
//            let c = CGPoint(x: xVal, y: zVal)
//            let d = distance(a: findClosest(pool: points, point: c), b: c)
//            if (d > bestDistance) {
//                bestDistance = d;
//                bestCandidate = c;
//            }
//        }
//        return bestCandidate;
//    }
//
//    func findClosest(pool: [CGPoint], point: CGPoint) -> CGPoint {
//        var currentClosest = point
//
//        var minDistance = Float.infinity
//        for aPointInPool in pool {
//            let dist = distance(a: aPointInPool, b: point)
//            if dist < minDistance {
//                currentClosest = aPointInPool
//                minDistance = dist
//            }
//        }
//
//        return currentClosest
//    }
//
//    func distance(a: CGPoint, b: CGPoint) -> Float {
//        let dx = a.x - b.x
//        let dy = a.y - b.y
//        return Float((dx * dx + dy * dy).squareRoot())
//    }
//}
