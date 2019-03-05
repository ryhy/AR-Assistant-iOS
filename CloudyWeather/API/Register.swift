//
//  Register.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/09.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase


class Register {
    
    let db: Firestore!
    
    init() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    func search(by email: String, completion: @escaping ((Bool) -> Void)) {
        print("検索ちゅう")
        db.collection("members").getDocuments { (snapshot, error) in
            if (error != nil) {
                print("エラー発見")
            }
            guard let documents = snapshot?.documents else { return }
            if documents.count >= 1 {
                print("メンバー探索をは開始します。");
                let flag = documents.filter({ (document) -> Bool in
                    return document.data()["email"] as! String == email
                }).count > 0 ? true : false
                completion(flag)
            }
        }
    }
    
    func issueID(completion: @escaping ((Int) -> Void)) {
        print("ID発行")
        db.collection("members").getDocuments { (snapshot, error) in
            
            if (error != nil) {
                print("エラー発見")
            }
            
            print("b")
            guard let documents = snapshot?.documents else { return }
            
            if documents.count >= 1 {
                completion(documents.count)
                print("a")
            }
        }
    }
    
    func updateUser(email: String, id: String) {
        print("アップデート")
        db.collection("members").getDocuments { (snapshot, error) in
            if (error != nil) {
                print("エラー発見")
            }
            guard let documents = snapshot?.documents else { return }
            if documents.count >= 1 {
                print("メンバー探索をは開始します。");
                let user = documents.filter({ (document) -> Bool in
                    return document.data()["email"] as! String == email
                })[0]
                let userid = user.data()["userid"] as! String
                let email = user.data()["email"] as! String
                let done = user.data()["done"] as! Bool
                let name = user.data()["name"] as! String
                let value = ["done": done, "email": email, "userid": userid, "name": name, "id": id] as [String : Any]
                print(value)
                self.db.collection("members").document(userid).setData(value)
            }
        }
    }
    
    func makePathUID(email: String, id: String) {
        print("アップデート")
        db.collection("members").getDocuments { (snapshot, error) in
            if (error != nil) {
                print("エラー発見")
            }
            guard let documents = snapshot?.documents else { return }
            if documents.count >= 1 {
                print("メンバー探索をは開始します。");
                let user = documents.filter({ (document) -> Bool in
                    return document.data()["email"] as! String == email
                })[0]
                let userid = user.data()["userid"] as! String
                let email = user.data()["email"] as! String
                let done = user.data()["done"] as! Bool
                let name = user.data()["name"] as! String
                let value = ["done": done, "email": email, "userid": userid, "name": name, "id": id] as [String : Any]
                
                guard let uniquid = Auth.auth().currentUser?.uid else {return}
                self.db.collection("signed").document(uniquid).setData(value)
            }
        }
    }

}
