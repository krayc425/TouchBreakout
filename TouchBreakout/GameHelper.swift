//
//  GameHelper.swift
//  TouchBreakout
//
//  Created by 宋 奎熹 on 2017/11/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import Cocoa

class GameHelper: NSObject {
    
    static let shared: GameHelper = GameHelper()
    
    private override init() {
        
    }

    private let kUserDefaultScoreKey = "best_score_touch_breakout"
    
    func loadBestScore() -> Int {
        return UserDefaults.standard.integer(forKey: kUserDefaultScoreKey)
    }
    
    func setBestScore(score: Int) {
        UserDefaults.standard.set(score, forKey: kUserDefaultScoreKey)
        UserDefaults.standard.synchronize()
    }
    
}
