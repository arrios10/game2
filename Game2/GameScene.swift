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
    
    var gameMenu: GameMenu!

    
    // test phrases
    var testPhrases: [TestPhrases] = [
        TestPhrases(phrase: "Time is now, or never.", wordList: ["Time", "Is", "Now","Or", "Never"], source: "", notes: "", wordCount: 5, wuhbaNumber: 1),
        TestPhrases(phrase: "Action is its own reward.", wordList: ["Action", "Is", "Its", "Own", "Reward"], source: "", notes: "", wordCount: 5, wuhbaNumber: 2),
        TestPhrases(phrase: "As I think, I am.", wordList: ["As", "I", "Think", "I", "Am"], source: "", notes: "", wordCount: 5, wuhbaNumber: 3),
        TestPhrases(phrase: "Crowded thoughts yield absent minds.", wordList: ["Crowded", "Thoughts", "Yield", "Absent", "Minds"], source: "", notes: "", wordCount: 5, wuhbaNumber: 4),
        TestPhrases(phrase: "Hard to build, not blast.", wordList: ["Hard", "To", "Build", "Not", "Blast"], source: "", notes: "", wordCount: 5, wuhbaNumber: 5),
        TestPhrases(phrase: "I think, so I will.", wordList: ["I", "Think", "So", "I", "Will"], source: "", notes: "", wordCount: 5, wuhbaNumber: 6),
        TestPhrases(phrase: "Kind words unlock iron doors.", wordList: ["Kind", "Words", "Unlock", "Iron", "Doors"], source: "", notes: "", wordCount: 5, wuhbaNumber: 7),
        TestPhrases(phrase: "Last mile is the longest.", wordList: ["Last", "Mile", "Is", "The", "Longest"], source: "", notes: "", wordCount: 5, wuhbaNumber: 8),
        TestPhrases(phrase: "Make a long story short.", wordList: ["Make", "A", "Long", "Story", "Short"], source: "", notes: "", wordCount: 5, wuhbaNumber: 9),
        TestPhrases(phrase: "My habits are my base.", wordList: ["My", "Habits", "Are", "My", "Base"], source: "", notes: "", wordCount: 5, wuhbaNumber: 10),
        TestPhrases(phrase: "Step by step with ferocity.", wordList: ["Step", "By", "Step", "With", "Ferocity"], source: "", notes: "", wordCount: 5, wuhbaNumber: 11),
        TestPhrases(phrase: "This phrase is not true.", wordList: ["This", "Phrase", "Is", "Not", "True"], source: "", notes: "", wordCount: 5, wuhbaNumber: 12),
        TestPhrases(phrase: "Through hardship, to the stars.", wordList: ["Through", "Hardship", "To", "The", "Stars"], source: "", notes: "", wordCount: 5, wuhbaNumber: 13),
        TestPhrases(phrase: "Time is now, or never.", wordList: ["Time", "Is", "Now", "Or", "Never"], source: "", notes: "", wordCount: 5, wuhbaNumber: 14),
        TestPhrases(phrase: "Time is the only currency.", wordList: ["Time", "Is", "The", "Only", "Currency"], source: "", notes: "", wordCount: 5, wuhbaNumber: 15),
        TestPhrases(phrase: "What is above, is below.", wordList: ["What", "Is", "Above", "Is", "Below"], source: "", notes: "", wordCount: 5, wuhbaNumber: 16)
    ]
    
    
    // nodes
    private var boxParent = SKSpriteNode()
    var scoreSquares: [SKShapeNode] = []
    
    let boxPositions: [CGFloat] = [-244.0,-122.0,0.0,122.0,244.0]
    var totalBoxes: Int = 0
    var score = 0
    
    var pauseButton = SKShapeNode()
    var pauseButton2 = SKShapeNode()
    var numberLabel = SKLabelNode()

    
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
        
        // wuhba number label
        numberLabel = self.childNode(withName: "wuhbaNumber") as! SKLabelNode
        numberLabel.isHidden = true
        numberLabel.text = "Wuhba No. " + String(testPhrases[randomIndex].wuhbaNumber)

        
        // populate data from testPhrase array
        wordList = testPhrases[randomIndex].wordList
        answerPhrase = testPhrases[randomIndex].phrase
        totalBoxes = testPhrases[randomIndex].wordCount
        
        
        // setup pause/start buttons
        pauseButton = self.childNode(withName: "pausebar") as! SKShapeNode
        pauseButton2 = self.childNode(withName: "pausebar2") as! SKShapeNode

        pauseButton.alpha = 0.0
        pauseButton2.alpha = 0.0
        
        // setup the parent box and child boxes
        setupBoxes(totalBoxes: totalBoxes, boxParent: boxParent)
        
        // game timers
        
        removeItemsTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        

            wordTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 1.3, secondNumber: 1.5)), target: self, selector: #selector(GameScene.createWordStream), userInfo: nil, repeats: true)
 
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if stopEverything == true {
            endGame()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if mask == CollisionType.whiteBox.rawValue | CollisionType.whiteFallingBox.rawValue {
            
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
                        
                        if score == 9 {
                            score += 1
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
    
    func backToMenuWithDelay() {
        
        // Schedule the scene transition after a delay
        let delayAction = SKAction.wait(forDuration: 3.0)
        let transitionAction = SKAction.run { [weak self] in
            self?.scene?.view?.presentScene(self!.gameMenu, transition: .crossFade(withDuration: TimeInterval(0.5)))
        }
        
        run(SKAction.sequence([delayAction, transitionAction]))
    }
    
    @objc func createWordStream() {
        
        if wordList.count == 0 {
            wordTimer?.invalidate()
            removeItemsTimer?.invalidate()
            stopEverything = true
        }
        
        if stopEverything == false {
            
            let size = CGSize(width: ((self.frame.width * 0.8) + 10) / (CGFloat(totalBoxes)), height: 122)
            spawnFallingBox(size: size)
            
        }
    }
    
    func endGame() {
        boxParent.removeAllChildren()
        boxParent.color = .white
        boxParent.run(SKAction.move(to: self.anchorPoint, duration: 0.5))
        let label = SKLabelNode(text: answerPhrase)
        label.fontColor = .white
        label.fontSize = 35
        label.fontName = "Helvetica Neue Bold"
        label.position.y = 42
        let fadeAction = SKAction.fadeIn(withDuration: 0.4)
        label.run(fadeAction)
        boxParent.addChild(label)
        finalScoreBoxes()
        backToMenuWithDelay()
   
        
    }
    
 

    
    func finalScoreBoxes(){
        for node in scoreSquares {
            // Do something with each shape node, for example, change the stroke color
            
            if let nodeName = node.name, let nodeNumber = Int(nodeName) {
                // The conversion was successful and nodeNumber now holds the integer value
                
                switch nodeNumber {
                case 1:
                    let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX + 180, y: self.frame.midY - 42), duration: 0.21)
                    node.run(moveAction)
                case 2:
                    let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX + 140, y: self.frame.midY - 42), duration: 0.21)
                    node.run(moveAction)
                    
                case 3:
                    let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX + 100, y: self.frame.midY - 42), duration: 0.21)
                    node.run(moveAction)
                    
                case 4:
                    let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX + 60, y: self.frame.midY - 42), duration: 0.21)
                    node.run(moveAction)
                    
                case 5:
                    let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX + 20, y: self.frame.midY - 42), duration: 0.21)
                    node.run(moveAction)
                    
                case 6:
                    let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX - 20, y: self.frame.midY - 42), duration: 0.21)
                    node.run(moveAction)
                    
                case 7:
                    let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX - 60, y: self.frame.midY - 42), duration: 0.21)
                    node.run(moveAction)
                case 8:
                    let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX - 100, y: self.frame.midY - 42), duration: 0.21)
                    node.run(moveAction)
                    
                case 9:
                    let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX - 140, y: self.frame.midY - 42), duration: 0.21)
                    node.run(moveAction)
                    
                case 10:
                    let moveAction = SKAction.move(to: CGPoint(x: self.frame.midX - 180, y: self.frame.midY - 42), duration: 0.21)
                    node.run(moveAction)
                    
                default:
                    print("default hit")
                }
                
                
                
            }
            
        }
        
        numberLabel.isHidden = false
        
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
        print(boxWidth)
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

            print(box.position.x)
            
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
        let totalWidth: CGFloat = CGFloat(totalBoxes) * boxWidth + CGFloat(totalBoxes - 1)
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
        
        fallingBox.position.x = CGFloat.random(in: -82.0...82.0)
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
            element.fillColor = .white
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
