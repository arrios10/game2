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
    

    func fetchTestPhrase(byDate date: String, completion: @escaping (TestPhrases?) -> Void) {
            let ref = Database.database().reference()
        
        ref.child("testPhrases").queryOrdered(byChild: "date").queryEqual(toValue: date).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                var testPhrase: TestPhrases? = nil
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if let value = child.value as? [String: Any] {
                        let phrase = value["phrase"] as? String ?? ""
                        let wordList = value["wordList"] as? [String] ?? []
                        let metadata = value["metadata"] as? String ?? ""
                        let notes = value["notes"] as? String ?? ""
                        let wuhbaNumber = value["wuhbaNumber"] as? Int ?? 0
                        let date = value["date"] as? String ?? ""

                        testPhrase = TestPhrases(
                            date: date,
                            metadata: metadata,
                            notes: notes,
                            phrase: phrase,
                            wordList:wordList ,
                            wuhbaNumber: wuhbaNumber
                        )
                        break // Since we only expect one result, we can break after finding the first match
                    }
                }
                completion(testPhrase) // Call completion with either the found phrase or nil if not found
            }
        }
}

