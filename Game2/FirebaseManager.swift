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
    
    func fetchTestPhrase(wuhbaNumber: Int, completion: @escaping (TestPhrases?) -> Void) {
        let ref = Database.database().reference()
        ref.child("testPhrases").child("\(wuhbaNumber)").observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                let phrase = value["phrase"] as? String ?? ""
                let wordList = value["wordList"] as? [String] ?? []
                let source = value["source"] as? String ?? ""
                let notes = value["notes"] as? String ?? ""
                let wordCount = value["wordCount"] as? Int ?? 0
                let wuhbaNumber = value["wuhbaNumber"] as? Int ?? 0
                
                let testPhrase = TestPhrases(
                    phrase: phrase,
                    wordList: wordList,
                    source: source,
                    notes: notes,
                    wordCount: wordCount,
                    wuhbaNumber: wuhbaNumber
                )
                completion(testPhrase)
            } else {
                completion(nil)
            }
        }
    }

}

