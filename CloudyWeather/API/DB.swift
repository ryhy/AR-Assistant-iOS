//
//  DB.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/28.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase


class DB {
    
    private let db: Firestore!
    
    init() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    func root(name: String) -> CollectionReference {
        return self.db.collection(name)
    }
    
    func getUserID(completion: @escaping (String) -> Void) {
        guard let id = Auth.auth().currentUser?.uid else {return};
        db.collection("signed").document(id).getDocument { (shot, err) in
            if (err != nil) {
                print(err?.localizedDescription ?? "");
                return;
            }
            guard let data = shot?.data() else {return};
            completion(data["userid"] as! String);
        }
    }
    
}

