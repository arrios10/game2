//
//  Helper.swift
//  Game2
//
//  Created by Andrew Rios on 7/20/23.
//

import Foundation
import UIKit


class Helper : NSObject {
    
    func randomBetweenTwoNumbers(firstNumber : CGFloat ,  secondNumber : CGFloat) -> CGFloat{
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
}

class Settings {
    static let sharedInstance = Settings()
    
    private init() {}
    
    private let highScoreKey = "highScore"
    private let playedTodayKey = "playedToday"
    private let lastPlayedDateKey = "lastPlayedDate"

    
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }
    
    var playedToday: Bool {
        get { UserDefaults.standard.bool(forKey: playedTodayKey) }
        set { UserDefaults.standard.set(newValue, forKey: playedTodayKey) }
    }
    
    //save the last played date
    func saveLastPlayedDate(_ date: String) {
        UserDefaults.standard.set(date, forKey: lastPlayedDateKey)
    }
    
    //get the last played date
    func getLastPlayedDate() -> String? {
        return UserDefaults.standard.string(forKey: lastPlayedDateKey)
    }
}
