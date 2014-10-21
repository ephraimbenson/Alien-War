//
//  GameScene.swift
//  Alien War
//
//  Created by Ephraim Benson on 10/18/14.
//  Copyright (c) 2014 Ephraim Benson. All rights reserved.
//

// test

import SpriteKit
import Foundation
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMoveToView(view: SKView) {
        
        println("Width: \(self.size.width), Height: \(self.size.height)")
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self,
                selector: "pauseGame",
                name: "applicationWillResignActive",
                object: nil)
        setupScene()
        
        startDelayTimer()
    }
    
    func startDelayTimer() {
        delayTimer.invalidate()
        let timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "decreaseDelay", userInfo: nil, repeats: true)
        delayTimer = timer
    }
    
    func decreaseDelay() {
        if alienSpawnDelay < 0.2 {
            alienSpawnDelay = 0.1
        } else {
            alienSpawnDelay -= 0.05
        }
        println("Delay: \(alienSpawnDelay)")
        
        alienSpawnTimer.invalidate()
        let timer = NSTimer.scheduledTimerWithTimeInterval(alienSpawnDelay, target: self, selector: "createAlien", userInfo: nil, repeats: true)
        alienSpawnTimer = timer
    }
    
    func createAlien() {
        var newAlien = SKSpriteNode()
        if drand48() <= 0.125 {
            newAlien = ZigZagAlien(screenSize: self.size)
        } else {
            newAlien = StandardAlien(screenSize: self.size)
        }
        newAlien.zPosition = self.alienZPos
        newAlien.physicsBody?.categoryBitMask = alienCategory
        newAlien.physicsBody?.categoryBitMask = alienCategory
        newAlien.physicsBody?.collisionBitMask = 0
        scene?.addChild(newAlien)
    }
    
    func createBullet() {
        let newBullet = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(3, 30))
        newBullet.name = "Bullet"
        newBullet.position = CGPointMake(spaceship.position.x, spaceship.position.y + spaceship.size.height / 2 + newBullet.size.height / 2)
        newBullet.zPosition = bulletZPos
        newBullet.physicsBody = SKPhysicsBody(rectangleOfSize: newBullet.size)
        newBullet.physicsBody?.categoryBitMask = self.bulletCategory
        newBullet.physicsBody?.contactTestBitMask = self.alienCategory | self.alienPartCategory
        newBullet.physicsBody?.collisionBitMask = 0
        
        scene?.addChild(newBullet)
        
        let bulletMovement = SKAction.moveToY(size.height + newBullet.size.height, duration: 1)
        newBullet.runAction(SKAction.group([bulletSound, bulletMovement]), completion: { newBullet.removeFromParent() })
    }
    
    func alienDeath(alien: SKNode, textureArray: [SKTexture]) {
        let lArmSprite = SKSpriteNode(texture: textureArray[0])
        let rArmSprite = SKSpriteNode(texture: textureArray[0])
        let TLSprite = SKSpriteNode(texture: textureArray[1])
        let TRSprite = SKSpriteNode(texture: textureArray[2])
        let BLSprite = SKSpriteNode(texture: textureArray[3])
        let BRSprite = SKSpriteNode(texture: textureArray[4])
        
        TLSprite.position = CGPointMake(alien.position.x - 10, alien.position.y)
        TRSprite.position = CGPointMake(TLSprite.position.x + TLSprite.size.width, TLSprite.position.y)
        BLSprite.position = CGPointMake(TLSprite.position.x - 1, TLSprite.position.y - TLSprite.size.height)
        BRSprite.position = CGPointMake(BLSprite.position.x + BLSprite.size.width, BLSprite.position.y)
        lArmSprite.position = CGPointMake(TLSprite.position.x - 12, TLSprite.position.y + 5)
        rArmSprite.position = CGPointMake(TRSprite.position.x + 12, TRSprite.position.y + 5)
        
        let partArray = [lArmSprite, rArmSprite, TLSprite, TRSprite, BLSprite, BRSprite]
        var n = 0
        for part in partArray {
            switch n {
            case 0:
                part.name = "APArmL"
            case 1:
                part.name = "APArmR"
            case 2:
                part.name = "APTL"
            case 3:
                part.name = "APTR"
            case 4:
                part.name = "APBL"
            case 5:
                part.name = "APBR"
            default:
                part.name = "alienPart"
            }
            n += 1
            /*
            let destination = getAlienPartDestination(part)
            let dur = getAlienPartDuration(part, destination: destination)
            part.runAction(SKAction.moveTo(destination, duration: dur), completion: { part.removeFromParent() })
            */
            
            part.setScale(2)
            
            part.physicsBody = SKPhysicsBody(rectangleOfSize: part.size)
            part.physicsBody?.categoryBitMask = alienPartCategory
            part.physicsBody?.collisionBitMask = alienPartCategory
            self.scene?.addChild(part)
        }
        
        alien.removeFromParent()
        
        //
        TLSprite.physicsBody?.applyImpulse(CGVectorMake(-randomVelocity, randomVelocity))
        TRSprite.physicsBody?.applyImpulse(CGVectorMake(randomVelocity, randomVelocity))
        BLSprite.physicsBody?.applyImpulse(CGVectorMake(-randomVelocity, randomVelocityLow))
        BRSprite.physicsBody?.applyImpulse(CGVectorMake(randomVelocity, randomVelocityLow))
        
        lArmSprite.physicsBody?.applyImpulse(CGVectorMake(-1.5, 1.5))
        rArmSprite.physicsBody?.applyImpulse(CGVectorMake(1.5, 1.5))
        
    }
    
    func pauseGame() {
        if gameIsPaused == true {
            return
        }
        println("Game Paused")
        gameIsPaused = true
        delayTimer.invalidate()
        alienSpawnTimer.invalidate()
        
        pauseButton.hidden = true; resumeButton.hidden = false; resumeButtonLabel.hidden = false;
        
        // Pause All Nodes
        self.paused = true
        self.enumerateChildNodesWithName("*") {
            node, stop in
            node.speed = 0.0
        }
        NSNotificationCenter.defaultCenter().postNotificationName("PauseMusic", object: self)
    }
    
    func resumeGame() {
        if gameIsPaused == false {
            return
        }
        gameIsPaused = false
        startDelayTimer()
        resumeButton.hidden = true; resumeButtonLabel.hidden = true; pauseButton.hidden = false
        
        // Resume All Nodes
        self.paused = false
        self.enumerateChildNodesWithName("*") {
            node, stop in
            node.speed = 1.0
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("ResumeMusic", object: self)
    }
    
    func gameOver() {
        shipIsDestroyed = true
        
        NSNotificationCenter.defaultCenter().postNotificationName("DecreaseVolume", object: self)
        
        let explosion = SKSpriteNode(texture: shipExplosionFrames[0])
        explosion.position = spaceship.position
        explosion.setScale(3.25)
        explosion.zPosition = explosionZPos
        scene?.addChild(explosion)
        self.spaceship.removeFromParent()
        let explosionAnimation = SKAction.animateWithTextures(shipExplosionFrames, timePerFrame: 0.075)
        explosion.runAction(SKAction.group([explosionAnimation, explosionSound]), completion: {
            let gameOver = GameOverScene(sz: self.scene!.size, score: self.playerScore)
            self.view?.presentScene(gameOver, transition: SKTransition.crossFadeWithDuration(0.5))
        })
    }
    
    func moveBackground() {
        if gameIsPaused == true {
            return
        }
        
        if arc4random_uniform(2) == 0 {
            let x = arc4random_uniform(UInt32(self.size.width))
            let newStar = SKSpriteNode(color: UIColor(red: 255, green: 255, blue: 255, alpha: 0.5), size: CGSizeMake(2, 50))
            newStar.position = CGPointMake(CGFloat(x), self.size.height + newStar.size.height / 2)
            newStar.zPosition = starZPos
            scene?.addChild(newStar)
            newStar.runAction(SKAction.moveToY(-newStar.size.height / 2, duration: 0.5), completion: {
                newStar.removeFromParent()
            })
        }
    }
    
    func getAlienPartDestination(alienpart: SKSpriteNode) -> CGPoint {
        var coordX = CGFloat()
        var coordY = CGFloat()
        
        // MARK: BAD_ACCESS error
        // Issue with accessing alien parts
        if alienpart.name? != nil {
            println(alienpart.name!)
            var charCount = alienpart.name!.utf16Count
            var alienLocation = alienpart.name?.substringFromIndex(advance(alienpart.name!.startIndex, charCount - 1))
            
            if alienLocation == "L" {
                coordX = CGFloat(UInt32(alienpart.position.x) - arc4random_uniform(alienPartMaxDisplacement))
            } else if alienLocation == "R" {
                coordX = CGFloat(UInt32(alienpart.position.x) + arc4random_uniform(alienPartMaxDisplacement))
            }
        }
        coordY = self.size.height
        return CGPointMake(coordX, coordY)
    }
    
    func getAlienPartDuration(alienpart: SKSpriteNode, destination: CGPoint) -> NSTimeInterval {
        let dx = pow(destination.x - alienpart.position.x, 2)
        let dy = pow(destination.y - alienpart.position.y, 2)
        let duration = Double(sqrt(dx + dy))
        return duration / alienPartPPS
    }
    
    // MARK: - Event Handling
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // Don't handle touch events if gameOver() has started
        if shipIsDestroyed == true {
            return
        }
        
        for touch: AnyObject in touches {
            let nodes = self.nodesAtPoint(touch.locationInNode(self))
            for node in nodes {
                // Pause game if scoreArea is tapped
                if node as SKNode == scoreArea {
                    pauseGame()
                    return
                }
            }
            let location = touch.locationInNode(self)
            if location.x > screenCenter.x && location.y < self.size.height - 25 {
                // Bullets can only be fired if the game isn't paused
                if self.paused == false {
                    createBullet()
                }
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)  {
        if gameIsPaused == true {
            return
        }
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let prevLocation = touch.previousLocationInNode(self)
            if location.x < screenCenter.x && self.paused == false {
                shipShouldMove = true
                if location.x > prevLocation.x {
                    shipDirectionRight = true
                } else if location.x < prevLocation.x {
                    shipDirectionRight = false
                }
            } else if location.x > screenCenter.x && prevLocation.x < screenCenter.x {
                shipShouldMove = false
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let nodes = self.nodesAtPoint(touch.locationInNode(self))
            for node in nodes {
                // Resume game
                if node as SKNode == resumeButton || node as SKNode == resumeButtonLabel {
                    resumeGame()
                    return
                }
            }
            
            if touch.locationInNode(self).x < screenCenter.x {
                shipShouldMove = false
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        let bodies = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if bodies == alienCategory | bulletCategory {
            // Bullet and Alien
            // Send alienDeath: the texture array that corresponds to its color
            if contact.bodyA.node?.name == "StandardAlien" {
                alienDeath(contact.bodyA.node!, textureArray: alienPartsTexturesGreen)
                contact.bodyB.node!.removeFromParent()
            } else if contact.bodyA.node!.name == "ZigZagAlien" {
                alienDeath(contact.bodyA.node!, textureArray: alienPartsTexturesRed)
                contact.bodyB.node!.removeFromParent()
            } else if contact.bodyB.node!.name == "StandardAlien" {
                alienDeath(contact.bodyB.node!, textureArray: alienPartsTexturesGreen)
                contact.bodyA.node!.removeFromParent()
            } else if contact.bodyB.node!.name == "ZigZagAlien" {
                alienDeath(contact.bodyB.node!, textureArray: alienPartsTexturesRed)
                contact.bodyA.node!.removeFromParent()
            }
            contact.bodyB.node?.removeFromParent()
            spaceship.runAction(hitSound)
            playerScore += alienPointValue
        } else if bodies == spaceshipCategory | alienCategory {
            gameOver()
        } else if bodies == bulletCategory | alienPartCategory {
            // Bullet and alien part
            let partExplosion = SKSpriteNode(texture: partExplosionFrames[0])
            partExplosion.setScale(2)
            partExplosion.position = contact.bodyB.node!.position
            partExplosion.position = contact.bodyB.node!.position
            scene?.addChild(partExplosion)
            partExplosion.runAction(hitPartSound)
            partExplosion.runAction(SKAction.animateWithTextures(partExplosionFrames, timePerFrame: 0.1), completion: {
                partExplosion.removeFromParent()
            })
            contact.bodyA.node!.removeFromParent(); contact.bodyB.node!.removeFromParent()
            playerScore += alienPartPointValue
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        moveBackground()
        
        // Remove Off-screen alienPart nodes
        // Alien and Bullet removal is handled by their SKActions
        self.enumerateChildNodesWithName("alienPart") { node, stop in
            if node.position.x < 0 || node.position.x > self.size.width || node.position.y > self.size.height {
                node.removeFromParent()
            }
        }
        
        scoreCounter.text = "Score: \(playerScore)"
        
        if shipShouldMove && self.paused == false {
            if shipDirectionRight {
                spaceship.runAction(SKAction.moveByX(shipSpeed, y: 0, duration: 0.1))
            } else {
                spaceship.runAction(SKAction.moveByX(-shipSpeed, y: 0, duration: 0.1))
            }
        }
    }
    
    // MARK: - Setup
    func setupScene() {
        self.backgroundColor = UIColor.blackColor()
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = borderCategory
        
        scoreArea = SKSpriteNode(color: UIColor.grayColor(), size: CGSizeMake(size.width, 25))
        scoreArea.anchorPoint = CGPointMake(0, 1)
        scoreArea.position = CGPointMake(0, size.height)
        scoreArea.zPosition = scoreZPos
        scoreArea.name = "pauseArea"
        self.addChild(scoreArea)
        
        scoreCounter.position = CGPointMake(size.width / 2, size.height - 20)
        scoreCounter.fontColor = UIColor.blackColor()
        scoreCounter.fontSize = 20
        scoreCounter.zPosition = scoreZPos
        self.addChild(scoreCounter)
        
        pauseButton.anchorPoint = CGPoint(x: 1, y: 1)
        pauseButton.position = CGPointMake(scene!.size.width - 2.5, scene!.size.height - 2.5)
        pauseButton.zPosition = pauseButtonZPos
        self.addChild(pauseButton)
        
        let resumeTexture = SKTexture(imageNamed: "restartButton")
        resumeTexture.filteringMode = .Nearest
        resumeButton = SKSpriteNode(texture: resumeTexture)
        resumeButton.setScale(7)
        resumeButton.position = self.screenCenter
        resumeButton.zPosition = pauseButtonZPos
        resumeButton.name = "resumeButton"
        resumeButton.hidden = true
        self.addChild(resumeButton)
        
        resumeButtonLabel.position = CGPointMake(resumeButton.position.x, resumeButton.position.y - 10)
        resumeButtonLabel.text = "Resume"
        resumeButtonLabel.fontSize = 28
        resumeButtonLabel.fontColor = UIColor.blackColor()
        resumeButtonLabel.zPosition = pauseTextZPos
        resumeButtonLabel.name = "resumeButtonLabel"
        resumeButtonLabel.hidden = true
        self.addChild(resumeButtonLabel)
        
        let spaceshipAtlas = SKTextureAtlas(named: "spaceship")
        var spaceshipFrames = [SKTexture]()
        
        var numImages = spaceshipAtlas.textureNames.count
        for var i = 1; i <= numImages; ++i {
            let textureName = "spaceship\(i)"
            let temp = spaceshipAtlas.textureNamed(textureName)
            spaceshipFrames.append(temp)
        }
        
        for texture in spaceshipFrames {
            texture.filteringMode = .Nearest
        }
        
        spaceship = SKSpriteNode(texture: spaceshipFrames[0])
        spaceship.setScale(3.157894737)
        spaceship.position = CGPointMake(screenCenter.x, spaceship.size.height / 2)
        spaceship.zPosition = shipZPos
        /* Update this to fit the sprite better */
        spaceship.physicsBody = SKPhysicsBody(rectangleOfSize: spaceship.size)
        spaceship.physicsBody?.categoryBitMask = spaceshipCategory
        spaceship.physicsBody?.collisionBitMask = borderCategory | alienCategory
        spaceship.physicsBody?.contactTestBitMask = alienCategory
        
        spaceship.physicsBody?.allowsRotation = false
        
        scene?.addChild(spaceship)
        spaceship.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(spaceshipFrames, timePerFrame: 0.2)))
        
        let shipExplosionAtlas = SKTextureAtlas(named: "shipExplosion")
        for var i = 1; i <= shipExplosionAtlas.textureNames.count; ++i {
            let textureName = "shipExplosion\(i)"
            let temp = shipExplosionAtlas.textureNamed(textureName)
            shipExplosionFrames.append(temp)
        }
        for texture in shipExplosionFrames {
            texture.filteringMode = .Nearest
        }
        
        alienPartsTexturesGreen = [alienArmTextureGreen, alienTLTextureGreen, alienTRTextureGreen, alienBLTexureGreen, alienBRTextureGreen]
        for texture in alienPartsTexturesGreen {
            texture.filteringMode = .Nearest
        }
        alienPartsTexturesRed = [alienArmTexureRed, alienTLTextureRed, alienTRTextureRed, alienBLTextureRed, alienBRTextureRed]
        for texture in alienPartsTexturesRed {
            texture.filteringMode = .Nearest
        }
        
        let partExplosionAtlas = SKTextureAtlas(named: "partExplosion")
        for var i = 1; i <= partExplosionAtlas.textureNames.count; ++i {
            let textureName = "partExplosion\(i)"
            let temp = partExplosionAtlas.textureNamed(textureName)
            partExplosionFrames.append(temp)
        }
        for frame in partExplosionFrames {
            frame.filteringMode = .Nearest
        }
    }
    
    // MARK: - Properties
    
    // Timers
    var alienSpawnDelay: NSTimeInterval = 1
    
    var delayTimer = NSTimer()
    var alienSpawnTimer = NSTimer()
    
    // Sprites 'n Stuff
    var scoreArea = SKSpriteNode()
    
    let pauseButton = SKSpriteNode(imageNamed: "pauseButton.png")
    var resumeButton = SKSpriteNode()
    let resumeButtonLabel = SKLabelNode(fontNamed: "GillSans-Bold")
    
    var spaceship = SKSpriteNode()
    
    var shipExplosionFrames = [SKTexture]()
    var partExplosionFrames = [SKTexture]()
    
    let scoreCounter = SKLabelNode(fontNamed: "GillSans-Bold")
    
    // -Alien Parts Green
    let alienArmTextureGreen = SKTexture(imageNamed: "alienArmGreen")
    let alienBLTexureGreen = SKTexture(imageNamed: "alienBLGreen")
    let alienBRTextureGreen = SKTexture(imageNamed: "alienBRGreen")
    let alienTLTextureGreen = SKTexture(imageNamed: "alienTLGreen")
    let alienTRTextureGreen = SKTexture(imageNamed: "alienTRGreen")
    var alienPartsTexturesGreen = [SKTexture]()
    // -Alien Parts Red
    let alienArmTexureRed = SKTexture(imageNamed: "alienArmRed")
    let alienBLTextureRed = SKTexture(imageNamed: "alienBLRed")
    let alienBRTextureRed = SKTexture(imageNamed: "alienBRRed")
    let alienTLTextureRed = SKTexture(imageNamed: "alienTLRed")
    let alienTRTextureRed = SKTexture(imageNamed: "alienTRRed")
    var alienPartsTexturesRed = [SKTexture]()
    
    // Body Categories
    let borderCategory: UInt32 = 0x1 << 1
    let spaceshipCategory: UInt32 = 0x1 << 2
    let alienCategory: UInt32 = 0x1 << 3
    let bulletCategory: UInt32 = 0x1 << 4
    let alienPartCategory: UInt32 = 0x1 << 5
    
    
    // Sound Effects
    let bulletSound = SKAction.playSoundFileNamed("bullet.wav", waitForCompletion: false)
    let hitSound = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
    let hitPartSound = SKAction.playSoundFileNamed("hitPart.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    let selectSound = SKAction.playSoundFileNamed("select.wav", waitForCompletion: true)
    
    
    // Variables
    var gameHasStarted = false
    
    var gameIsPaused = false
    
    var shipShouldMove = false
    var shipDirectionRight = false
    
    var shipIsDestroyed = false
    
    var playerScore:Int = 0
    
    
    var randomVelocity: CGFloat {
        get {
            return CGFloat(drand48() + 0.5)
        }
    }
    var randomVelocityLow: CGFloat {
        get {
            return CGFloat(drand48())
        }
    }
    
    
    // Constants
    let alienPartPPS: Double = 109
    let alienPartMaxDisplacement: UInt32 = 60
    
    var screenCenter: CGPoint {
        get {
            return CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        }
    }
    
    let alienPointValue = 5
    let alienPartPointValue = 1
    
    let shipSpeed: CGFloat = 5
    let alienPartSpeed: CGFloat = 0.75
    
    let starZPos: CGFloat = 1
    let alienZPos: CGFloat = 2
    let bulletZPos: CGFloat = 3
    let shipZPos: CGFloat = 4
    let explosionZPos: CGFloat = 5
    let scoreZPos: CGFloat = 6
    let pauseButtonZPos: CGFloat = 7
    let pauseTextZPos: CGFloat = 8
}
