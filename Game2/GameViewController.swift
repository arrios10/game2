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
            if let scene = SKScene(fileNamed: "GameMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.preferredFramesPerSecond = 120  // Set your preferred FPS here.

            view.showsFPS = false
            view.showsNodeCount = false
            //view.showsPhysics = true
        }
        
        for family: String in UIFont.familyNames
               {
                   print(family)
                   for names: String in UIFont.fontNames(forFamilyName: family)
                   {
                       print("== \(names)")
                   }
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
