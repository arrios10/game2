//
//  GameMenu.swift
//  Game2
//
//  Created by Andrew Rios on 8/10/23.
//

import SpriteKit

class GameMenu: SKScene {
    
    private var boxParent = SKSpriteNode()
    let gap: CGFloat = 0
    var totalBoxes: Int = 0
    let boxPositions: [CGFloat] = [-244.0,-122.0,0.0,122.0,244.0]
    
    var startGame = SKLabelNode()
    var startBox = SKShapeNode()

    //var gameSettings = Settings.sharedInstance
    var gameVC: GameViewController!

    override func didMove(to view: SKView) {
        
        //let highScore = gameSettings.getHighScore()
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startGame = self.childNode(withName: "startGame") as! SKLabelNode
        
        //setupBoxes()

    }
    
    func setupBoxes() {
        let boxWidth = 122
        // setup word boxes
        for i in 0..<5 {

            // create word box
            let box = SKShapeNode(rectOf: CGSize(width: boxWidth, height: 122))
            
            box.position.x = boxPositions[i]
            
            
            // box properties
            box.strokeColor = .white
            box.lineWidth = 8

            boxParent.addChild(box)
       
        }
        // set parent box properties
        boxParent.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 250)
        boxParent.size.width = 122*5
        boxParent.color = .white
        addChild(boxParent)
        
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "startGame" || atPoint(touchLocation).name == "startBox" {

                let gameScene = GameScene(fileNamed: "GameScene")!
                gameScene.gameMenu = self
                gameScene.scaleMode = .aspectFill
                scene?.view?.presentScene(gameScene, transition: .crossFade(withDuration: TimeInterval(0.5)))
            }

        }
    }
    
  
    

    
    
    
}
