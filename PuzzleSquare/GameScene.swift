//
//  GameScene.swift
//  PuzzleSquare
//
//  Created by Stephen Brennan on 7/27/16.
//  Copyright (c) 2016 Stephen Brennan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var square = 2
    var board : Board!
    var playerDrill : Drill!
    var shuffleDrill : ShuffleDrill!
    
    enum GameStates {
        case START
        case SHUFFLING
        case PLAYING
    }
    
    var state = GameStates.START
    static let NextButtonName = "NextButton"
    static let PrevButtonName = "PrevButton"
    
//    weak var zeroTile : Tile!
    
    func resetBoard() {
        state = .START
        let boardSize = square * square
        // nuke old board
        var toRemove = [ Tile ]()
        for c in children {
            if let n = c as? Tile {
                toRemove.append(n)
            }
        }
        removeChildrenInArray(toRemove)
        
        // create new board
        let maxBlock = square
        let margin = CGFloat(20)
        let totalWidth = frame.width - 2 * margin
        let size = totalWidth / CGFloat(maxBlock)
        board = Board(square:square)
        for idx in 0..<boardSize {
            let row = idx / square
            let col = idx % square
            
            let num = (1 + idx) % boardSize
            let theTile = Tile(num:num, size:size - 4)
            board.append(theTile)
            addChild(theTile)
            let xPos = (CGFloat(col) + 0.5) * size + margin
            let yPos = ((CGFloat(row) - 1.5) * -1.0) * size + frame.height / 2
            theTile.position = CGPointMake(xPos, yPos)
        }
        
        var counter = 0
        let shuffleCount = 5 * square * square * square
        shuffleDrill = ShuffleDrill(board: board, duration: 2.0 / Double(shuffleCount) / Double(square))
        playerDrill = Drill(board: board)
        var lastTile : Tile?
        while counter < shuffleCount {
            let idx = random() % board.count
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
        
        let by = CGFloat(20)
        let labelSize = CGFloat(30)
        let nextButton = Label(size: labelSize, text: "▷")
        nextButton.position = CGPointMake(frame.maxX - 100, by)
        nextButton.name = GameScene.NextButtonName
        addChild(nextButton)
        let prevButton = Label(size: labelSize, text: "◁")
        prevButton.position = CGPointMake(100, by)
        prevButton.name = GameScene.PrevButtonName
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
                    if l.name == GameScene.NextButtonName {
                        self.square += 1
                    } else if l.name == GameScene.PrevButtonName {
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
