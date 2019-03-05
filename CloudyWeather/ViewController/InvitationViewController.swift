//
//  InvitationViewController.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/09.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//


import UIKit
import FirebaseAuth
import FirebaseFirestore

class InvitationViewController: UIViewController {

    var server: Register!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var invitationCard: UIView! {
        didSet {
            invitationCard.dropShadow(color: .lightGray,
                                      opacity: 1, offSet: CGSize(width: -1, height: 1),
                                      radius: 3, scale: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        server = Register.init()
    }
    
    @IBAction func completePressed(_ sender: UIButton) {
        
        Utils.showProgress()

        guard let emailtext = self.email.text else { return }

        server.search(by: emailtext) { (status) in
            Utils.dismissProgress()
            print(status)
            if (status) {
                self.issueID()
            } else {
                self.createAlert()
            }
        }
    }
    
    func issueID() {
        guard let emailtext = self.email.text else { return }
        server.issueID { (uniqueID) in
            self.server.updateUser(email: emailtext, id: "member\(uniqueID)")
            self.loginUser(id: uniqueID)
            print("ユーザーの準備完了");
        }
    }

    func moveToARVC() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ar") as! ViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func createAlert() {
        let alert = UIAlertController(title: "エラー", message: "メールアドレスが見つかりませんでした。Google HomeあまたはGoogle Assistantで先にログインをしてください。", preferredStyle: .alert)
        let action = UIAlertAction(title: "了解", style: .default) { ( _ ) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    func loginUser(id: Int) {
        
        let yourid =  "member\(id)"
        
        guard let emailtext = self.email.text else { return }
        
        let alert = UIAlertController(title: "\(yourid)(あなたのID番号)で、ログインをします。", message: "ID番号を忘れないように。", preferredStyle: .alert);
        let action = UIAlertAction(title: "了解", style: .default) { ( _ ) in
            Utils.showProgress();
            Auth.auth().createUser(withEmail: emailtext, password: yourid, completion: { (result, err) in
                if (err != nil) {
                    Utils.dismissProgress()
                    print("ログインエラー", err?.localizedDescription);
                    self.createAlert()
                    return
                }
                print("ログイン成功");
                Utils.dismissProgress();
                self.server.makePathUID(email: emailtext, id: yourid);
                self.moveToARVC();
            })
        }
        alert.addAction(action);
        self.present(alert, animated: true, completion: nil);
    }

}



