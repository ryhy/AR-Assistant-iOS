//
//  extension.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/09.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import UIKit
import ARKit

extension ARSCNView {
    
    
    func configureSession() {
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal;
            self.session.run(configuration);
        } else {
            let configuration = AROrientationTrackingConfiguration();
            self.session.run(configuration);
        }
    }
    
}


extension UITableView {
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let row = self.numberOfRows(inSection:  self.numberOfSections - 1) - 1;
            let section = self.numberOfSections - 1;
            let indexPath = IndexPath(row: row, section: section);
            self.scrollToRow(at: indexPath, at: .bottom, animated: true);
        }
    }
    
    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}

extension UITableViewCell {
    
    func config() {
        self.textLabel?.backgroundColor = .clear
        self.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        self.textLabel?.textColor = UIColor.white
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        self.textLabel?.backgroundColor = .clear
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.contentView.backgroundColor = UIColor.clear
    }
    
    func transperant() {
        self.textLabel?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        self.textLabel?.backgroundColor = .clear
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.contentView.backgroundColor = UIColor.clear
    }
}



extension UILabel {
    
    func toUnderline() {
        let textRange = NSMakeRange(0, self.text?.count ?? 0)
        let attributedText = NSMutableAttributedString(string: self.text!)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        self.attributedText = attributedText
    }
}


extension UIView {
    
    
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 3.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}


extension UIViewController {

    
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    func created() -> UIViewController {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let className = String(describing: type(of: self));
        let vc = sb.instantiateViewController(withIdentifier: className)
        return vc
    }
    
    func addGesture(lhs_selector: Selector?, rhs_selector: Selector?) {
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: lhs_selector);
        leftSwipe.direction = .left;
        self.view.addGestureRecognizer(leftSwipe);
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: rhs_selector);
        rightSwipe.direction = .right;
        self.view.addGestureRecognizer(rightSwipe);
    }
    
    
}
