//
//  GameScene.swift
//  Game2
//
//  Created by Andrew Rios on 7/19/23.
//

import SpriteKit


enum CollisionType: UInt32 {
    case whiteBox = 1
    case grayBox = 2
    case whiteFallingBox = 4
    case grayFallingBox = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var boxParent = SKSpriteNode()
    
    // Generate the boxes.
    
    let gap: CGFloat = 0
    
    var lastWord = ""
    
    
    
    //falling box
    private weak var wordTimer: Timer?
    
    
    var stopEverything = false
    
    private weak var removeItemsTimer: Timer?
    
    
    var wordList = ["The", "Only", "Way", "Out", "Is","Through"]
    
    var wordBank: [String] = []
    
    
    let colorPalette: [UIColor] = [.systemBlue, .cyan, .green, .yellow, .orange, .red]
    
    
    let totalBoxes = 6
    
    
    
    override func didMove(to view: SKView) {
        // Set up the parent node.
        self.addChild(boxParent)
        
        physicsWorld.contactDelegate = self
        
        
        
        let boxWidth: CGFloat = ((self.frame.width * 0.8) + 10) / (CGFloat(totalBoxes))
        view.preferredFramesPerSecond = 120 // Set preferred FPS to 60
        physicsWorld.gravity = CGVector(dx: 0, dy: -3.71)
        
        
        
        for i in 0..<totalBoxes {
            let box = SKShapeNode(rectOf: CGSize(width: boxWidth, height: 100))
            
            
            box.lineWidth = 0
            
            box.position.x = CGFloat(i) * (boxWidth) - ((CGFloat(totalBoxes) * boxWidth + CGFloat(totalBoxes - 1)) / 2) + (boxWidth / 2)
            
            boxParent.addChild(box)
            
            // Add a label to the box.
            // let label = SKLabelNode(text: wordList[i])
            //label.fontColor = .black
            //label.fontSize = 25
            //label.fontName = "Helvetica Neue Bold"
            //label.alpha = 0
            //label.position = CGPoint(x: box.position.x, y: -10)  // position label relative to boxParent
            //boxParent.addChild(label)  // add label to boxParent instead of box
            
            let size = CGSize(width: box.frame.width / 2 , height: box.frame.height)
            
            
            box.physicsBody = SKPhysicsBody(rectangleOf: size)
            box.physicsBody?.affectedByGravity = false
            box.physicsBody?.isDynamic = false
            
            
            box.strokeColor = .white
            box.lineWidth = 8
            box.physicsBody?.categoryBitMask = CollisionType.whiteBox.rawValue
            box.physicsBody?.collisionBitMask = CollisionType.whiteFallingBox.rawValue
            box.physicsBody?.contactTestBitMask = CollisionType.whiteFallingBox.rawValue
            
            
            box.name = wordList[i]
            
        }
        
        
        if stopEverything == false {
            wordTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 1.3, secondNumber: 1.5)), target: self, selector: #selector(GameScene.createWordStream), userInfo: nil, repeats: true)
            removeItemsTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
            
        }
        
        let totalWidth: CGFloat = CGFloat(totalBoxes) * boxWidth + CGFloat(totalBoxes - 1) * gap
        boxParent.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 250)
        boxParent.size.width = totalWidth
        boxParent.color = .white
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch mask {
        case CollisionType.whiteBox.rawValue | CollisionType.whiteFallingBox.rawValue:
            print("White box and white falling box collided")
            
            if let whiteBox = contact.bodyA.node as? SKShapeNode {
                // use whiteBox
                if let whiteFallingBox = contact.bodyB.node {
                    // use whiteFallingBox
                    if whiteBox.name == whiteFallingBox.name {
                        print(whiteBox.name!)
                        let label = SKLabelNode(text: whiteBox.name)
                        label.fontColor = .black
                        label.fontSize = 24
                        label.fontName = "Helvetica Neue Bold"
                        label.position.y = 42
                        whiteBox.addChild(label)
                        let moveAction = SKAction.moveTo(y: -10, duration: 0.21)
                        //let sequence = SKAction.sequence([fadeOutAction, fadeInAction])
                        label.run(moveAction)
                        
                        whiteBox.fillColor = UIColor.white
                        whiteFallingBox.removeFromParent()
                        wordList.removeAll { $0 == whiteBox.name!}
                    } else{
                        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                            explosion.position = whiteFallingBox.position
                            addChild(explosion)
                        }
                        whiteFallingBox.removeFromParent()
                    }
                }
                
            }
            
            
            
            // Perform someAction here
        case CollisionType.grayBox.rawValue | CollisionType.grayFallingBox.rawValue:
            print("Gray box and gray falling box collided")
            
            if let grayBox = contact.bodyA.node {
                // use grayBox
                
                if let grayFallingBox = contact.bodyB.node {
                    // use grayFallingBox
                    
                    if grayFallingBox.position.y > self.frame.maxY {
                        print("above barrier")
                    }
                    if grayBox.name == grayFallingBox.name {
                        print(grayBox.name!)
                        let label = SKLabelNode(text: grayBox.name)
                        label.fontColor = .black
                        label.fontSize = 23
                        label.fontName = "Helvetica Neue Bold"
                        label.position.y = -10
                        grayBox.addChild(label)
                        grayFallingBox.removeFromParent()
                    }
                    
                }
                
            }
            
            
            // Perform someAction here
        default:
            return
        }
    }
    
    
    
    @objc func createWordStream() {
        
        if wordList.count == 0 {
            wordTimer?.invalidate()
            removeItemsTimer?.invalidate()
            stopEverything = true
        }
        
        if stopEverything == false {
            
            let size = CGSize(width: ((self.frame.width * 0.8) + 10) / (CGFloat(totalBoxes)), height: 100)
            
            let fallingBox = SKShapeNode(rectOf: size)
            let randomIndex = Int(arc4random_uniform(UInt32(wordBank.count)))
            addChild(fallingBox)
            
            
            if wordBank.isEmpty {
                // If it is, repopulate it with the original wordList.
                wordBank = wordList
            }
            
            
            
            let label = SKLabelNode(text: wordBank[Int(randomIndex)])
            label.fontColor = .white
            label.fontSize = 23
            label.fontName = "Helvetica Neue Bold"
            label.position = CGPoint(x: fallingBox.position.x, y: -10)
            
            fallingBox.addChild(label)
            
            
            fallingBox.position.x = CGFloat.random(in: -69.0...69.0)
            fallingBox.position.y = self.frame.maxY + 100
            fallingBox.name = wordBank[Int(randomIndex)]
            
            let boxSize = CGSize(width: label.frame.width , height: fallingBox.frame.height)
            wordBank.remove(at: randomIndex)
            
            
            // Assign the physicsBody first
            fallingBox.physicsBody = SKPhysicsBody(rectangleOf: boxSize)
            fallingBox.physicsBody?.linearDamping = 0.5
            
            
            fallingBox.strokeColor = .systemYellow
            fallingBox.lineWidth = 3
            fallingBox.physicsBody?.categoryBitMask = CollisionType.whiteFallingBox.rawValue
            fallingBox.physicsBody?.collisionBitMask = CollisionType.whiteBox.rawValue | CollisionType.whiteFallingBox.rawValue | CollisionType.grayFallingBox.rawValue
            fallingBox.physicsBody?.contactTestBitMask = CollisionType.whiteBox.rawValue | CollisionType.whiteFallingBox.rawValue | CollisionType.grayFallingBox.rawValue
            
            
        }
    }
    
    
    
    @objc func removeItems(){
        for child in children{
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
        }
        
    }
    
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            boxParent.run(SKAction.moveTo(x: location.x, duration: 0.1))
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            boxParent.run(SKAction.moveTo(x: location.x * 2, duration: 0.13))
        }
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        
    }
}
