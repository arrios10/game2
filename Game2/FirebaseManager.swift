//
//  FirebaseManager.swift
//  Game2
//
//  Created by Andrew Rios on 8/25/23.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}
    

    func fetchGameData(byDate date: String, completion: @escaping (GameData?) -> Void) {
            let ref = Database.database().reference()
        
        ref.child("gameData").queryOrdered(byChild: "date").queryEqual(toValue: date).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                var gameData: GameData? = nil
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if let value = child.value as? [String: Any] {
                        let word = value["word"] as? String ?? ""
                        let letterList = value["letterList"] as? [String] ?? []
                        let metadata = value["metadata"] as? String ?? ""
                        let notes = value["notes"] as? String ?? ""
                        let wuhbaNumber = value["wuhbaNumber"] as? Int ?? 0
                        let date = value["date"] as? String ?? ""

                        gameData = GameData(
                            date: date,
                            metadata: metadata,
                            notes: notes,
                            word: word,
                            letterList: letterList ,
                            wuhbaNumber: wuhbaNumber
                        )
                        break // Since we only expect one result, we can break after finding the first match
                    }
                }
                completion(gameData) // Call completion with either the found data or nil if not found
            }
        }
}

