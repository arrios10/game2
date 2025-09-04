//
//  GameMenu.swift
//  Game2
//  Created by Andrew Rios on 8/10/23.
//

import SpriteKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseAnalytics
import GameKit
import UIKit
import AVFoundation
import AVKit

private enum Constants {
    static let rotationDuration: TimeInterval = 0.42
    static let initialZRotation: CGFloat = -CGFloat.pi / 2
}

class GameMenu: SKScene, GKGameCenterControllerDelegate {
    
    
    weak var viewController: GameViewController?
    
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID

    var prefetchedTestWord: GameData?
    
    var scoreSquares: [SKShapeNode] = []
    var graySquares: [SKShapeNode] = []
    
    var score: Int = 0
    var totalScore: Int = 0
    
    var crashTestButton: SKLabelNode!
    var totalScoreLabel: SKLabelNode!

    var numberLabel: SKLabelNode!
    var checkBox = SKSpriteNode()
    var soundButton = SKSpriteNode()
    var scoreFlag: SKSpriteNode!


    private var boxParent = SKSpriteNode()
    var startGame = SKLabelNode()
    var startBox = SKShapeNode()
    var gameSettings = Settings.sharedInstance
    var gameVC: GameViewController!
    private var rotateAction: SKAction!
    private var repeatAction: SKAction!
    
    // Instructions popup elements
    private var instructionsOverlay = SKShapeNode()
    private var instructionsBackground = SKShapeNode()
    private var instructionsText = SKLabelNode()
    //private var instructionsVideoNode: SKVideoNode?
    //private var videoPlayer: AVPlayer?
    private var closeButton = SKLabelNode()
    private var isInstructionsVisible = false
    
    var gcEnabled = Bool() {
        didSet {
            if gcEnabled == true {
                scoreFlag.isHidden = false
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
    
    
        // Listen for the app returning to the foreground
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        authenticateLocalPlayer()
        
        checkBox = self.childNode(withName: "checkbox") as! SKSpriteNode
        checkBox.isHidden = true
        
        soundButton = self.childNode(withName: "speaker") as! SKSpriteNode
        numberLabel = self.childNode(withName: "wuhbaNumber") as? SKLabelNode
        totalScoreLabel = self.childNode(withName: "totalScoreLabel") as? SKLabelNode
        numberLabel.isHidden = true
        
        updateSoundIcon()
        
        // Setup instructions popup
        setupInstructionsPopup()

        setupStartBox()
        score = Settings.sharedInstance.highScore
        totalScore = Settings.sharedInstance.getLast30DayScore()
        totalScoreLabel.text = String(totalScore)
        setupScoreBoxes()
        
 
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        signIn { success in
            DispatchQueue.main.async {
                if success {
                    // proceed with fetching data or enabling game features
                    self.prefetchDataForCurrentDate()
                } else {
                    // handle sign-in failure (show an alert to the user)
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
                    if let gameData = self.prefetchedTestWord {
                        print("Using prefetched data: \(gameData.word)")
                        // Proceed to start the game with prefetched data
                        
                        // Log the event to Firebase Analytics
                        Analytics.logEvent("game_started", parameters: [
                            "date": gameData.date
                        ])
                        // Assuming your GameScene has a property called currentPhrase
                        if let gameScene = GameScene(fileNamed: "GameScene") {
                            gameScene.currentWord = gameData
                            gameScene.gameMenu = self
                            gameScene.gameDelegate = viewController
                            gameScene.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(gameScene, transition: .crossFade(withDuration: TimeInterval(0.5)))
                        }
                       
                        
                    } else {
                        self.prefetchDataForCurrentDate()
                    }
                
                case "highScore":
                    //show score history
                    print("fix later")
                    
                case "speaker":
                    Settings.sharedInstance.soundEnabled.toggle()
                    updateSoundIcon()

                case "crashTestButton":
                    // Deliberate crash
                    let numbers = [0]
                    let _ = numbers[1]
                    
                case "scoreFlag", "totalScoreLabel", "totalScore":
                    showLeaderBoard()
                    
                case "howtoplay":
                    showInstructionsPopup()
                
                case "closeInstructions":
                    hideInstructionsPopup()
        
                default:
                    break
                }
            }
        }
    }
    
    func updateSoundIcon() {
        if Settings.sharedInstance.soundEnabled {
            soundButton.texture = SKTexture(imageNamed: "speaker.png")
        } else {
            soundButton.texture = SKTexture(imageNamed: "mute.png")
        }
            }
    
    @objc func appDidBecomeActive() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        let lastPlayedDate = Settings.sharedInstance.getLastPlayedDate()

        // check if the current date is different from the last played date
        if lastPlayedDate != currentDate {
            Settings.sharedInstance.playedToday = false
            Settings.sharedInstance.saveLastPlayedDate(currentDate) // update last played date
            // date has changed, fetch the new phrase
            prefetchDataForCurrentDate()
        }
        
        // Update checkbox visibility after date logic has run
        updateCheckboxVisibility() 
    }

    deinit {
        // Clean up video player and notification observer
        //videoPlayer?.pause()
        NotificationCenter.default.removeObserver(self)
    }
    
    func prefetchDataForCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        
        FirebaseManager.shared.fetchGameData(byDate: currentDate) { fetchedTestPhrase in
            self.prefetchedTestWord = fetchedTestPhrase
            print("Data prefetched successfully.")
            self.readyToPlay(wuhbaNumber: self.prefetchedTestWord!.wuhbaNumber)
            
        }
        
    }
        
