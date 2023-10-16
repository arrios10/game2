//
//  GameScene.swift
//  Game2
//
//  Created by Andrew Rios on 7/19/23.
//

import Foundation
import SpriteKit
import Firebase
import FirebaseDatabase

enum CollisionType: UInt32 {
    case wordBox = 1
    case fallingBox = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var explosionTexture: SKTexture?
    var explosionEmitter: SKEmitterNode?
    
    var explosion2Texture: SKTexture?
    var explosion2Emitter: SKEmitterNode?
    
    var gameMenu: GameMenu!
    var currentPhrase: TestPhrases!
    var totalBoxes: Int = 0
    var score = 0
    var answerPhrase: String = ""
    var stopEverything = false
    var gameComplete = false
    var gameSeconds: Int = 0

    
    var moveBoxAction: SKAction!
    
    //nodes
    private var boxParent = SKSpriteNode()
    var scoreSquares: [SKShapeNode] = []
    let boxPositions: [CGFloat] = [-244.0,-122.0,0.0,122.0,244.0]
    var pauseButton = SKShapeNode()
    var pauseButton2 = SKShapeNode()
    var numberLabel = SKLabelNode()
    
    // timers
    private weak var wordTimer: Timer?
    private weak var removeItemsTimer: Timer?
    
    // word arrays
    var wordList: [String] = []
    var wordBank: [String] = []

    // MARK: - Lifecycle Methods
    override func didMove(to view: SKView) {
        
        // Preload textures
          explosionTexture = SKTexture(imageNamed: "spark")
        explosion2Texture = SKTexture(imageNamed: "bar")

          // Preload emitters
          if let emitter = SKEmitterNode(fileNamed: "Explosion") {
              explosionEmitter = emitter
          }
        
        if let emitter = SKEmitterNode(fileNamed: "Explosion2") {
            explosion2Emitter = emitter
        }
  
        // set up physics world
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -3.14)
        
        setupActions()
        
        // Observer for the `UIApplication.willResignActiveNotification` notification.
        // When the app is about to go from the active to inactive state, the method `appResignActive` will be called.
        NotificationCenter.default.addObserver(
            self,                                   // The observer is `self`, usually an instance of a class that contains this code.
            selector: #selector(GameScene.appResignActive), // The method that will be called when the notification is received.
            name: UIApplication.willResignActiveNotification, // The name of the notification to observe for.
            object: nil                              // The object sending the notification. Nil means it listens to any object that sends this notification.
        )

        // Set up the parent node.appResignActive
        self.addChild(boxParent)
        
        // setup access for gamescene score nodes
        setupScoreBoxes()
    
        // wuhba number label
        numberLabel = self.childNode(withName: "wuhbaNumber") as! SKLabelNode
        numberLabel.isHidden = true
        numberLabel.text = "Wuhba No. " + String(currentPhrase!.wuhbaNumber)
        
        // populate data from testPhrase array
        wordList = currentPhrase!.wordList
        answerPhrase = currentPhrase!.phrase
        totalBoxes = currentPhrase!.wordCount
        
        // setup pause/start buttons
        pauseButton = self.childNode(withName: "pausebar") as! SKShapeNode
        pauseButton2 = self.childNode(withName: "pausebar2") as! SKShapeNode
        pauseButton.alpha = 0.0
        pauseButton2.alpha = 0.0
        
        // setup the parent box and child boxes
        setupBoxes(totalBoxes: totalBoxes, boxParent: boxParent)
        
