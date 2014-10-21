//
//  StandardAlien.swift
//  Alien War
//
//  Created by Ephraim Benson on 10/18/14.
//  Copyright (c) 2014 Ephraim Benson. All rights reserved.
//

import Foundation
import SpriteKit

class StandardAlien: SKSpriteNode {
    var alienGreenFrames = [SKTexture(imageNamed: "alienGreen1"), SKTexture(imageNamed: "alienGreen2")]
    var screenSize = CGSize()
    
    init(screenSize: CGSize) {
        super.init(texture: alienGreenFrames[0], color: nil, size: alienGreenFrames[0].size())
        self.screenSize = screenSize
        
        self.name = "StandardAlien"
        
        for frame in alienGreenFrames {
            frame.filteringMode = .Nearest
        }
        self.setScale(2)
        
        self.position = CGPointMake(CGFloat(Int(rand())) % screenSize.width, screenSize.height)
        
        self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(alienGreenFrames, timePerFrame: 0.5)))
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.dynamic = false
        
        if self.position.x < self.size.width / 2 {
            self.position.x = self.size.width / 2
        } else if self.position.x > screenSize.width - self.size.width / 2 {
            self.position.x = screenSize.width - self.size.width / 2
        }
        
        self.runAction(SKAction.moveByX(0, y: -screenSize.height, duration: 2.5), completion: { self.removeFromParent() })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
}
