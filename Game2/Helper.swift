//
//  Helper.swift
//  Game2
//
//  Created by Andrew Rios on 7/20/23.
//

import Foundation
import UIKit

enum GameMode: String {
    case daily
    case random
}

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
    private let dailyScoresKey = "dailyScores"
    private let gameModeKey = "gameMode"
    
    var soundEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: "soundEnabled") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "soundEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "soundEnabled")
        }
    }
    
    // Retrieve and store a [String: Int] dictionary in UserDefaults
    var dailyScores: [String: Int] {
        get {
            return UserDefaults.standard.dictionary(forKey: dailyScoresKey) as? [String: Int] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: dailyScoresKey)
        }
    }
    
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }
    
    var playedToday: Bool {
        get { UserDefaults.standard.bool(forKey: playedTodayKey) }
        set { UserDefaults.standard.set(newValue, forKey: playedTodayKey) }
    }

    var currentGameMode: GameMode {
        get {
            if let modeString = UserDefaults.standard.string(forKey: gameModeKey),
               let mode = GameMode(rawValue: modeString) {
                return mode
            }
            return .daily // Default to daily mode
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: gameModeKey)
        }
    }

    //save the last played date
    func saveLastPlayedDate(_ date: String) {
        UserDefaults.standard.set(date, forKey: lastPlayedDateKey)
    }
    
    //get the last played date
    func getLastPlayedDate() -> String? {
        return UserDefaults.standard.string(forKey: lastPlayedDateKey)
    }
    
    func getLast30DayScore() -> Int {
        let scores = Settings.sharedInstance.dailyScores
        
        // If needed, ensure only 30 days remain in the dictionary (as above)
        // Then just sum them up:
        return scores.values.reduce(0, +)
    }
}
