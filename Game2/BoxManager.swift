//
//  BoxManager.swift
//  Game2
//
//  Created by Andrew Rios on 10/21/23.
//

import Foundation
import SpriteKit

class BoxManager {
    
    var boxParent: SKSpriteNode?
    var totalBoxes: Int = 0
    let boxPositions: [CGFloat] = [-244.0,-122.0,0.0,122.0,244.0]
    let gameFrame:CGRect
    let letterList: [String]  // Added wordList property

    
    init(gameFrame: CGRect, boxParent: SKSpriteNode, totalBoxes: Int,letterList: [String]) {
        self.boxParent = boxParent
        self.totalBoxes = totalBoxes
        self.letterList = letterList  // Assign wordList
        self.gameFrame = gameFrame
       }
    
    func addWordToBox(wordBox: SKShapeNode, fallingBox: SKNode) {
        let label = SKLabelNode(text: wordBox.name)
        label.fontColor = .black
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 25
        label.position.y = 42
        wordBox.addChild(label)
        let moveAction = SKAction.moveTo(y: -10, duration: 0.21)
        label.run(moveAction)
        
        wordBox.fillColor = UIColor.white
    }
    
    func setupBoxes() {
        // setup word box width
        let boxWidth: CGFloat = ((gameFrame.width * 0.8) + 10) / (CGFloat(totalBoxes))
        
        // setup word boxes
        for i in 0..<totalBoxes {
            // create word box
            let box = SKShapeNode(rectOf: CGSize(width: boxWidth, height: 122))
            
            // calculate word box size
            let size = CGSize(width: box.frame.width / 2 , height: box.frame.height)
            
            // box properties
            box.strokeColor = .white
            box.lineWidth = 8
            box.position.x = boxPositions[i]
            boxParent!.addChild(box)
            
            // box physics properties
            box.physicsBody = SKPhysicsBody(rectangleOf: size)
            box.physicsBody?.affectedByGravity = false
            box.physicsBody?.isDynamic = false
            box.physicsBody?.categoryBitMask = CollisionType.wordBox.rawValue
            box.physicsBody?.collisionBitMask = CollisionType.fallingBox.rawValue
            box.physicsBody?.contactTestBitMask = CollisionType.fallingBox.rawValue
            
            // set box name to current word
            box.name = letterList[i]
        }
        
        // set parent box properties
        let totalWidth: CGFloat = CGFloat(totalBoxes) * boxWidth + CGFloat(totalBoxes - 1)
        self.boxParent?.position = CGPoint(x: gameFrame.midX, y: gameFrame.minY + 250)
        boxParent!.size.width = totalWidth
        boxParent!.color = .white
        
    }
}