        //run timers
        removeItemsTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1.0), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        wordTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 1.3, secondNumber: 1.5)), target: self, selector: #selector(GameScene.createWordStream), userInfo: nil, repeats: true)
    }
    
    override public func willMove(from view: SKView) {
        self.removeAllChildren()
        self.removeAllActions()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if stopEverything == true && gameComplete == false {
            endGame()
        }
    }
    
    deinit {
        print("\n THIS SCENE WAS REMOVED FROM MEMORY (DEINIT) \n")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appResignActive() {
        physicsWorld.gravity.dy = 0
        wordTimer?.invalidate()
        removeItemsTimer?.invalidate()
        self.removeAllActions()
        self.removeAllChildren()
        backToMenuWithDelay()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if mask == CollisionType.wordBox.rawValue | CollisionType.fallingBox.rawValue {
            
            if let wordBox = contact.bodyA.node as? SKShapeNode {
                // use wordbox
                if let fallingBox = contact.bodyB.node {
                    // use falling box
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
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 25
        label.position.y = 42
        wordBox.addChild(label)
        let moveAction = SKAction.moveTo(y: -10, duration: 0.21)
        //let sequence = SKAction.sequence([fadeOutAction, fadeInAction])
        label.run(moveAction)
        
        wordBox.fillColor = UIColor.white
    }
    
    func animateBoxImpact(fallingBox: SKNode) {
        if let explosion = explosionEmitter?.copy() as? SKEmitterNode {
              explosion.position = fallingBox.position
              addChild(explosion)
          }
        
        if let explosion2 = explosion2Emitter?.copy() as? SKEmitterNode {
              explosion2.position = fallingBox.position
              addChild(explosion2)
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
            stopEverything = true
        }
        if stopEverything == false {
            let size = CGSize(width: ((self.frame.width * 0.8) + 10) / (CGFloat(totalBoxes)), height: 122)
            spawnFallingBox(size: size)
        }
    }
    
    func endGame() {
        // Log game completed event to Firebase Analytics
        Analytics.logEvent("game_completed", parameters: [
              "final_score": 10-score,  // Replace 'finalScore' with actual variable
              "game_seconds": gameSeconds, 
              "wuhba_number": currentPhrase!.wuhbaNumber

          ])
        gameComplete = true
        wordTimer?.invalidate()
        removeItemsTimer?.invalidate()
        for child in children {
            if currentPhrase!.wordList.contains(child.name ?? "") {
                child.removeFromParent()
            }
        }
        
       
        print("score: ",10-score)
        
        boxParent.removeAllChildren()
        boxParent.color = .white
        boxParent.run(SKAction.move(to: self.anchorPoint, duration: 0.5))
        let label = SKLabelNode(text: answerPhrase)
        label.fontColor = .white
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 36
        label.position.y = 42
        let fadeAction = SKAction.fadeIn(withDuration: 0.4)
        label.run(fadeAction)
        addChild(label)
        finalScoreBoxes()
        backToMenuWithDelay()
    }

    
    func finalScoreBoxes() {
        let baseX = self.frame.midX
        let baseY = self.frame.midY - 42
        let duration = 0.42
        let initialOffset: CGFloat = 180
        let stepOffset: CGFloat = 40

        for node in scoreSquares.reversed() {
            if let nodeName = node.name, let nodeNumber = Int(nodeName), nodeNumber >= 1 && nodeNumber <= 10 {
                // For nodes 1 to 5, we move right from the midpoint
                // For nodes 6 to 10, we move left from the midpoint
                let moveX = baseX + (initialOffset - ((CGFloat(nodeNumber)-1) * stepOffset))
                let moveAction = SKAction.move(to: CGPoint(x: moveX, y: baseY), duration: duration)
                node.run(moveAction)
            } else {
                print("Unrecognized node name or out of range: \(node.name ?? "nil")")
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
            boxParent.addChild(box)
            
            // box physics properties
            box.physicsBody = SKPhysicsBody(rectangleOf: size)
            box.physicsBody?.affectedByGravity = false
            box.physicsBody?.isDynamic = false
            box.physicsBody?.categoryBitMask = CollisionType.wordBox.rawValue
            box.physicsBody?.collisionBitMask = CollisionType.fallingBox.rawValue
            box.physicsBody?.contactTestBitMask = CollisionType.fallingBox.rawValue
            
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
        print("arrays:")
        print(wordBank)
        print(wordList)
        
        if wordBank.isEmpty {
            // If it is, repopulate it with the original wordList.
            wordBank = wordList
        }
        
        let fallingBox = SKShapeNode(rectOf: size)
        
        if let randomWord = wordBank.randomElement(),
           let index = wordBank.firstIndex(of: randomWord) {
            addChild(fallingBox)
            print(randomWord)
            
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
            wordBank.remove(at: index)
        }
        
        fallingBox.position.x = CGFloat.random(in: -82.0...82.0)
        fallingBox.position.y = self.frame.maxY + 82
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
    
    @objc func removeItems(){
        gameSeconds += 1
        for child in children{
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
        }
    }
    
    private func setupActions() {
          moveBoxAction = SKAction.moveTo(x: 0, duration: 0.1) // Initialize with dummy value
      }
    
    func updateScoreBoxes(){
        for i in stride(from: 0, to: score, by: 1) {
            let element = scoreSquares[i]
            element.alpha = 0.1
            element.fillColor = .white
        }
    }
    
    // MARK: - Input Handling Methods
    func touchDown(atPoint pos : CGPoint) {}
    func touchMoved(toPoint pos : CGPoint) {}
    func touchUp(atPoint pos : CGPoint) {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let newAction = SKAction.moveTo(x: location.x, duration: 0.1)
            moveBoxAction = newAction
            boxParent.run(moveBoxAction)
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
                let location = touch.location(in: self)
                let newAction = SKAction.moveTo(x: location.x * 2, duration: 0.13)
                moveBoxAction = newAction
                boxParent.run(moveBoxAction)
            }
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    
    
    // for test phrases
    func uploadTestData() {
        // Initialize a DatabaseReference
        let ref = Database.database().reference()
        
        // Your test data
        let testPhrases: [TestPhrases] = [
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
            TestPhrases(phrase: "What is above, is below.", wordList: ["What", "Is", "Above", "Is", "Below"], source: "", notes: "", wordCount: 5, wuhbaNumber: 16)        ]
        
        for phrase in testPhrases {
            // Create a Dictionary representation of your object
            print(phrase)
            let phraseDict: [String : Any] = [
                "phrase": phrase.phrase,
                "wordList": phrase.wordList,
                "source": phrase.source,
                "notes": phrase.notes,
                "wordCount": phrase.wordCount,
                "wuhbaNumber": phrase.wuhbaNumber
            ]
            
            // Generate a new child location using a unique key and save the Dictionary into it
            ref.child("testPhrases").child("\(phrase.wuhbaNumber)").setValue(phraseDict)
        }
    }
}
