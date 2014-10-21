//
//  GameViewController.swift
//  Alien War
//
//  Created by Ephraim Benson on 7/13/14.
//  Copyright (c) 2014 Ephraim Benson. All rights reserved.
//

import UIKit
import AVFoundation
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameStartScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    
    var backgroundMusicPlayer = AVAudioPlayer()
    let defaultMusicVolume:Float = 0.4
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var error: NSError? = NSError()
        let backgroundMusicURL: NSURL! = NSBundle.mainBundle().URLForResource("background-music", withExtension: "mp3")
        self.backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL, error: &error)
        self.backgroundMusicPlayer.numberOfLoops = -1;
        defaultVolume()
        self.backgroundMusicPlayer.prepareToPlay()
        self.backgroundMusicPlayer .play()
        
        if let scene = GameStartScene.unarchiveFromFile("GameStartScene") as? GameStartScene {
            // Configure the view.
            let skView = self.view as SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            
            //skView.showsPhysics = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.size = skView.bounds.size
            skView.presentScene(scene)
        }
    }
    
    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter()
            .addObserver(self,
                selector: "pauseMusic",
                name: "PauseMusic",
                object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self,
                selector: "resumeMusic",
                name: "ResumeMusic",
                object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self,
                selector: "decreaseVolume",
                name: "DecreaseVolume",
                object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self,
                selector: "defaultVolume",
                name: "DefaultVolume",
                object: nil)
    }
    
    func pauseMusic() {
        backgroundMusicPlayer.pause()
    }
    
    func resumeMusic() {
        backgroundMusicPlayer.play()
    }
    
    
    func defaultVolume() {
        backgroundMusicPlayer.volume = defaultMusicVolume
    }
    
    func decreaseVolume() {
        backgroundMusicPlayer.volume = 0.1
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
