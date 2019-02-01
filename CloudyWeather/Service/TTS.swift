//
//  TTS.swift
//  CloudyWeather
//
//  Created by 新井　崚平 on 2019/01/23.
//  Copyright © 2019年 新井　崚平. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


final class TTS: NSObject {
    
    static let shared = TTS()
    
    var texts = [String]()
    let talker = AVSpeechSynthesizer()
    
    private override init() {
        super.init()
        talker.delegate = self;
    }
    
    func append(text: String) {
        texts.append(text);
        if texts.count == 1 {
            play(text: texts[0])
        }
    }
    
    func clear() {
        texts.removeAll()
        if talker.isSpeaking {
            talker.stopSpeaking(at: .immediate)
        }
    }
    
    private func play(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        talker.speak(utterance)
    }
    
}

extension TTS : AVSpeechSynthesizerDelegate {
    
    // MARK: AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if texts.count > 0 {
            texts.removeFirst()
            if texts.count > 0 {
                play(text: texts[0])
            }
        } else {
            // speech finished
        }
    }
    
}
