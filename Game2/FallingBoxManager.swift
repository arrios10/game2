//
//  FallingBoxManager.swift
//  Game2
//
//  Created by Andrew Rios on 10/22/23.
//

import Foundation
import SpriteKit

class FallingBoxManager {
    
    var explosionTexture: SKTexture?
    var explosionEmitter: SKEmitterNode?
    var explosion2Texture: SKTexture?
    var explosion2Emitter: SKEmitterNode?
    
    var totalBoxes: Int = 0
    let boxPositions: [CGFloat] = [-244.0,-122.0,0.0,122.0,244.0]
    let gameFrame:CGRect
    var letterBank: [String]
    var letterList: [String]  // Added wordList property
    
    init(gameFrame: CGRect, totalBoxes: Int,letterBank: [String],letterList: [String]) {
        self.totalBoxes = totalBoxes
        self.letterBank = letterBank  // Assign wordList
        self.gameFrame = gameFrame
        self.letterList = letterList  // Assign wordList
        
        // Preload textures
        self.explosionTexture = SKTexture(imageNamed: "spark")
        self.explosion2Texture = SKTexture(imageNamed: "bar")
        
        // Preload emitters
        if let emitter = SKEmitterNode(fileNamed: "Explosion") {
            self.explosionEmitter = emitter
        }
        
        if let emitter = SKEmitterNode(fileNamed: "Explosion2") {
            self.explosion2Emitter = emitter
        }
        
    }
    
    
    func animateBoxImpact(parentNode: SKNode,fallingBox: SKNode) {
        if let explosion = explosionEmitter?.copy() as? SKEmitterNode {
            explosion.position = fallingBox.position
            parentNode.addChild(explosion)
            
            let wait = SKAction.wait(forDuration: 1.0)
            let remove = SKAction.removeFromParent()
            explosion.run(SKAction.sequence([wait, remove]))
        }
        
        if let explosion2 = explosion2Emitter?.copy() as? SKEmitterNode {
            explosion2.position = fallingBox.position
            parentNode.addChild(explosion2)
            
            let wait = SKAction.wait(forDuration: 1.0)
            let remove = SKAction.removeFromParent()
            explosion2.run(SKAction.sequence([wait, remove]))
        }
    }
    
    
    func spawnFallingBox(parentNode: SKNode, size: CGSize) {
        
        if letterBank.isEmpty {
            // If it is, repopulate it with the original wordList.
            letterBank = letterList
        }
        
        let fallingBox = SKShapeNode(rectOf: size)
        
        if let randomWord = letterBank.randomElement(),
           let index = letterBank.firstIndex(of: randomWord) {
            parentNode.addChild(fallingBox)
            
            let label = SKLabelNode(text: randomWord)
            label.fontColor = .white
            label.fontSize = 25
            label.fontName = "AvenirNext-Bold"
            label.position = CGPoint(x: fallingBox.position.x, y: -10)
            
            fallingBox.addChild(label)
            fallingBox.name = randomWord
            
            fallingBox.userData = [
                "word": randomWord,
                "index": index,
            ]
            letterBank.remove(at: index)
        }
        
        fallingBox.position.x = CGFloat.random(in: -82.0...82.0)
        fallingBox.position.y = gameFrame.maxY + 50
        fallingBox.strokeColor = .systemYellow
        fallingBox.lineWidth = 3
        
        let boxSize = CGSize(width: fallingBox.frame.width - 20 , height: fallingBox.frame.height)
        
        // fallingbox physics
        fallingBox.physicsBody = SKPhysicsBody(rectangleOf: boxSize)
        fallingBox.physicsBody?.linearDamping = 0.5
        fallingBox.physicsBody?.categoryBitMask = CollisionType.fallingBox.rawValue
        fallingBox.physicsBody?.collisionBitMask = CollisionType.wordBox.rawValue
        fallingBox.physicsBody?.contactTestBitMask = CollisionType.wordBox.rawValue
    }
    
    
}
