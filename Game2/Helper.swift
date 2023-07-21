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
