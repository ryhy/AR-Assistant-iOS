//
//  ViewController.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/09.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import CoreImage
import HGRippleRadarView

// TODO: 継続的にアプリを開いてもらうために、工夫するべきこと：

// - ミサイルタイプ - ミサイル(弾の大きさ)、ボム、追跡型　→ shop 機能。
// - 応援を呼ぶことができる　スペースシップオブジェクトから球が発射され、宇宙人を一緒に撃退する。
// - 自動的に動いてくれるアルゴリズムを作成。
// - スコア化してユーザーのランク付けを行う。倒した宇宙人の数を記録する。
// - レアキャラが突如出てくる、それを倒すことが目的。
// - 1000 分の１でボスを倒すことができる。ボスが出たら通知が行くようにする。
// - ボスを倒したら、ユーザー（ニックネーム）をTwitterアカウントに掲載される。
// - ゲームオーバーはない、時間が経ちすぎると、敵が増える。
// - 本物天気データに合わせる。


enum Particles: String {
    
    case bokeh
    case confetti
    case fire
    case rain
    case reactor
    case smoke
    case stars
    
    static var order: [Particles] = [
        .bokeh,
        .confetti,
        .fire,
        .rain,
        .reactor,
        .smoke,
        .stars
    ]
}


class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var weatherForcastLabel: UILabel! {
        didSet {
            weatherForcastLabel.text = "天気予報取得中..."
            weatherForcastLabel.toUnderline()
        }
    }

    
    @IBOutlet var sceneView: ARSCNView! {
        didSet {

        }
    }
    
    @IBOutlet weak var bulletNumber: UILabel! {
        didSet {
            bulletNumber.text = "x \(bullet)";
        }
    }
    
    @IBOutlet weak var shootButton: UIButton! {
        didSet {
            shootButton.layer.cornerRadius = shootButton.frame.width/2;
            shootButton.layer.borderWidth = 0;
        }
    }
    
    @IBOutlet weak var weatherLabel: UILabel! {
        didSet {
            weatherForcastLabel.layer.masksToBounds = true
            weatherForcastLabel.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var enemyLabel: UILabel! {
        didSet {
            enemyLabel.text = ""
        }
    }
    
    var killNum = 0;
    @IBOutlet weak var killScore: UILabel! {
        didSet {
            killScore.text = "\(self.killNum)"
        }
    }
    
    @IBOutlet weak var raderView: RadarView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = .clear
            tableView.delegate = self
            tableView.dataSource = self
            tableView.isHidden = true
        }
    }
    
    var items = [Item]()
    
    let assistant = Assistant.init()
    
    var timer: Timer? = nil;
    var invaderService: InvaderService!
    var weatherAPI: WeatherAPI!
    var bullet = 20;
    var leftAliens = 0;
    
    let animationService = AnimationService.init();
    var arservice: ARService!;
    
    private var selectedParticle: Particles = .fire
    private var currentParticleNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self;
        sceneView.scene.physicsWorld.contactDelegate = self;
//        timerStart();
        initializeAR();
        startListeningToServer();
    }
    
    private func initializeAR() {
        arservice = ARService(sceneView: self.sceneView);
        invaderService = InvaderService.init();
        invaderService.fetchScore { (score) in
            DispatchQueue.main.async {
                self.killNum = score
                self.killScore.text = "\(self.killNum)"
            }
        }
        
        weatherAPI = WeatherAPI.init();
        invaderService.updateBulletNumber(runout: false);
        
        self.addGesture(
            lhs_selector: #selector(self.leftSwiped(sender:)),
            rhs_selector: #selector(self.rightSwiped(sender:))
        )
    }
    
    private func initializeRaderView(alienNumber: Int) {
        var alienBox = [Aliens]();
        for i in 0...alienNumber {
            let alien = Aliens(title: "ship_\(i)", color: .lightGray);
            alienBox.append(alien);
        }
        items = alienBox.map { Item(uniqueKey: $0.title, value: $0) };
        self.raderView.add(items: items)
    }
    
    @objc func leftSwiped(sender: UISwipeGestureRecognizer) {
        print("left swiped!");
        let sb = UIStoryboard.init(name: "Main", bundle: nil);
        let shopViewController = sb.instantiateViewController(withIdentifier: "shop") as! ShopViewController;
        shopViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        let nav = UINavigationController(rootViewController: shopViewController);
        shopViewController.bombDelegate = self
        self.present(nav, animated: true) {
            print("presented Shop VC");
        }
    }
    
    @objc func rightSwiped(sender: UISwipeGestureRecognizer) {
        print("right swiped!")
        
        let childs = self.sceneView.scene.rootNode.childNodes.filter {$0.name == "bomb"}
        childs.forEach({ (node) in
            node.removeFromParentNode()
            self.addParticle(self.selectedParticle, to: childs)
            self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.explodeit), userInfo: nil, repeats: false)
            print("バイバイ、ぼむ")
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        print("viewWillAppear");
        updateBullet()
        sceneView.configureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        
        displayWeather();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        print("viewWillDisappear")
        sceneView.session.pause()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        print("viewDidDisappear")
    }
    
    private func addParticle(_ particle: Particles, to nodes: [SCNNode]){
        currentParticleNode?.removeFromParentNode()
        
        let particle = SCNParticleSystem.init(named: particle.rawValue + ".scnp", inDirectory: "art.scnassets")
        let particleNode = SCNNode()
        particleNode.name = "fire"
        particleNode.addParticleSystem(particle!)
        particleNode.scale = SCNVector3Make(1.5, 1.5, 1.5)
        nodes.forEach { (node) in
            particleNode.position = node.position
        }
        
        sceneView.scene.rootNode.addChildNode(particleNode)
        
        currentParticleNode = particleNode
        
    }
    
}

