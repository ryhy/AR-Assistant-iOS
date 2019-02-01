//
//  Assistant.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/30.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation


class Assistant {
    
    var phrases = ["宇宙人が出現した、撃ち落とすのだ。"]
    
    init() { }
    
    private func getRandomComment() -> String? {
        return ["その調子だ", "いいぞ！！", "よくやった．", "その調子だ！","さすが！"].randomElement()
    }
    
    private func teachCommand() -> String? {
        return [
            "仲間が必要であれば、本部に連絡をしてくれ。",
            "相手の動きを10秒だけ止めることができる。ただし、一回のみだ",
            "ミサイルがなくなったら、連絡をするのだ"
            ].randomElement()
    }
    
    func add(completion: @escaping (() -> Void)) {
        guard let comment = self.getRandomComment() else {return}
        guard let command = self.teachCommand() else {return}
//        guard let text = [comment, command].randomElement() else {return}
        self.phrases.append(comment)
        self.phrases.append(command)
        completion()
    }
    
    func say(text: String) {
        self.phrases.append(text)
    }
    
    func updateDisplay(leftBullet: Int) {
        switch leftBullet {
        case 0...5 :
            self.say(text: ["連絡の準備ができたか？", "ミサイルを補充する連絡が取れるように", "連絡が取れるように", "連絡とる準備を!"].shuffled().first!)
        case 15...20:
            self.say(text: ["残りのミサイルが少ない！", "慎重に使うように"].shuffled().first!)
        case 21...30:
            self.say(text: ["落ち着いて倒せば大丈夫だ"].shuffled().first!)
        default: break
        }
    }

}
