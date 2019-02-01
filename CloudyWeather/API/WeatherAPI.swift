//
//  WeatherAPI.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/21.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase


class WeatherAPI {
    
    let db: Firestore!
    
    init() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    func get(userid: String, completion: @escaping ([String: Any]) -> Void) {
        
        self.db.collection("weather").document(userid).getDocument { (snapshot, error) in
            guard let data = snapshot?.data() else {
                return
            }
            
            completion(data)
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
            completion(data["userid"]);
        }
    }
    
}
