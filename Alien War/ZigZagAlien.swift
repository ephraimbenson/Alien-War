//
//  ZigZagAlien.swift
//  Alien War
//
//  Created by Ephraim Benson on 10/18/14.
//  Copyright (c) 2014 Ephraim Benson. All rights reserved.
//

import Foundation
import SpriteKit

class ZigZagAlien: SKSpriteNode {
    var alienRedFrames = [SKTexture(imageNamed: "alienRed1"), SKTexture(imageNamed: "alienRed2")]
    var screenSize = CGSize()
    
    init(screenSize: CGSize) {
        super.init(texture: alienRedFrames[0], color: nil, size: alienRedFrames[0].size())
        self.screenSize = screenSize
        
        self.name = "ZigZagAlien"
        
        for frame in alienRedFrames {
            frame.filteringMode = .Nearest
        }
        self.setScale(2)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.dynamic = false
        
        self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(alienRedFrames, timePerFrame: 0.5)))
    
        // set alien position to either far left or right and move back and forth
        var newPoint = CGPoint()
        if arc4random_uniform(2) == 0 {
            self.position = CGPointMake(0, screenSize.height)
            newPoint = CGPointMake(screenSize.width, self.position.y - 50)
        } else {
            self.position = CGPointMake(screenSize.width, screenSize.height)
            newPoint = CGPointMake(0, self.position.y - 50)
        }
        
        zigZag(newPoint)
    }
    
    func zigZag(point: CGPoint) {
        var newPoint = point
        self.runAction(SKAction.moveTo(newPoint, duration: 2), completion: {
            if newPoint.x == 0 {
                newPoint = CGPointMake(self.screenSize.width, newPoint.y - 50)
            } else {
                newPoint = CGPointMake(0, newPoint.y - 50)
            }
            if self.position.y < -50 {
                // remove alien when it leaves the screen
                self.removeFromParent()
            } else {
                self.zigZag(newPoint)
            }
        })
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
}