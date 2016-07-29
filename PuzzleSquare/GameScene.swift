//
//  GameScene.swift
//  PuzzleSquare
//
//  Created by Stephen Brennan on 7/27/16.
//  Copyright (c) 2016 Stephen Brennan. All rights reserved.
//

import SpriteKit

let BG_white = "BG_white"
let BG_red = "BG_red"
class GameScene: SKScene {
    var square = 2
    var board : Board!
    var playerDrill : Drill!
    var shuffleDrill : ShuffleDrill!
    let margin = CGFloat(20)
    var tileFactory : TileFactory?
    
    enum GameStates {
        case START
        case WIN
        case SHUFFLING
        case PLAYING
    }
    
    var state = GameStates.START
    static let nextButtonName = "NextButton"
    static let prevButtonName = "PrevButton"
    static let winNodeName = "WinSprite"
    
//    weak var zeroTile : Tile!
    
    func getBoardWidth() -> CGFloat {
        return (frame.width < frame.height ? frame.width : frame.height) - 2 * margin
    }
    func showWin() {
        let width = getBoardWidth()
        // show full image
        if let tf = tileFactory {
            if let texture = tf.getTexture() {
                let image = SKSpriteNode(texture: texture)
                image.size = CGSizeMake(width, width)
                image.position = CGPointMake(frame.width/2, frame.height/2)
                image.name = GameScene.winNodeName
                image.zPosition = 10
                addChild(image)
            }
        }
        let blackSize = CGSizeMake(175, 80 )
        let borderWidth = CGFloat(2)
        var zPos = CGFloat(20)
        let black = SKSpriteNode(color: UIColor.blackColor(), size: blackSize)
        black.position = CGPointMake(frame.width / 2, frame.height / 2)
        black.zPosition = zPos
        black.name = GameScene.winNodeName
        zPos += 1
        addChild(black)
        let bg = SKSpriteNode(imageNamed: BG_red)
        bg.size = CGSizeMake(blackSize.width - borderWidth * 8, blackSize.height - borderWidth * 8)
        bg.position = CGPointMake(borderWidth / 2.0, borderWidth / 2.0)
        bg.zPosition = zPos
        bg.name = GameScene.winNodeName
        black.addChild(bg)
        
        zPos += 1
        let w = SKLabelNode(text: "You Win!")
        w.zPosition = zPos
        w.fontName = w.fontName! + "_Bold"
        w.name = GameScene.winNodeName
        w.verticalAlignmentMode = .Center
        bg.addChild(w)
        
        w.runAction(SKAction.repeatActionForever(SKAction.sequence(
            [
                SKAction.scaleTo(1.25, duration: 1.0),
                SKAction.scaleTo(0.95, duration: 1.0),
            ])))
        
        state = .WIN
    }
    
    func addBlurryBackground(image: String) {
        if false {
            let blurNode = SKEffectNode()
            let blur = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": 0.5])
            blurNode.filter = blur
            blurNode.zPosition = -5
            addChild(blurNode)
            let pic = SKSpriteNode(imageNamed: image)
            pic.zPosition = -4
            pic.size = frame.size
            blurNode.addChild(pic)
        } else {
            let uiimg = UIImage(named: "Pick")!
            let img = CIImage(image: uiimg)!
            let filter = CIFilter(name:"CIGaussianBlur")!
            filter.setDefaults()
            filter.setValue(img, forKey: kCIInputImageKey)
            filter.setValue(2, forKey: kCIInputRadiusKey)
            let ciContext = CIContext(options: nil)
            let result = filter.valueForKey(kCIOutputImageKey) as! CIImage!
            let cgImage = ciContext.createCGImage(result, fromRect: frame)
//            let finalImage = UIImage(CGImage: cgImage)
            let bg = SKSpriteNode(texture: SKTexture(CGImage: cgImage))
            addChild(bg)
//            bg.xScale = CGFloat(CGImageGetWidth(cgImage)) / frame.width
//            bg.yScale = CGFloat(CGImageGetHeight(cgImage)) / frame.height
//            bg.xScale = 0.1
//            bg.yScale = 0.1
            bg.position = CGPointMake(frame.midX, frame.midY)
            bg.zPosition = -1
            bg.alpha = 0.5
            bg.size = frame.size
            
            
            
        }
    }
    
