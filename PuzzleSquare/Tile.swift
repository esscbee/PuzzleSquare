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

class PictureTile : Tile {
    let image  : SKTexture?
    init(num: Int, size: CGFloat, image : SKTexture?) {
        self.image = image
        super.init(num: num, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func getTexture() -> SKTexture? {
        return image
    }
    override func getFontColor() -> SKColor {
        return SKColor.purpleColor()
    }
    
}

class TileFactory {
    func create(num: Int, size: CGFloat) -> Tile? {
        return Tile(num: num, size: size);
    }
}

class PictureTileFactory : TileFactory {
    let image : UIImage
    let square : Int
    init(imageNamed: String, square: Int) {
        image = UIImage(named: imageNamed)!
        self.square = square
    }
    override func create(num: Int, size: CGFloat) -> Tile? {
        var sqi : SKTexture?
        
        if num != 0 {
            let row = num / square
            let col = num % square
            let isize = image.size
            let dx = isize.width / CGFloat(square)
            let dy = isize.height / CGFloat(square)
            let x = dx * CGFloat(col)
            let y = dy * CGFloat(row)
            let rect = CGRectMake(x, y, dx, dy)
            
            guard let subImage = CGImageCreateWithImageInRect(image.CGImage!, rect)
                else { return nil }
            
            sqi = SKTexture(CGImage: subImage)
        }
        let t = PictureTile(num: num, size: size, image: sqi )
        
        return t
    }
}