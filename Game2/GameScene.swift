//
//  GameScene.swift
//  Game2
//
//  Created by Andrew Rios on 7/19/23.
//

import SpriteKit

class GameScene: SKScene {
    
    private var boxParent = SKSpriteNode()

    //var boxNodes = [SKShapeNode]() // This array will store references to all box nodes.
    var previousTouchPoint: CGPoint? // This will store the previous touch point.
    
    // Generate the boxes.
      let boxWidth: CGFloat = 150
      let gap: CGFloat = 13
    
    
    //falling box
    private weak var wordTimer: Timer?


    var stopEverything = false
    
    private weak var removeItemsTimer: Timer?

    let wordList = ["To", "Thine", "Own", "Self", "Be","True"]
    
    var totalBoxes: Int {
            return wordList.count
        }
    

    override func didMove(to view: SKView) {
            // Set up the parent node.
            self.addChild(boxParent)
        view.preferredFramesPerSecond = 120 // Set preferred FPS to 60

        
        print(Double(totalBoxes)/4)

            
            for i in 0..<totalBoxes {
                let box = SKShapeNode(rectOf: CGSize(width: boxWidth, height: 50))
                if i % 2 == 0 {
                    box.fillColor = .lightGray
                    
                } else {
                    box.fillColor = .white
                    
                }
                
                box.lineWidth = 0
                
                box.position.x = CGFloat(i) * (boxWidth + gap) - ((CGFloat(totalBoxes) * boxWidth + CGFloat(totalBoxes - 1) * gap) / 2) + (boxWidth / 2)
                boxParent.addChild(box)
                
                // Add a label to the box.
                let label = SKLabelNode(text: wordList[i])
                label.fontColor = .black
                label.fontSize = 25
                label.fontName = "Helvetica Neue Bold"
                //label.alpha = 0
                label.position = CGPoint(x: box.position.x, y: -10)  // position label relative to boxParent
                boxParent.addChild(label)  // add label to boxParent instead of box
                
                

            }
        
        if stopEverything == false {
            wordTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 1.3, secondNumber: 1.5)), target: self, selector: #selector(GameScene.createWordStream), userInfo: nil, repeats: true)
            removeItemsTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)

       }

            let totalWidth: CGFloat = CGFloat(totalBoxes) * boxWidth + CGFloat(totalBoxes - 1) * gap
            boxParent.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 250)
            boxParent.size.width = totalWidth
            boxParent.color = .white
        }
    

    @objc func createWordStream() {
        let size = CGSize(width: 100, height: 50)

        let wordStreamBox = SKSpriteNode(color: .white, size: size)
        let randomIndex = arc4random_uniform(UInt32(wordList.count))
        addChild(wordStreamBox)
        
        let label = SKLabelNode(text: wordList[Int(randomIndex)])
        label.fontColor = .black
        label.fontSize = 25
        label.fontName = "Helvetica Neue Bold"
        label.position = CGPoint(x: wordStreamBox.position.x, y: -10)
        wordStreamBox.addChild(label)
        
        wordStreamBox.position.y = 700
        
        if randomIndex % 2 == 0 {
            wordStreamBox.color = .lightGray
            
        } else {
            wordStreamBox.color = .white
            
        }
        
        wordStreamBox.physicsBody = SKPhysicsBody(rectangleOf: wordStreamBox.size)
        wordStreamBox.physicsBody?.linearDamping = 0.999
        
        var fruitsCopy = wordList
        
        
        if fruitsCopy.count == 0 {
            wordTimer?.invalidate()
            stopEverything = true

            
        }
        
        
    }

    
    @objc func removeItems(){
           for child in children{
               if child.position.y < -self.size.height - 100{
                   child.removeFromParent()
               }
           }
           
       }
    

    
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    
        //for touch in touches {
        //    let location = touch.location(in: self)
        //    boxParent.run(SKAction.moveTo(x: location.x, duration: 0.1))
        //}
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            boxParent.run(SKAction.moveTo(x: location.x, duration: 0.1))
        }
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            boxParent.run(SKAction.moveTo(x: location.x * 1.5, duration: 0.1))
        }

        
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }

    }
}