    func resetBoard() {
        state = .START
        
        let boardSize = square * square
        // nuke old board
        var toRemove = [ SKNode ]()
        for c in children {
            if let n = c as? Tile {
                toRemove.append(n)
            } else if let w = c as? SKSpriteNode {
                if w.name == GameScene.winNodeName {
                    toRemove.append(w)
                }
            }
        }
        removeChildrenInArray(toRemove)
        
        addBlurryBackground("Pick")
        
        // create new board
        let maxBlock = square
        let width = getBoardWidth()
        let size = width / CGFloat(maxBlock)
        board = Board(square:square)
        tileFactory = PictureTileFactory(imageNamed: "Pick", square: square)
        for idx in 0..<boardSize {
            let row = idx / square
            let col = idx % square
            
            let num = (1 + idx) % boardSize
            let theTile = tileFactory!.create(num, size:size - 4)!
            board.append(theTile)
            addChild(theTile)
            let xPos = (CGFloat(col) + 0.5) * size + margin
            let yPos = ((CGFloat(row) + 0.5 - CGFloat(maxBlock) / 2)) * -size + frame.height / 2
            theTile.position = CGPointMake(xPos, yPos)
        }
        
        var counter = 0
        let shuffleCount = 5 * square * square * square
        let baseDuration = square < 3 ? 1.0 : 0
        shuffleDrill = ShuffleDrill(board: board, duration: baseDuration / Double(shuffleCount) / Double(square))
        playerDrill = Drill(board: board)
        var lastTile : Tile?
        while counter < shuffleCount {
            let idx = Int(arc4random() % UInt32(board.count))
            if let theTile = shuffleDrill.drill(idx, lastTile: lastTile) {
                lastTile = theTile
                counter += 1
            }
        }
        state = .SHUFFLING
    }
    override func didMoveToView(view: SKView) {
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand(time)
        resetBoard()
        addBottomButtons()
    }
    
    func addBottomButtons() {
        let by = CGFloat(30)
        let labelSize = CGFloat(40)
        let nextButton = Label(size: labelSize, text: "▷")
        nextButton.position = CGPointMake(frame.maxX - 100, by)
        nextButton.name = GameScene.nextButtonName
        addChild(nextButton)
        let prevButton = Label(size: labelSize, text: "◁")
        prevButton.position = CGPointMake(100, by)
        prevButton.name = GameScene.prevButtonName
        addChild(prevButton)
        

    }
    
    // return true if board is in a Win state
    
    func checkWin() -> Bool {
        for i in 0..<board.count-1 {
            if board[i].num != (i+1) {
                return false
            }
        }
        return true
    }
    
    var doneWithWin = 0.0

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var win = false
        for touch in touches {
            if win {
                break
            }
            let location = touch.locationInNode(self)
            for n in nodesAtPoint(location) {
                if win {
                    break
                }
                if let t = n as? Tile {
                    if t.num == 0 || state != .PLAYING {
                        continue
                    }
                    
                    let idx = board.indexOf(t)!
                    
                    if let _ = playerDrill.drill(idx) {
                        win = checkWin()
                    }
                } else if let l = n as? Label {
                    if l.name == GameScene.nextButtonName {
                        self.square += 1
                    } else if l.name == GameScene.prevButtonName {
                        self.square -= 1
                        if self.square < 2 {
                            self.square = 2
                        }
                    }
                    resetBoard()
                    break

                }
            }
        }
        let dt = NSDate().timeIntervalSince1970
        if win {
            state = .WIN
            showWin()
            doneWithWin = 1 + dt
        } else if state == .WIN && dt > doneWithWin {
            square += 1
            resetBoard()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if state == .SHUFFLING {
            if !shuffleDrill.performAnimations(self) {
                state = .PLAYING
            }
        }
        
    }
}
