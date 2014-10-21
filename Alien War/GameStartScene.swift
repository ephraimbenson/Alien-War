//
//  GameStartScene.swift
//  Alien War
//
//  Created by Ephraim Benson on 10/18/14.
//  Copyright (c) 2014 Ephraim Benson. All rights reserved.
//

import SpriteKit

class GameStartScene: SKScene {

    let titleLabel = SKLabelNode(fontNamed:"GillSans-Bold")
    var startButton = SKSpriteNode()
    var startButtonText = SKLabelNode()
    
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.blackColor()
        
        titleLabel.text = "Alien War Simulator";
        titleLabel.fontSize = 48;
        titleLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:size.height * 0.61);
        
        self.addChild(titleLabel)
        
        let startButtonTexture = SKTexture(imageNamed: "restartButton")
        startButtonTexture.filteringMode = .Nearest
        
        startButton = SKSpriteNode(texture: startButtonTexture)
        startButton.setScale(8)
        startButton.position = CGPointMake(CGRectGetMidX(frame), size.height * 0.3)
        self.addChild(startButton)
        
        startButtonText = SKLabelNode(fontNamed: "GillSans-Bold")
        startButtonText.position = CGPointMake(CGRectGetMidX(frame), startButton.position.y - 15)
        
        startButtonText.fontColor = UIColor.blackColor()
        startButtonText.fontSize = 38
        startButtonText.text = "Start"
        self.addChild(startButtonText)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let nodes = self.nodesAtPoint(touch.locationInNode(self))
            for node in nodes {
                // Present GameScene
                let trans = SKTransition.crossFadeWithDuration(0.5)
                let newScene = GameScene(size: self.scene!.size)
                self.view!.presentScene(newScene, transition: trans)
                NSNotificationCenter.defaultCenter().postNotificationName("DefaultVolume", object: self)

            }
        }
    }
}
