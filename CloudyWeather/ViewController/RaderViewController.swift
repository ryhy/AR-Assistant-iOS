//
//  RaderViewController.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/23.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import UIKit
import HGRippleRadarView

class RaderViewController: UIViewController {
    
    @IBOutlet var raderView: RadarView!
    
    var timer: Timer?
    
    @IBOutlet weak var searchLabel: UILabel! {
        didSet {
            
        }
    }
    
    let aliens = [
        Aliens(title: "A", color: .blue),
        Aliens(title: "A", color: .lightGray),
        Aliens(title: "A", color: .lightGray),
        Aliens(title: "boss", color: .darkGray),
        Aliens(title: "A", color: .yellow)
    ] as [Aliens]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.animateLabel()
//        let items = aliens.map { Item(uniqueKey: $0.title, value: $0) }
        raderView.delegate = self
        raderView.diskRadius = 10.0
        raderView.diskColor = UIColor.white
//        raderView.add(items: items)
        raderView.itemBackgroundColor = .lightGray

        self.view.backgroundColor = .black
        
        let duration = Double(floatBetween(5, and: 15))
        
        timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(1),
            target: self, selector: #selector(openAR),
            userInfo: nil, repeats: false
        )
    }
    
    func animateLabel() {
        searchLabel.fadeIn(duration: 1.5, delay: 0.1) { (_) in
            self.searchLabel.fadeOut(duration: 1.5, delay: 0.1) { (_) in
                self.animateLabel()
            }
        }
    }
    
    @objc func openAR() {
        popAlert(to: self, title: "宇宙人発見", message: "", actionTitle: "了解") {
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let raderVC = sb.instantiateViewController(withIdentifier: "ar") as! ViewController
            self.present(raderVC, animated: true) {
                print("presented AR VC");
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    private func enlarge(view: UIView?) {
        let animation = Animation.transform(from: 1.0, to: 1.5)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        view?.layer.add(animation, forKey: "transform")
    }
    
    private func reduce(view: UIView?) {
        let animation = Animation.transform(from: 1.5, to: 1.0)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        view?.layer.add(animation, forKey: "transform")
    }

    
    private func hideAnimalView(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            completion?()
        }
    }
}

extension RaderViewController: RadarViewDataSource {
    
    func radarView(radarView: RadarView, viewFor item: Item, preferredSize: CGSize) -> UIView {
//        let animal = item.value as? Animal
//        let frame = CGRect(x: 0, y: 0, width: preferredSize.width, height: preferredSize.height)
//        let imageView = UIImageView(frame: frame)
//
//        guard let imageName = animal?.imageName else { return imageView }
//        let image =  UIImage(named: imageName)
//        imageView.image = image
//        imageView.contentMode = .scaleAspectFill
        return UIView()
    }
}

extension RaderViewController: RadarViewDelegate {
    
    func radarView(radarView: RadarView, didSelect item: Item) {
        let view = radarView.view(for: item)
        enlarge(view: view)
    }
    
    func radarView(radarView: RadarView, didDeselect item: Item) {
        let view = radarView.view(for: item)
        reduce(view: view)
    }
    
    func radarView(radarView: RadarView, didDeselectAllItems lastSelectedItem: Item) {
        let view = radarView.view(for: lastSelectedItem)
        reduce(view: view)
        hideAnimalView()
    }
}
