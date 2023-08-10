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
    private init(){
        
    }
    
    var highScore = 0
    let highScoreKey = "highScore"
    
    func saveHighScore(_ value: Int) {
        UserDefaults.standard.set(value, forKey: highScoreKey)
        UserDefaults.standard.synchronize()
    }
    
    func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: highScoreKey)
    }
}
