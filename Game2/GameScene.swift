//
//  GameScene.swift
//  Game2
//
//  Created by Andrew Rios on 7/19/23

import Foundation
import SpriteKit
import Firebase
import FirebaseDatabase
import FirebaseAnalytics
import GameKit

enum CollisionType: UInt32 {
    case wordBox = 1
    case fallingBox = 4
}

protocol GameSceneDelegate: AnyObject {
    func shareScore(score: Int, wuhbaNumber: Int)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var gameDelegate: GameSceneDelegate?
    
    //box managers
    var fallingBoxManager: FallingBoxManager!
    var boxManager: BoxManager!
    
    var gameMenu: GameMenu!
    var currentWord: GameData!
    var totalBoxes: Int = 0
    var score = 0
    var answerWord: String = ""
    var stopEverything = false
    var gameComplete = false
    var gameSeconds: Int = 0
    var moveBoxAction: SKAction!
    
    //nodes
    private var boxParent = SKSpriteNode()
    private var spout1 = SKShapeNode()
    private var spout2 = SKShapeNode()
    
    private var shareButton = SKSpriteNode()
    private var exitButton = SKSpriteNode()
    private var shareLabel = SKLabelNode()
    
    var scoreSquares: [SKShapeNode] = []
    let boxPositions: [CGFloat] = [-244.0,-122.0,0.0,122.0,244.0]
    var pauseButton = SKShapeNode()
    var pauseButton2 = SKShapeNode()
    var numberLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var answerLabel = SKLabelNode()
    
    // sounds
    let rightSound = SKAction.playSoundFileNamed("Pickup_coin32.wav", waitForCompletion: false)
    let wrongSound = SKAction.playSoundFileNamed("Blip_select20.wav", waitForCompletion: false)
    let completeSound = SKAction.playSoundFileNamed("Pickup_coin94.wav", waitForCompletion: false)
    
    
    // timers
    private weak var wordTimer: Timer?
    private weak var removeItemsTimer: Timer?
    
    // word arrays
    var letterList: [String] = []
    var letterBank: [String] = []
    
