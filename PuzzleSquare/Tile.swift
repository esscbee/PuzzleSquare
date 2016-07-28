//
//  Tile.swift
//  PuzzleSquare
//
//  Created by Stephen Brennan on 7/27/16.
//  Copyright © 2016 Stephen Brennan. All rights reserved.
//

import SpriteKit

class Label : SKSpriteNode {
    
    var text : String?
    
    func getTexture() -> SKTexture? {
        return SKTexture(imageNamed: "BG_white")
    }
    func getFontColor() -> SKColor {
        return UIColor.blackColor()
    }
    init(size: CGFloat, text: String?) {
        self.text = text
        let theSize = CGSizeMake(size, size)
        let color = UIColor.clearColor()
        super.init(texture: nil, color: color, size: theSize)
        let texture = getTexture()
        super.texture = texture
        
        if let text = self.text {
            
            let theLabel = SKLabelNode(text: text)
            addChild(theLabel)
            theLabel.verticalAlignmentMode = .Center
            theLabel.fontSize = size * 0.7
            theLabel.zPosition = 10
            theLabel.fontColor = getFontColor()
            theLabel.fontName = "Chalkboard"
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Tile : Label {
    let num : Int
    init(num : Int, size: CGFloat) {
        self.num = num
        let text : String? = num == 0 ? nil : String(num )
        super.init(size: size, text: text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func getFontColor() -> SKColor {
        let odd = 0 != (num & 1)
        return odd ? UIColor.whiteColor() : UIColor.blackColor()
    }
    override func getTexture() -> SKTexture? {
        if num == 0 {
            return nil
        } else {
            let odd = 0 != (num & 1)
            let textName = odd ? "BG_red" : "BG_white"
            let texture = SKTexture(imageNamed: textName)
            return texture
        }
    }
}