    func setupStartBox(){
        startGame = self.childNode(withName: "startGame") as! SKLabelNode
        
        startGame.text = "LOADING"
        
        startBox = self.childNode(withName: "startBox") as! SKShapeNode
        
        let pulseDownAction = SKAction.fadeAlpha(to: 0.1, duration: 1)
        let pulseUpAction = SKAction.fadeAlpha(to: 0.82, duration: 1.1)
        let pulseSequence = SKAction.sequence([pulseDownAction, pulseUpAction]) // Create the sequence
        repeatAction = SKAction.repeatForever(pulseSequence)
        startGame.run(repeatAction)

    }
    
    
    func readyToPlay(wuhbaNumber: Int) {
        DispatchQueue.main.async {
            self.startGame.removeAllActions()
            self.startGame.fontSize = 42
            self.startGame.alpha = 1
            self.startGame.fontColor = .systemYellow
            self.startGame.text = "PLAY"
            self.startBox.alpha = 1
            self.numberLabel.text = "WUHBA No. " + String(wuhbaNumber)
            self.numberLabel.isHidden = false
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
        
        // Update checkbox when returning from game
        updateCheckboxVisibility()
    }
    
    func resetScoreBoxes(){
        for square in scoreSquares{
            square.alpha = 1
        }
    }
    
    func updateCheckboxVisibility() {
        checkBox.isHidden = !Settings.sharedInstance.playedToday
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
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        //gcEnabled = localPlayer.isAuthenticated
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if let ViewController = ViewController {
                // 1. Show login if player is not logged in
                self.gameVC.present(ViewController, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if let error = error { print(error)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                //self.gcEnabled = false
                
                print("Local player could not be authenticated!")
                if let error = error {print(error)}
            }
        }
    }
    
    func showLeaderBoard() {
        let gcVC = GKGameCenterViewController()
        
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier? = "wuhba30dayscore"
        
        let viewController = self.view?.window?.rootViewController
        
        viewController?.present(gcVC, animated: true, completion: nil)
    }
    
    // MARK: - Instructions Popup Methods
//    private func setupInstructionsVideo(popupWidth: CGFloat, popupHeight: CGFloat) {
//        // Look for gameplay video in bundle
//        guard let videoPath = Bundle.main.path(forResource: "gameplay", ofType: "mp4") else {
//            print("No gameplay.mp4 video found in bundle")
//            return
//        }
//        
//        let videoURL = URL(fileURLWithPath: videoPath)
//        videoPlayer = AVPlayer(url: videoURL)
//        
//        // Create video node
//        let videoWidth: CGFloat = popupWidth - 40
//        let videoHeight: CGFloat = videoWidth
//        let videoSize = CGSize(width: videoWidth, height: videoHeight)
//        
//        instructionsVideoNode = SKVideoNode(avPlayer: videoPlayer!)
//        instructionsVideoNode!.size = videoSize
//        instructionsVideoNode!.position = CGPoint(x: 0, y: popupHeight/2 - videoHeight/2 - 60)
//        
//        // Set video to loop
//        NotificationCenter.default.addObserver(
//            forName: .AVPlayerItemDidPlayToEndTime,
//            object: videoPlayer!.currentItem,
//            queue: .main
//        ) { [weak self] _ in
//            self?.videoPlayer?.seek(to: .zero)
//            self?.videoPlayer?.play()
//        }
//        
//        instructionsBackground.addChild(instructionsVideoNode!)
//    }
    
    func setupInstructionsPopup() {
        // Semi-transparent overlay covering entire screen
        instructionsOverlay = SKShapeNode(rect: self.frame)
        instructionsOverlay.fillColor = UIColor.black.withAlphaComponent(0.55)
        instructionsOverlay.zPosition = 1000
        instructionsOverlay.isHidden = true
        
        // White rounded background for instructions (larger to accommodate video)
        let popupWidth: CGFloat = self.frame.width * 0.85
        let popupHeight: CGFloat = self.frame.height * 0.63
    
        instructionsBackground = SKShapeNode(rect: CGRect(x: -popupWidth/2, y: -popupHeight/2, width: popupWidth, height: popupHeight), cornerRadius: 10)
        instructionsBackground.fillColor = .black
        instructionsBackground.strokeColor = .black
        instructionsBackground.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 90)
        
        // Setup video player if video exists
        //setupInstructionsVideo(popupWidth: popupWidth, popupHeight: popupHeight)
        
        // Instructions text
        let instructionText = """
        HOW TO PLAY WUHBA
        
        • Letters fall from the top in random order
        • Move 5-box grid left and right
        • Catch the correct letter in each box
        • 10 wrong catches is game over
        • Complete the word and share your score
        
        30 DAY SCORE
        
        • Past 30-day scores are totaled
        • Score is 0 if you don’t play that day
        • Scores ranked on leaderboard
        
        Good luck!
        """
        
        instructionsText = SKLabelNode(text: instructionText)
        instructionsText.fontName = "AvenirNext-Medium"
        instructionsText.fontSize = 28
        instructionsText.fontColor = .white
        instructionsText.numberOfLines = 0
        instructionsText.preferredMaxLayoutWidth = popupWidth - 30
        instructionsText.verticalAlignmentMode = .center
        instructionsText.horizontalAlignmentMode = .center
        instructionsText.position = CGPoint(x: 0, y: -10)
        
        // Close button
        closeButton = SKLabelNode(text: "✕")
        closeButton.name = "closeInstructions"
        closeButton.fontName = "AvenirNext-Bold"
        closeButton.fontSize = 82
        closeButton.fontColor = .systemYellow
        closeButton.position = CGPoint(x: instructionsOverlay.position.x, y: -popupHeight/2 + 20)
        
        // Assemble popup
        instructionsBackground.addChild(instructionsText)
        instructionsBackground.addChild(closeButton)
        instructionsOverlay.addChild(instructionsBackground)
        
        self.addChild(instructionsOverlay)
    }
    
    func showInstructionsPopup() {
        guard !isInstructionsVisible else { return }
        isInstructionsVisible = true
        instructionsOverlay.isHidden = false
        
        // Start video playback if available
        //videoPlayer?.play()
        
        // Fade in animation
        instructionsOverlay.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        instructionsOverlay.run(fadeIn)
    }
    
    func hideInstructionsPopup() {
        guard isInstructionsVisible else { return }
        
        // Stop and pause video playback
        //videoPlayer?.pause()
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let hide = SKAction.run { [weak self] in
            self?.instructionsOverlay.isHidden = true
            self?.isInstructionsVisible = false
        }
        let sequence = SKAction.sequence([fadeOut, hide])
        instructionsOverlay.run(sequence)
    }

    
}
