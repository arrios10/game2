//
//  UserScore.swift
//  Game2
//
//  Created by Andrew Rios on 3/4/24.
//

import Foundation

struct UserScore {
    let date: String
    let wuhbaNumber: Int
    let score: Int

    var toDictionary: [String: Any] {
        return [
            "date": date,
            "wuhbaNumber": wuhbaNumber,
            "score": score
        ]
    }
}

