//
//  GameMenu.swift
//  Game2
//
//  Created by Andrew Rios on 8/10/23.
//

import SpriteKit
import Firebase
import FirebaseAuth

class GameMenu: SKScene {
    
    var crashTestButton: SKLabelNode!
    
    private var boxParent = SKSpriteNode()
    
    var startGame = SKLabelNode()
    var startBox = SKShapeNode()
    
    //var gameSettings = Settings.sharedInstance
    var gameVC: GameViewController!
    
    override func didMove(to view: SKView) {
        signIn() 
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startGame = self.childNode(withName: "startGame") as! SKLabelNode
        
        // Initialize crashTestButton
        crashTestButton = SKLabelNode(fontNamed: "Avenir")
        crashTestButton.text = "Test Crash"
        crashTestButton.fontSize = 20
        crashTestButton.fontColor = .red
        crashTestButton.position = CGPoint(x: 0, y: -50) // Adjust this position as needed
        crashTestButton.name = "crashTestButton"
        addChild(crashTestButton)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)

            if let nodeName = atPoint(touchLocation).name {
                switch nodeName {
                case "startGame", "startBox":
                    // Log the event to Firebase Analytics
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterItemID: "id-StartGame",
                        AnalyticsParameterItemName: "StartGame",
                        AnalyticsParameterContentType: "menuOption",
                    ])

                    let randomIndex = Int(arc4random_uniform(UInt32(16)))
                    FirebaseManager.shared.fetchTestPhrase(wuhbaNumber: randomIndex) { fetchedTestPhrase in
                        print("Successfully reached call")

                        if let fetchedTestPhrase = fetchedTestPhrase {
                            print("Successfully fetched: \(fetchedTestPhrase.phrase)")

                            // Assuming your GameScene has a property called currentPhrase
                            let gameScene = GameScene(fileNamed: "GameScene")!
                            gameScene.currentPhrase = fetchedTestPhrase
                            gameScene.gameMenu = self
                            gameScene.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(gameScene, transition: .crossFade(withDuration: TimeInterval(0.5)))

                        } else {
                            print("Failed to fetch for wuhbaNumber: \(randomIndex)")
                        }
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

    
    
    func signIn() {
        if Auth.auth().currentUser == nil {
            Task {
                do {
                    try await Auth.auth().signInAnonymously()
                }
                catch {
                    print (error.localizedDescription)
                }
            }
        }
        else {
            print("Someone is signed in.")
            if let user = Auth.auth().currentUser {
                print(user.uid)
            }
        }
    }
}
