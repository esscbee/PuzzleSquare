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
        if win {
            state = .WIN
            showWin()
        } else if state == .WIN {
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
