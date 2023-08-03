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
    
    // test phrases
    var testPhrases: [TestPhrases] = [
        TestPhrases(phrase: "I think, therefore I am", wordList: ["I", "Think", "Therefore","I", "Am"], author: "Descartes", notes: "", wordCount: 5),
        TestPhrases(phrase: "I have my job be", wordList: ["To", "Be", "Or", "Not", "Be"], author: "Shakespeare", notes: "", wordCount: 5),
        TestPhrases(phrase: "Do or do not, try", wordList: ["Do", "Or", "Do", "Not", "Try"], author: "Yoda", notes: "", wordCount: 5),
        TestPhrases(phrase: "Yes, we can change it", wordList: ["Yes", "We", "Can", "Change", "It"], author: "Obama", notes: "", wordCount: 5),
        TestPhrases(phrase: "Love all, trust a few", wordList: ["Love", "All", "Trust", "A", "Few"], author: "Shakespeare", notes: "", wordCount: 5),
        TestPhrases(phrase: "Be the change you seek", wordList: ["Be", "The", "Change", "You", "Seek"], author: "Gandhi", notes: "", wordCount: 5),
        TestPhrases(phrase: "The only thing we fear", wordList: ["The", "Only", "Thing", "We", "Fear"], author: "Roosevelt", notes: "", wordCount: 5),
        TestPhrases(phrase: "Make haste slowly, achieve more", wordList: ["Make", "Haste", "Slowly", "Achieve", "More"], author: "Augustus", notes: "", wordCount: 5),
        TestPhrases(phrase: "Know thyself, then know others", wordList: ["Know", "Thyself", "Then", "Know", "Others"], author: "Confucius", notes: "", wordCount: 5),
        TestPhrases(phrase: "Your friends close, enemies closer", wordList: ["Your", "Friends", "Close", "Enemies", "Closer"], author: "Sun Tzu", notes: "", wordCount: 5)
    ]

    
    // nodes
    private var boxParent = SKSpriteNode()
    var scoreSquares: [SKShapeNode] = []
    
    let gap: CGFloat = 0
    var totalBoxes: Int = 0
    var score = 0
    
    // timers
    private weak var wordTimer: Timer?
    private weak var removeItemsTimer: Timer?
    
    // word arrays
    var wordList: [String] = []
    var wordBank: [String] = []
    
    var answerPhrase: String = ""
    var stopEverything = false
    
    
    // MARK: - Lifecycle Methods
    override func didMove(to view: SKView) {
        
        // Set up the parent node.
        self.addChild(boxParent)
        
        // set up physics world
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -3.14)
        
        // setup access for gamescene score nodes
        setupScoreBoxes()
        
        // random index for test phrases
        let randomIndex = Int(arc4random_uniform(UInt32(testPhrases.count)))
        
        // populate data from testPhrase array
        wordList = testPhrases[randomIndex].wordList
        answerPhrase = testPhrases[randomIndex].phrase
        totalBoxes = testPhrases[randomIndex].wordCount
        
        // setup the parent box and child boxes
        setupBoxes(totalBoxes: totalBoxes, boxParent: boxParent)
        
        // game timers
        wordTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 1.3, secondNumber: 1.5)), target: self, selector: #selector(GameScene.createWordStream), userInfo: nil, repeats: true)
        removeItemsTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if stopEverything == true {
            endGame()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if mask == CollisionType.whiteBox.rawValue | CollisionType.whiteFallingBox.rawValue {
            print("White box and white falling box collided")
            
            if let wordBox = contact.bodyA.node as? SKShapeNode {
                // use whiteBox
                if let fallingBox = contact.bodyB.node {
                    // use whiteFallingBox
                    if wordBox.name == fallingBox.name {
                        
                        // add the falling box word to the white word box
                        addWordToBox(wordBox: wordBox, fallingBox: fallingBox)
                        
                        fallingBox.removeFromParent()
                        
                        if let index = wordList.firstIndex(of: wordBox.name!) {
                            wordList.remove(at: index)
                        }
                        
                        wordBox.name = nil
                        
                    } else{
                        
                        // blow up box effects on impact
                        animateBoxImpact(fallingBox: fallingBox)
                        
                        if score == 10 {
                            stopEverything = true
                        } else {
                            score += 1
                            
                        }
                        
                        updateScoreBoxes()
                        fallingBox.removeFromParent()
                    }
                }
            }
        }
    }
    
    
    // MARK: - Game Methods
    
    func addWordToBox(wordBox: SKShapeNode, fallingBox: SKNode) {
        let label = SKLabelNode(text: wordBox.name)
        label.fontColor = .black
        label.fontSize = 25
        label.fontName = "Helvetica Neue Bold"
        label.position.y = 42
        wordBox.addChild(label)
        let moveAction = SKAction.moveTo(y: -10, duration: 0.21)
        //let sequence = SKAction.sequence([fadeOutAction, fadeInAction])
        label.run(moveAction)
        
        wordBox.fillColor = UIColor.white
    }
    
    func animateBoxImpact(fallingBox: SKNode) {
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = fallingBox.position
            addChild(explosion)
        }
        
        if let explosion = SKEmitterNode(fileNamed: "Explosion2") {
            explosion.position = fallingBox.position
            addChild(explosion)
        }
        
    }
    
    @objc func createWordStream() {
        
        if wordList.count == 0 {
            wordTimer?.invalidate()
            removeItemsTimer?.invalidate()
            stopEverything = true
        }
        
        if stopEverything == false {
            
            let size = CGSize(width: ((self.frame.width * 0.8) + 10) / (CGFloat(totalBoxes)), height: 125)
            
            spawnFallingBox(size: size)
            
        }
    }
    
    func endGame() {
        boxParent.removeAllChildren()
        boxParent.color = .white
        boxParent.run(SKAction.move(to: self.anchorPoint, duration: 0.5))
        let label = SKLabelNode(text: answerPhrase)
        label.fontColor = .white
        label.fontSize = 30
        label.fontName = "Helvetica Neue Bold"
        label.position.y = 42
        let moveAction = SKAction.fadeIn(withDuration: 0.4)
        label.run(moveAction)
        boxParent.addChild(label)
        
    }
    
    func setupScoreBoxes(){
        // access gamescene score nodes
        for i in 1...10 {
            if let square = self.childNode(withName: "\(i)") as? SKShapeNode {
                scoreSquares.append(square)
            }
        }
    }
    
    func setupBoxes(totalBoxes: Int, boxParent: SKSpriteNode) {
        
        // setup word box width
        let boxWidth: CGFloat = ((self.frame.width * 0.8) + 10) / (CGFloat(totalBoxes))
        
        // setup word boxes
        for i in 0..<totalBoxes {
            
            // create word box
            let box = SKShapeNode(rectOf: CGSize(width: boxWidth, height: 125))
            
            // calculate word box size
            let size = CGSize(width: box.frame.width / 2 , height: box.frame.height)
            
            // box properties
            box.strokeColor = .white
            box.lineWidth = 8
            box.position.x = CGFloat(i) * (boxWidth) - ((CGFloat(totalBoxes) * boxWidth + CGFloat(totalBoxes - 1)) / 2) + (boxWidth / 2)
            
            boxParent.addChild(box)
            
            // box physics properties
            box.physicsBody = SKPhysicsBody(rectangleOf: size)
            box.physicsBody?.affectedByGravity = false
            box.physicsBody?.isDynamic = false
            box.physicsBody?.categoryBitMask = CollisionType.whiteBox.rawValue
            box.physicsBody?.collisionBitMask = CollisionType.whiteFallingBox.rawValue
            box.physicsBody?.contactTestBitMask = CollisionType.whiteFallingBox.rawValue
            
            // set box name to current word
            box.name = wordList[i]
            
        }
        
        // set parent box properties
        let totalWidth: CGFloat = CGFloat(totalBoxes) * boxWidth + CGFloat(totalBoxes - 1) * gap
        boxParent.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 250)
        boxParent.size.width = totalWidth
        boxParent.color = .white
        
    }
    
    
    func spawnFallingBox(size: CGSize) {
        
        if wordBank.isEmpty {
            // If it is, repopulate it with the original wordList.
            wordBank = wordList
        }
        
        let fallingBox = SKShapeNode(rectOf: size)
        
        if let randomWord = wordBank.randomElement(),
           let index = wordBank.firstIndex(of: randomWord) {
            addChild(fallingBox)
            
            let label = SKLabelNode(text: randomWord)
            label.fontColor = .white
            label.fontSize = 25
            label.fontName = "Helvetica Neue Bold"
            label.position = CGPoint(x: fallingBox.position.x, y: -10)
            
            fallingBox.addChild(label)
            fallingBox.name = randomWord
            
            fallingBox.userData = [
                "word": randomWord,
                "index": index,
            ]
            wordBank.remove(at: index)
        }
        
        fallingBox.position.x = CGFloat.random(in: -69.0...69.0)
        fallingBox.position.y = self.frame.maxY + 100
        
        fallingBox.strokeColor = .systemYellow
        fallingBox.lineWidth = 3
        
        let boxSize = CGSize(width: fallingBox.frame.width - 20 , height: fallingBox.frame.height)
        
        // fallingbox physics
        fallingBox.physicsBody = SKPhysicsBody(rectangleOf: boxSize)
        fallingBox.physicsBody?.linearDamping = 0.5
        fallingBox.physicsBody?.categoryBitMask = CollisionType.whiteFallingBox.rawValue
        fallingBox.physicsBody?.collisionBitMask = CollisionType.whiteBox.rawValue | CollisionType.whiteFallingBox.rawValue | CollisionType.grayFallingBox.rawValue
        fallingBox.physicsBody?.contactTestBitMask = CollisionType.whiteBox.rawValue | CollisionType.whiteFallingBox.rawValue | CollisionType.grayFallingBox.rawValue
    }
    
    
    @objc func removeItems(){
        for child in children{
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
        }
        
    }
    
    func updateScoreBoxes(){
        for i in stride(from: 0, to: score, by: 1) {
            let element = scoreSquares[i]
            element.alpha = 0.1
        }
    }
    
    
    // MARK: - Input Handling Methods
    
    
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
