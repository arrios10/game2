//
//  GameViewController.swift
//  Game2
//
//  Created by Andrew Rios on 7/19/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameMenu") as? GameMenu {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
            
                //scene.gameDelegate = self
                
                scene.viewController = self // Add a property `viewController` to your GameMenu to hold this

                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.preferredFramesPerSecond = 120  // Set your preferred FPS here.

            view.showsFPS = false
            view.showsNodeCount = false
            //view.showsPhysics = true
        }
        
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
///Users/andrewrios/Dev/Game2/Game2/GameViewController.swift:56:10 Instance method 'shareScore(score:wuhbaNumer:)' has different argument labels from those required by protocol 'GameSceneDelegate' ('shareScore(score:wuhbaNumber:)')


extension GameViewController: GameSceneDelegate {
    func shareScore(score: Int, wuhbaNumber: Int) {
        let scoreEmojiString = emojiScoreString(forScore: score)
        
        let scoreMessage = "\(score)/10. Wuhba \(wuhbaNumber). \(scoreEmojiString) @playWuhba"
        let activityViewController = UIActivityViewController(activityItems: [scoreMessage], applicationActivities: nil)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func emojiScoreString(forScore score: Int) -> String {
        // Define the emojis for each color box
        let orangeBox = "\u{1F7E7}"
        let yellowBox = "\u{1F7E8}"
        let greenBox = "\u{1F7E9}"
        let blueBox = "\u{1F7E6}"
        let purpleBox = "\u{1F7EA}"
        let blackBox = "\u{2B1B}"
        
        // The maximum number of each colored box
        let maxColorBoxes = 2
        let totalBoxes = 10

        // Calculate the number of colored boxes based on the score
        let numOrange = min(maxColorBoxes, score)
        let numYellow = max(0, min(maxColorBoxes, score - numOrange))
        let numGreen = max(0, min(maxColorBoxes, score - (numOrange + numYellow)))
        let numBlue = max(0, min(maxColorBoxes, score - (numOrange + numYellow + numGreen)))
        let numPurple = score == 9 ? 1 : (score == totalBoxes ? maxColorBoxes : 0)

        // Calculate the number of black boxes
        let numBlack = totalBoxes - (numOrange + numYellow + numGreen + numBlue + numPurple)
        
        // Build the string with the colored and black boxes
        let scoreString = String(repeating: orangeBox, count: numOrange) +
                          String(repeating: yellowBox, count: numYellow) +
                          String(repeating: greenBox, count: numGreen) +
                          String(repeating: blueBox, count: numBlue) +
                          String(repeating: purpleBox, count: numPurple) +
                          String(repeating: blackBox, count: numBlack)
        return scoreString
    }
}

   


