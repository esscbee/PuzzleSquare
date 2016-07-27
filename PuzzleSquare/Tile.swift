//
//  Tile.swift
//  PuzzleSquare
//
//  Created by Stephen Brennan on 7/27/16.
//  Copyright © 2016 Stephen Brennan. All rights reserved.
//

import SpriteKit

class Tile : SKSpriteNode {
    
    let num : Int
    init(num : Int, size: CGFloat) {
        self.num = num
        let theColor = UIColor.blueColor()
        let theSize = CGSizeMake(size, size)
        if num == 0 {
            super.init(texture: nil, color: UIColor.clearColor(), size: theSize)
        } else {
            let odd = 0 != (num & 1)
            let textName = odd ? "BG_red" : "BG_white"
            let texture = SKTexture(imageNamed: textName)
            super.init(texture: texture, color: theColor, size: theSize)
            let theLabel = SKLabelNode(text: String(num))
            addChild(theLabel)
            theLabel.verticalAlignmentMode = .Center
            theLabel.fontSize = size * 0.7
            theLabel.zPosition = 10
            theLabel.fontColor = odd ? UIColor.whiteColor() : UIColor.blackColor()
            theLabel.fontName = "Chalkboard"
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}