//
//  ShopViewController.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/28.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import UIKit

class Shop {
    var title: String
    var image: String
    var description: String
    var purchasable: Bool
    
    init(title: String, image: String, description: String, purchaseable: Bool) {
        self.title = title
        self.image = image
        self.description = description
        self.purchasable = purchaseable
    }
}

struct ProductStore {
    
    static func fetch() -> [Shop] {
        return [
            Shop(title: "ミサイル", image: "missile.png", description: "必要コイン x5", purchaseable: true),
            Shop(title: "爆弾", image: "missile.png", description: "必要コイン x20", purchaseable: true),
            Shop(title: "ストップタイマー", image: "missile.png", description: "必要コイン x50", purchaseable: true),
            Shop(title: "追跡ミサイル", image: "missile.png", description: "必要コイン x100", purchaseable: true),
            Shop(title: "巨大爆弾", image: "missile.png", description: "必要コイン x300", purchaseable: true)
        ]
    }
}

class ShopViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var items = ProductStore.fetch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func closeVC(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension ShopViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopcell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        cell.detailTextLabel?.text = items[indexPath.row].description
        cell.imageView?.image = UIImage(named: items[indexPath.row].image)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}
