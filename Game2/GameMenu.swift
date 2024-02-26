//
//  GameMenu.swift
//  Game2
//
//  Created by Andrew Rios on 8/10/23.
//

import SpriteKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

private enum Constants {
    static let rotationDuration: TimeInterval = 0.42
    static let initialZRotation: CGFloat = -CGFloat.pi / 2
}


class GameMenu: SKScene {
    
    var prefetchedTestPhrase: TestPhrases?
    
    var scoreSquares: [SKShapeNode] = []
    var graySquares: [SKShapeNode] = []
    
    var score: Int = 0
    
    var crashTestButton: SKLabelNode!
    private var boxParent = SKSpriteNode()
    var startGame = SKLabelNode()
    var startBox = SKShapeNode()
    var gameSettings = Settings.sharedInstance
    var gameVC: GameViewController!
    private var rotateAction: SKAction!
    private var repeatAction: SKAction!
    
    
    override func didMove(to view: SKView) {
        setupStartBox()
        score = gameSettings.getHighScore()
        setupScoreBoxes()
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        signIn { success in
            DispatchQueue.main.async {
                if success {
                    // Proceed with fetching data or enabling game features
                    self.prefetchDataForCurrentDate()
                } else {
                    // Handle sign-in failure (e.g., show an alert to the user)
                    self.showSignInErrorAlert()
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            if let nodeName = atPoint(touchLocation).name {
                switch nodeName {
                case "startGame", "startBox":
                    if let fetchedTestPhrase = self.prefetchedTestPhrase {
                        print("Using prefetched data: \(fetchedTestPhrase.phrase)")
                        // Proceed to start the game with prefetched data
                        
                        // Log the event to Firebase Analytics
                        Analytics.logEvent("game_started", parameters: [
                            "date": fetchedTestPhrase.date
                        ])
                        // Assuming your GameScene has a property called currentPhrase
                        let gameScene = GameScene(fileNamed: "GameScene")!
                        gameScene.currentPhrase = fetchedTestPhrase
                        gameScene.gameMenu = self
                        gameScene.scaleMode = .aspectFill
                        self.scene?.view?.presentScene(gameScene, transition: .crossFade(withDuration: TimeInterval(0.5)))
                        
                    } else {
                        self.prefetchDataForCurrentDate()
                    }
                    
                    
                case "crashTestButton":
                    // Deliberate crash
                    let numbers = [0]
                    let _ = numbers[1]
                    
                default:
                    break
                }
            }
        }
    }
    
    func prefetchDataForCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        
        FirebaseManager.shared.fetchTestPhrase(byDate: currentDate) { fetchedTestPhrase in
            self.prefetchedTestPhrase = fetchedTestPhrase
            print("Data prefetched successfully.")
            self.setupStartButton()
            
            
        }
        
    }
    
    func setupStartBox(){
        startGame = self.childNode(withName: "startGame") as! SKLabelNode
        
        startGame.text = "LOADING"
        
        startBox = self.childNode(withName: "startBox") as! SKShapeNode
        
        rotateAction = SKAction.rotate(byAngle: Constants.initialZRotation, duration: Constants.rotationDuration) // Rotate 90 degrees over 1 second
        repeatAction = SKAction.repeatForever(rotateAction)
        startBox.run(repeatAction)
        
    }
    
    
    func setupStartButton() {
        DispatchQueue.main.async {
            self.startBox.removeAllActions()
            self.startBox.zRotation = Constants.initialZRotation
            self.startGame.fontSize = 42
            self.startGame.text = "PLAY"
        }
    }
    
    func signIn(completion: @escaping (Bool) -> Void) {
        // Check if a user is already signed in
        if Auth.auth().currentUser != nil {
            print("User is already signed in.")
            print("user: " + Auth.auth().currentUser!.uid)
            completion(true) // Indicate success as the user is already signed in
            return
        }
        
        // Attempt to sign in anonymously
        Task {
            do {
                try await Auth.auth().signInAnonymously()
                print("User signed in anonymously.")
                print("user: " + Auth.auth().currentUser!.uid)
                completion(true) // Sign-in successful
            } catch {
                print("Failed to sign in: \(error.localizedDescription)")
                completion(false) // Sign-in failed, pass false to indicate failure
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
        updateScoreBoxes()
        
    }
    
    func updateScoreBoxes(){
        resetScoreBoxes()
        for i in stride(from: 0, to: 10-score, by: 1) {
            let element = scoreSquares[i]
            element.alpha = 0
        }
    }
    
    func resetScoreBoxes(){
        for square in scoreSquares{
            square.alpha = 1
        }
    }
    
    func showSignInErrorAlert(){
        print("SignInErrorAlert")
    }
    
    // for crash testing
    func setupCrashButton(){
        
        // Initialize crashTestButton
        crashTestButton = SKLabelNode(fontNamed: "Avenir")
        crashTestButton.text = "Test Crash"
        crashTestButton.fontSize = 20
        crashTestButton.fontColor = .red
        crashTestButton.position = CGPoint(x: 0, y: -50) // Adjust this position as needed
        crashTestButton.name = "crashTestButton"
        addChild(crashTestButton)
        
    }
    
    
    // for test phrases
    func uploadTestData() {
        // Initialize a DatabaseReference
        let ref = Database.database().reference()
        
        // Your test data
        let testPhrases: [TestPhrases] = [
            
            TestPhrases(phrase: "Time is now, or never.", wordList: ["Time", "Is", "Now","Or", "Never"], source: "", notes: "", wordCount: 5, wuhbaNumber: 1, date: "2024-02-24"),
            
            TestPhrases(phrase: "Action is its own reward.", wordList: ["Action", "Is", "Its", "Own", "Reward"], source: "", notes: "", wordCount: 5, wuhbaNumber: 2, date: "2024-02-25"),
            
            TestPhrases(phrase: "As I think, I am.", wordList: ["As", "I", "Think", "I", "Am"], source: "", notes: "", wordCount: 5, wuhbaNumber: 3, date: "2024-02-26"),
            
            TestPhrases(phrase: "What is above, is below.", wordList: ["What", "Is", "Above", "Is", "Below"], source: "", notes: "", wordCount: 5, wuhbaNumber: 4, date: "2024-02-27"),
            
            TestPhrases(phrase: "This phrase is not true.", wordList: ["This", "Phrase", "Is", "Not", "True"], source: "", notes: "", wordCount: 5, wuhbaNumber: 5, date: "2024-02-28"),
            
            TestPhrases(phrase: "I think, so I will.", wordList: ["I", "Think", "So", "I", "Will"], source: "", notes: "", wordCount: 5, wuhbaNumber: 6, date: "2024-03-01"),
            
            TestPhrases(phrase: "Kind words unlock iron doors.", wordList: ["Kind", "Words", "Unlock", "Iron", "Doors"], source: "", notes: "", wordCount: 5, wuhbaNumber: 7, date: "2024-03-02"),
            
            TestPhrases(phrase: "Last mile is the longest.", wordList: ["Last", "Mile", "Is", "The", "Longest"], source: "", notes: "", wordCount: 5, wuhbaNumber: 8, date: "2024-03-03"),
            
            TestPhrases(phrase: "Make a long story short.", wordList: ["Make", "A", "Long", "Story", "Short"], source: "", notes: "", wordCount: 5, wuhbaNumber: 9, date: "2024-03-04"),
            
            TestPhrases(phrase: "My habits are my base.", wordList: ["My", "Habits", "Are", "My", "Base"], source: "", notes: "", wordCount: 5, wuhbaNumber: 10, date: "2024-03-05"),
            
            
        ]
        
        for phrase in testPhrases {
            // Create a Dictionary representation of your object
            print(phrase)
            let phraseDict: [String : Any] = [
                "phrase": phrase.phrase,
                "wordList": phrase.wordList,
                "source": phrase.source,
                "notes": phrase.notes,
                "wordCount": phrase.wordCount,
                "wuhbaNumber": phrase.wuhbaNumber,
                "date": phrase.date
            ]
            
            // Generate a new child location using a unique key and save the Dictionary into it
            ref.child("testPhrases").child("\(phrase.wuhbaNumber)").setValue(phraseDict)
        }
    }
    
}
