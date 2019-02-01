//
//  InvaderService.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/11.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase

class InvaderService {
    
    let db: Firestore!
    
    var userid: String = ""
    
    init() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        self.getUserID { (userid) in
            let id = userid as! String
            self.userid = id
        }
    }
    
    func getUserID(completion: @escaping (Any) -> Void) {
        guard let id = Auth.auth().currentUser?.uid else {return};
        db.collection("signed").document(id).getDocument { (shot, err) in
            if (err != nil) {
                print(err?.localizedDescription ?? "");
                return;
            }
            guard let data = shot?.data() else {return};
            print("******************");
            print(data);
            print("******************");
            completion(data["userid"]!);
        }
    }
    
    func fetchScore(completion: @escaping ((Int) -> Void)) {
        self.getUserID { (id) in
            let userid = id as! String
            self.db.collection("score").document(userid).getDocument(completion: { (snapshot, err) in
                if let error = err {
                    print(error.localizedDescription);
                    return
                }
                guard let score = snapshot?.data()?["numbers"] else { return }
                completion(score as! Int);
            })
        }
    }
    
    func fetchNumber(completion: @escaping ((Int) -> Void)) {
        self.getUserID { (userid) in
            self.db.collection("alert").getDocuments(completion: { (shot, err) in
                shot?.documents.forEach({ (shot) in
                    print(shot.data())
                })
            })
            self.db.collection("alert").document(userid as! String).getDocument(completion: { (alert, err) in
                if (err != nil) {
                    print(err?.localizedDescription ?? "")
                    return
                }
                guard let alertd = alert?.data() else {return}
                print(alertd)
                let num = alertd["numbers"] as! Int
                completion(num);
            })
        }
    }
    
    func killedInvader() {
        self.getUserID { (userid) in
            self.db.collection("score").document(userid as! String).getDocument(completion: { (score, err) in
                if (err != nil) {
                    print(err?.localizedDescription ?? "");
                    return;
                }
                guard let userscore = score?.data() else {return};
                let num = userscore["numbers"] as! Int;
                let newNum = num + 1;
                self.db.collection("score").document(userid as! String).setData(["numbers": newNum]);
            });
        }
    }
    
    func getBullet(completion: @escaping ([String: Any]) -> Void) {
        getUserID { (userid) in
            self.db.collection("MoreBulletIntent").document(userid as! String).getDocument(completion: { (snapshot, error) in
                guard let dict = snapshot?.data() else {return}
                let bullet = dict["bullet"] as! Int
                let runout = dict["runout"] as! Bool
                completion(["bullet": bullet, "runout": runout])
            })
        }
    }
    
    func updateBulletNumber(runout: Bool) {
        print("user", self.userid)
        getUserID { (userid) in
            if (runout) {
                print("heiiiiii", userid as! String)
                self.db.collection("MoreBulletIntent").document(userid as! String).setData(["runout": runout, "bullet": 0], completion: { (error) in
                    print(error?.localizedDescription ?? "fuck off", error.debugDescription)
                    print("donnnnnn");
                });
            } else {
                print("yooooooooooooo");
                self.db.collection("MoreBulletIntent").document(userid as! String).setData(["runout": runout, "bullet": 50], completion: { (error) in
                    
                });
            }
        }
    }
    
//    func added() {
//        self.db.collection("hq").document(self.userid).collection("operation").document().setData(["added": true])
//    }
}
