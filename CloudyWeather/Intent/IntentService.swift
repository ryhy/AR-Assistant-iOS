//
//  Intent.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/28.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import FirebaseFirestore

class IntentService: DB {
    
    private var intentname: String;
    private var reference: CollectionReference? = nil;
    
    init(intentname: String) {
        self.intentname = intentname
        super.init()
        self.reference = self.root(name: intentname)
    }
    
    
    func setSingleStateListener(completion: @escaping ([String: Any]) -> Void) {
        self.getUserID { (userid) in
            self.reference?.document(userid).addSnapshotListener { documentSnapshot, error in
                guard let doc = documentSnapshot else {
                    print("Error fetching documents: \(error!)");
                    return;
                }
                guard let data = doc.data() else { return }
                print("@@@@@@@@@@@ ", data, " @@@@@@@@@@@")
                completion(data)
            }
        }
    }
    
    
    func stopListening() {
        self.getUserID { (userid) in
            let ref = self.reference?.document(userid).addSnapshotListener { querySnapshot, error in}
            ref?.remove()
        }
    }
    
    
    func write(collection: String? = nil, value: [String: Any],
               completion: ((Error?) -> Void)?) {
        self.getUserID { (userid) in
            if let collectionName = collection {
                print("collection name");
                self.reference?.document(userid).collection(collectionName).document().setData(value, completion: completion)
            } else {
                print("collection does not exist");
                self.reference?.document(userid).setData(value, completion: completion);
            }
        }
    }
    
    // User IDに紐付くデータを取得する関数
    
    func singlefetch(completion: @escaping ((DocumentSnapshot?) -> Void)) {
        self.getUserID { (userid) in
            self.reference?.document(userid).getDocument(completion: { (snapshot, error) in
                guard let err = error else { return }
                print(err.localizedDescription)
                completion(snapshot)
            })
        }
    }
    
    // User IDの配下にCollectionを指定、その中のドキュメントを全て取得する。
    
    private func multiplefetch(collection: String? = nil, completion: @escaping ((QuerySnapshot?) -> Void)) {
        self.getUserID { (userid) in
            if let collectionName = collection {
                self.reference?.document(userid).collection(collectionName).getDocuments(completion: { (snapshot, error) in
                    guard let err = error else { return };
                    print(err.localizedDescription);
                    completion(snapshot);
                });
            }
        }
    }
    
    func fetchNotAssisted(collection: String? = nil, completion: @escaping (([QueryDocumentSnapshot]?) -> Void)) {
        multiplefetch { (query) in
            let unspoken = query?.documents.filter( { $0.data()["assisted"] as! Bool == false} )
            completion(unspoken);
        }
    }
    
    
    func singleUpdate(collection: String? = nil, value: [String: Any], at itemid: String,
                      completion: ((Error?) -> Void)?) {
        self.getUserID { (userid) in
            if let collectionName = collection {
                print("collection name")
                self.reference?.document(userid).collection(collectionName).document(itemid).setData(value, completion: completion)
            }
        }
    }
    
    
    func delete(collection: String? = nil, itemid: String, value: [String: Any],completion: ((Error?) -> Void)?) {
        self.getUserID { (userid) in
            if let collectionName = collection {
                print("collection name")
                self.reference?.document(userid).collection(collectionName).document(itemid).delete(completion: completion)
            }
        }
    }
    
    func affectedFromGH(value: [String: Any], completion: ((Error?) -> Void)?) {
        self.getUserID { (userid) in
            print("collection name")
            self.reference?.document(userid).setData(value)
        }
    }
}
