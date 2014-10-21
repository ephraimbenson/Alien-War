//
//  HighScore.swift
//  Alien War
//
//  Created by Ephraim Benson on 10/18/14.
//  Copyright (c) 2014 Ephraim Benson. All rights reserved.
//

import Foundation

class HighScore {
	var highScore = Int()
	
	let rootPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
	let plistPath = String()
	
	init(score: Int) {
		plistPath = rootPath + "/highScore.plist"
		
		var dict: NSDictionary? = NSDictionary(contentsOfFile: plistPath)
		if dict != nil {
			var foundScore: AnyObject! = dict?.objectForKey("highScore")
			if score > foundScore as Int {
				foundScore = score
			}
			highScore = foundScore as Int
		} else {
			highScore = score
		}
		saveScore(highScore)
	}
	
	func saveScore(newHighScore: Int) {
        let newDict = NSDictionary(object: newHighScore, forKey: "highScore")
        newDict.writeToFile(plistPath, atomically: true)
	}
	
}