extension ViewController {
    
    // Firestoreの変更をリッスンする
    
    private func startListeningToServer() {
        
        IntentManager.shared.SpaceStopIntent.setSingleStateListener { (dict) in
            print("SpaceStopIntent in lisening vc");
            print(dict);
            let stopped = dict["stopped"] as! Bool
            if stopped {
                print("All Aliens in total: ", self.getAllAliens().count);
                self.getAllAliens().forEach({ (alien) in
                    alien.removeAction(forKey: "moving");
                });
                self.assistant.say(text: "10秒後に動き始める、その前に倒すのだ。")
                self.updateTableView()
                
                Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.startMoving), userInfo: nil, repeats: false);
                IntentManager.shared.SpaceStopIntent.affectedFromGH(value: ["stopped": false], completion: { (err) in
                    print(err?.localizedDescription ?? "err")
                })
            }
        }
        
        IntentManager.shared.AircraftIntent.setSingleStateListener { (dict) in
            print("AircraftIntent in lisening vc");
            print(dict);
            let sent = dict["sent"] as! Bool
            if (sent) {
                for _ in 0...5 {
                    BubbleMissile.add(sceneView: self.sceneView);
                }
                self.assistant.say(text: "応援を出動させた、共に戦ってくれ。")
                self.updateTableView()
                
                IntentManager.shared.AircraftIntent.affectedFromGH(value: ["sent": false], completion: { (err) in
                    print(err?.localizedDescription ?? "err")
                })
            }
        }
        
        IntentManager.shared.MoreBulletIntent.setSingleStateListener { (dict) in
            print("MoreBulletIntent in lisening vc");
            DispatchQueue.main.async {
                self.bullet = dict["bullet"] as! Int;
                self.bulletNumber.text = "x \(self.bullet)";
                self.shootButton.isEnabled = true;
            }
            print(dict);
        }
        
        IntentManager.shared.ExplodeBombIntent.setSingleStateListener { (dict) in
            let state = dict["state"] as! Bool
            let childs = self.sceneView.scene.rootNode.childNodes.filter {$0.name == "bomb"}
            if childs.count > 0 {
                if state {
                    childs.forEach({ (node) in
                        node.removeFromParentNode()
                        self.addParticle(self.selectedParticle, to: childs)
                        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.explodeit), userInfo: nil, repeats: false)
                        print("バイバイ、ぼむ")
                    })
                    IntentManager.shared.ExplodeBombIntent.affectedFromGH(value: ["state": false], completion: { (err) in
                        print(err?.localizedDescription ?? "err")
                    })
                }
            }
        }
        
        IntentManager.shared.OtherWeaponsIntent.setSingleStateListener { (dict) in
            print("OtherWeaponsIntent in lisening vc");
            print(dict);
            let canChange = dict["canChange"] as! Bool;
            if canChange {
                let sb = UIStoryboard.init(name: "Main", bundle: nil);
                let shopViewController = sb.instantiateViewController(withIdentifier: "shop") as! ShopViewController;
                let nav = UINavigationController(rootViewController: shopViewController);
//                shopViewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                shopViewController.bombDelegate = self
                self.present(nav, animated: true) {
                    print("presented Shop VC");
                }
                
                IntentManager.shared.OtherWeaponsIntent.affectedFromGH(value: ["canChange": false], completion: { (err) in
                    print(err?.localizedDescription ?? "err")
                });
            }
        }
        
        IntentManager.shared.RemoveInvaderIntent.setSingleStateListener { (dict) in
            print("RemoveInvaderIntent in lisening vc");
            print(dict);
            self.removeEnemyFromRader(nodes: self.getAllAliens())
        }
    }
    
    @objc func startMoving() {
        self.getAllAliens().forEach { (ship) in
            let rand = CGFloat(Float.random(in: -0.2...0.2))
            self.animationService.animateObjectsInSpace(node: ship, rand: rand);
            self.animationService.animateObjectsInSpace(node: ship, rand: -rand)
        }
    }
    
    // GAME INIT 関数
    
    private func updateBullet() {
        invaderService.getBullet { (dict) in
            DispatchQueue.main.async {
                self.aliensFoundAlert(bulletnum: dict)
            }
        }
    }
    
    private func displayWeather() {
//        Utils.showProgress();
        weatherAPI.getUserID { (userid) in
            self.weatherAPI.get(userid: userid as! String, completion: { (dictionary) in
                let loc = dictionary["location"] as! String
                let condition = dictionary["condition"] as! String
                let temp = dictionary["temp"] as! Int
                DispatchQueue.main.async {
//                    Utils.dismissProgress()
                    self.weatherForcastLabel.text = "\(loc) - \(condition) - \(temp)℃"
                    self.weatherForcastLabel.sizeToFit()
                    self.weatherForcastLabel.toUnderline()
                }
            })
        }
    }
    
    
    func cantsee() {
        
    }
    
}