    // MARK: - Lifecycle Methods
    override func didMove(to view: SKView) {
        
        answerLabel = SKLabelNode(text: "SHOW ANSWER")
        answerLabel.name = "answerLabel"
        answerLabel.fontColor = .white
        
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        spout1 = self.childNode(withName: "spout1") as! SKShapeNode
        spout2 = self.childNode(withName: "spout2") as! SKShapeNode
        
        shareLabel = self.childNode(withName: "shareLabel") as! SKLabelNode
        shareButton = self.childNode(withName: "shareButton") as! SKSpriteNode
        exitButton = self.childNode(withName: "exitButton") as! SKSpriteNode
        
        shareLabel.isHidden = true
        exitButton.isHidden = true
        shareButton.isHidden = true

        // set up physics world
        physicsWorld.contactDelegate = self
        
        //game speed
        physicsWorld.gravity = CGVector(dx: 0, dy: -2.8)
        
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
        numberLabel.text = "Wuhba No. " + String(currentWord!.wuhbaNumber)
        
        // populate data from array
        letterList = currentWord!.letterList
        answerWord = currentWord!.word
        totalBoxes = 5
        
        // setup the parent box and child boxes
        boxManager = BoxManager(gameFrame: self.frame, boxParent: boxParent, totalBoxes: totalBoxes, letterList: currentWord!.letterList)
        //setupBoxes(totalBoxes: totalBoxes, boxParent: boxParent)
        boxManager.setupBoxes()
        
        fallingBoxManager = FallingBoxManager(gameFrame: self.frame, totalBoxes: totalBoxes, letterBank: letterBank, letterList: letterList)
        
        
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
        print("*** resign active ***")
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
                        self.boxManager.addWordToBox(wordBox: wordBox, fallingBox: fallingBox)
                        fallingBox.removeFromParent()
                        if let index = fallingBoxManager.letterList.firstIndex(of: wordBox.name!) {
                            fallingBoxManager.letterList.remove(at: index)
                            fallingBoxManager.letterBank.removeAll{$0 == wordBox.name}
                            print("YO YO " + wordBox.name!)

                        }
                        wordBox.name = nil
                        if Settings.sharedInstance.soundEnabled {
                            run(rightSound)
                        }
                        
                        if fallingBoxManager.letterList.count == 0 {
                            stopEverything = true
                        }

                    } else{
                        // blow up box effects on impact
                        fallingBoxManager.animateBoxImpact(parentNode: self, fallingBox: fallingBox)
                        
                    
                        if Settings.sharedInstance.soundEnabled {
                            run(wrongSound)
                        }

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
    
    
    func backToMenuWithDelay() {
        // Schedule the scene transition after a delay
        let delayAction = SKAction.wait(forDuration: 0.1)
        let transitionAction = SKAction.run { [weak self] in
            // Make sure self is still around and gameMenu is not nil
            guard let strongSelf = self, let gameMenu = strongSelf.gameMenu else {
                print("Self or gameMenu is nil, cannot transition")
                return
            }
            gameMenu.updateScoreBoxes()  // Update the score boxes
            
            // Ensure that the transition only occurs if the view is still available
            if let view = strongSelf.scene?.view {
                view.presentScene(gameMenu, transition: .crossFade(withDuration: 0.5))
            }
        }
        run(SKAction.sequence([delayAction, transitionAction]))
    }
    
    
    @objc func createWordStream() {
        if fallingBoxManager.letterList.count == 0 {
            stopEverything = true
        }
        if stopEverything == false {
            let size = CGSize(width: ((self.frame.width * 0.8) + 10) / (CGFloat(totalBoxes)), height: 122)
            fallingBoxManager.spawnFallingBox(parentNode: self, size: size)
        }
    }
    
    func saveDailyScore(_ score: Int, for date: String) {
        var scores = Settings.sharedInstance.dailyScores

        // Store today's score
        scores[date] = score

        // (Optionally) remove older than 30 entries
        // Easiest is to rely on chronological sorting of keys:
        let sortedDates = scores.keys.sorted()
        if sortedDates.count > 30 {
            let excess = sortedDates.count - 30
            let datesToRemove = sortedDates.prefix(excess)
            for d in datesToRemove {
                scores.removeValue(forKey: d)
            }
        }

        // Write back to UserDefaults
        Settings.sharedInstance.dailyScores = scores
    }

    
    func endGame() {
        
        for child in children {
            if currentWord!.letterList.contains(child.name ?? "") {
                child.removeFromParent()
            }
        }
        
        let finalScore = 10-score
        
        if finalScore > 0 {
            answerLabel.text = answerWord
            answerLabel.fontColor = .systemYellow
            
            if Settings.sharedInstance.soundEnabled {
                run(completeSound)
            }

        }

        spout1.isHidden = true
        spout2.isHidden = true
        
        if Settings.sharedInstance.playedToday == false {
            
            saveDailyScore(finalScore, for: currentWord.date)
            
            let newGKScore = GKScore(leaderboardIdentifier: "wuhba30dayscore")
            newGKScore.value = Int64(Settings.sharedInstance.getLast30DayScore())
            GKScore.report([newGKScore]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("New Score of \(Settings.sharedInstance.getLast30DayScore()) submitted to your Leaderboard!")
                }
            }

                        
            let userScore = FirebaseScore(date: currentWord.date, wuhbaNumber: currentWord.wuhbaNumber, score: finalScore)
            saveScore(userScore)
            
            if Settings.sharedInstance.highScore < finalScore {
                Settings.sharedInstance.highScore = finalScore
            }
            Settings.sharedInstance.playedToday = true

            // Log game completed event to Firebase Analytics
            Analytics.logEvent("game_completed", parameters: [
                "final_score": finalScore,
                "game_seconds": gameSeconds,
                "wuhba_number": currentWord!.wuhbaNumber
                
            ])
        }
        
        gameComplete = true
        wordTimer?.invalidate()
        removeItemsTimer?.invalidate()
        
        boxParent.removeAllChildren()
        boxParent.color = .white
        boxParent.run(SKAction.move(to: self.anchorPoint, duration: 0.5))
        boxParent.removeFromParent()
        answerLabel.fontName = "AvenirNext-Bold"
        answerLabel.fontSize = 36
        answerLabel.position.y = 42
        let fadeAction = SKAction.fadeIn(withDuration: 0.4)
        answerLabel.run(fadeAction)
        addChild(answerLabel)
        finalScoreBoxes()
        
        shareLabel.isHidden = false
        shareButton.isHidden = false
        
        //backToMenuWithDelay()
        
    }
    
    
    func finalScoreBoxes() {
        let baseX = self.frame.midX
        let baseY = 150.0
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
        scoreLabel.isHidden = false
        exitButton.isHidden = false
        
    }
    
    func saveScore(_ score: FirebaseScore) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not signed in")
            return
        }
        
        let ref = Database.database().reference().child("userScores").child(uid).child("scores").childByAutoId()
        ref.setValue(score.toDictionary) { error, _ in
            if let error = error {
                print("Error saving score: \(error.localizedDescription)")
            } else {
                print("Score successfully saved")
            }
        }
    }
    
    func setupScoreBoxes(){
        // access gamescene score nodes
        for i in 1...10 {
            if let square = self.childNode(withName: "\(i)") as? SKShapeNode {
                scoreSquares.append(square)
            }
        }
    }
    //
    
    @objc func removeItems(){
        gameSeconds += 1
        for child in children{
            if child.position.y < -self.size.height - 50{
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
            
            
            
            if let nodeName = atPoint(location).name {
                if nodeName == "shareButton"{
                    print("shareButton")
                    gameDelegate?.shareScore(score: 10-score, wuhbaNumber: currentWord!.wuhbaNumber)
                }
                
                if nodeName == "exitButton"{
                    print("exitButton")
                    backToMenuWithDelay()
                }
                if nodeName == "answerLabel"{
                    answerLabel.text = answerWord
                    answerLabel.fontColor = .systemYellow
                }
                
            }
            
            if stopEverything == false && gameComplete == false {
                let newAction = SKAction.moveTo(x: location.x, duration: 0.1)
                moveBoxAction = newAction
                boxParent.run(moveBoxAction)
            }
            
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
    
    
}
