//
//  GameOverScene.swift
//  Alien War
//
//  Created by Ephraim Benson on 10/18/14.
//  Copyright (c) 2014 Ephraim Benson. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
	let font = "GillSans-Bold"
	var selectSound = SKAction()
    
    init(sz: CGSize, score: Int) {
		super.init(size: sz)
		
		let midpointX = CGRectGetMidX(frame)
		
		self.backgroundColor = UIColor.blackColor()
		let gameOverLabel = SKLabelNode(fontNamed: font)
		gameOverLabel.fontColor = UIColor.whiteColor()
		gameOverLabel.fontSize = 50
		gameOverLabel.text = "Game Over"
		gameOverLabel.position = CGPointMake(midpointX, size.height * 0.75)
		self.addChild(gameOverLabel)
		
		let currentScoreNode = SKLabelNode(fontNamed: font)
		currentScoreNode.position = CGPointMake(midpointX, size.height * 0.6)
		currentScoreNode.text = "Score: \(score)"
		self.addChild(currentScoreNode)
		
		let highScoreObj = HighScore(score: score)
		
		let theHighScore = highScoreObj.highScore
		
		let highScoreNode = SKLabelNode(fontNamed: font)
		highScoreNode.position = CGPointMake(midpointX, size.height * 0.45)
		highScoreNode.text = "High Score: \(theHighScore)"
		self.addChild(highScoreNode)
		
		selectSound = SKAction.playSoundFileNamed("select.wav", waitForCompletion: true)
		
        let restartTexture = SKTexture(imageNamed: "restartButton")
        restartTexture.filteringMode = .Nearest
        
        let restartButton = SKSpriteNode(texture: restartTexture)
        restartButton.setScale(8)
        restartButton.position = CGPointMake(CGRectGetMidX(frame), size.height * 0.25)
        restartButton.name = "RestartButton"
        restartButton.alpha = 0
        self.addChild(restartButton)
        
        let restartText = SKLabelNode(fontNamed: font)
        restartText.position = CGPointMake(restartButton.position.x, restartButton.position.y - 10)
        restartText.fontColor = UIColor.blackColor()
        restartText.text = "Restart"
        restartText.alpha = 0
        restartText.name = "RestartText"
        self.addChild(restartText)
        
        restartButton.runAction(SKAction.fadeInWithDuration(0.2))
        restartText.runAction(SKAction.fadeInWithDuration(0.2))
    }
	
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		let touch = touches.anyObject() as! UITouch
		let nodes = self.nodesAtPoint(touch.locationInNode(self))
		for node in nodes {
			if node.name? == "RestartText" || node.name? == "RestartButton" {
				node.runAction(selectSound, completion: {
					let trans = SKTransition.crossFadeWithDuration(0.5)
                    let newScene = GameScene(size: self.scene!.size)
					self.view!.presentScene(newScene, transition: trans)
                    NSNotificationCenter.defaultCenter().postNotificationName("DefaultVolume", object: self)
				})
			}
		}
	}
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}