// 接触等の判定

extension ViewController: SCNPhysicsContactDelegate {
    

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.arservice.detectRunaway() {
            print("宇宙人が撤退した。")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }

    func embedAnimation(to nodes: [SCNNode]) {
        
        nodes.forEach { (node) in
            self.animationService.addHitAnimation(node, from: self.sceneView)
        }
        self.invaderService.killedInvader();

    }
    
    func removeEnemyFromRader(nodes: [SCNNode]) {
        let names = nodes.map({ return $0.name! })
        names.forEach { (name) in print(name) }
        let key = names.filter({ $0.components(separatedBy: "_").first == "ship" }).first!
        let removeItem = self.items.filter({ $0.uniqueKey == key }).first!
        print(removeItem.uniqueKey, removeItem.value, key)
        DispatchQueue.main.async {
            if self.leftAliens == 0 {
                print("You killed all aliens.")
            } else {
                self.raderView.remove(item: removeItem)
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        print("Begin contact!!", contact.nodeA.name!, contact.nodeB.name!);
        
        let firstNode = contact.nodeA;
        let secondNode = contact.nodeB;
        
        if firstNode.physicsBody?.categoryBitMask == CollisionTypes.bulletPhysics.rawValue
            || secondNode.physicsBody?.categoryBitMask == CollisionTypes.invaderPhysics.rawValue
            && firstNode.physicsBody?.categoryBitMask == CollisionTypes.invaderPhysics.rawValue
            || secondNode.physicsBody?.categoryBitMask == CollisionTypes.bulletPhysics.rawValue
            
            && firstNode.physicsBody?.categoryBitMask == CollisionTypes.invaderPhysics.rawValue
            || secondNode.physicsBody?.categoryBitMask == CollisionTypes.bombPhysics.rawValue
            && firstNode.physicsBody?.categoryBitMask == CollisionTypes.bombPhysics.rawValue
            || secondNode.physicsBody?.categoryBitMask == CollisionTypes.invaderPhysics.rawValue
        
        {
            
            if (contact.nodeA.name!.components(separatedBy: "_").first! == "ship"
                || contact.nodeB.name!.components(separatedBy: "_").first! == "ship") {
                
                print("Ship hit");
                
                let nodes =  [contact.nodeA, contact.nodeB]
                embedAnimation(to: nodes)
                removeEnemyFromRader(nodes: nodes)
                assistant.add {
                    self.updateTableView()
                }
                
                DispatchQueue.main.async {
                    self.killNum += 1
                    self.killScore.text = "\(self.killNum)"
                }
                
            }else{
                print("bullet hit");
            }
            
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode();
                contact.nodeB.removeFromParentNode();
                print("Deleted!!!");
            }
            
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("didFailWithError")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("sessionWasInterrupted!");
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("sessionInterruptionEnded!");
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("didEnd contact");
    }
    
    
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        let filter:CIFilter=CIFilter(name:"CIColorInvert")!
//        let image = CIImage(cvPixelBuffer: frame.capturedImage)
//        filter.setValue(image, forKey: kCIInputImageKey)
//        let context = CIContext()
//        if let result = filter.outputImage,
//            let cgImage = context.createCGImage(result, from: result.extent) {
//            sceneView.scene.background.contents = cgImage
//            if let transform = currentScreenTransform() {
//                sceneView.scene.background.contentsTransform = transform
//            }
//        }
//    }
//
//    private func currentScreenTransform() -> SCNMatrix4? {
//        switch UIDevice.current.orientation {
//        case .landscapeLeft:
//            return SCNMatrix4Identity
//        case .landscapeRight:
//            return SCNMatrix4MakeRotation(.pi, 0, 0, 1)
//        case .portrait:
//            return SCNMatrix4MakeRotation(.pi / 2, 0, 0, 1)
//        case .portraitUpsideDown:
//            return SCNMatrix4MakeRotation(-.pi / 2, 0, 0, 1)
//        default:
//            return nil
//        }
//    }
}

// ゲームタイマー

extension ViewController {
    
//    func timerStart() {
//        timer = Timer.scheduledTimer(timeInterval: 20,
//                                     target: self, selector: #selector(self.timerUpdate),
//                                     userInfo: nil, repeats: true)
//    }

    @objc func explodeit() {
        self.currentParticleNode?.removeFromParentNode()
    }


}

// ミサイルを撃つ時の処理

extension ViewController {

    
    @IBAction func shootPressed(_ sender: UIButton) {
        
        
        
        self.updateTableView()
        
        if (self.bullet == 0) {
            DispatchQueue.main.async {
                self.invaderService.updateBulletNumber(runout: true);
            }
            popAlert(to: self, title: "ミサイルが切れた", message: "Google HomeまたはGoogle Assistantアプリで「宇宙人撃退本部につないで」と言うと連絡が取れる。") {
                print("call back");
                openGoogleAssistant();
            }
            return;
        }
//        BubbleMissile.add(sceneView: self.sceneView);
        self.arservice.addBullet();
        self.bullet = self.bullet - 1;
        self.bulletNumber.text = "x \(self.bullet)"
        self.animationService.bounceButton(sender: sender);
    }

}

// ゲームロジック等

extension ViewController {
    
    
    func getAllAliens() -> [SCNNode] {
        return self.sceneView.scene.rootNode.childNodes.filter({$0.name?.components(separatedBy: "_").first! == "ship"})
    }
    
    func allAliensDied() -> Bool {
        return getAllAliens().count == 0;
    }
    
    func endGame() {
        if (allAliensDied()) {
            print("all eliens died");
        } else {
            print("not died");
        }
    }
    
}


// アラート系

extension ViewController {
    
   
    func aliensFoundAlert(bulletnum: [String:Any]) {
        DispatchQueue.main.async {
            self.invaderService.fetchNumber { (data) in
                self.leftAliens = data;
                if (self.leftAliens > 0) {
                    self.arservice.createShips(number: self.leftAliens);
                    self.bullet = bulletnum["bullet"] as! Int;
                    self.bulletNumber.text = "x \(self.bullet)"
                    self.shootButton.isEnabled = true;
                    self.initializeRaderView(alienNumber: self.leftAliens);
                }
//                } else {
//                    self.arservice.createShips(number: 5);
//                    self.initializeRaderView(alienNumber: 5);
//                }
            }
        }
//        popAlert(to: self, title: "エイリアン出現", message: nil, actionTitle: "了解") {
//
//        }
    }
    
    func restartThisGame() {
        popAlert(to: self, title: "注意", message: nil) {
            self.arservice.createShips(number: 20)
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            let indexPath = IndexPath(row: self.assistant.phrases.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assistant.phrases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "monitor", for: indexPath)
        cell.config();
        DispatchQueue.main.async {
            cell.textLabel?.text = self.assistant.phrases[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 18
    }
    
}



extension ViewController : BombDelegate {
    
    func place() {
        let arservice = ARService(sceneView: self.sceneView)
        arservice.addBomb()
        self.dismiss(animated: true, completion: nil)
    }
    
}
