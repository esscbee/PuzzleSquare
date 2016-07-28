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
//    weak var zeroTile : Tile!
    
    func resetBoard() {
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
        let target = square * square * square
        let theDrill = Drill(board: board)
        playerDrill = Drill(board: board)
        while counter < target {
            let idx = random() % board.count
            if let _ = theDrill.drill(idx) {
                counter += 1
            }
        }
        
        
    }
    override func didMoveToView(view: SKView) {
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand(time)

        resetBoard()
        
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
                    if t.num == 0 {
                        continue
                    }
                    
                    let idx = board.indexOf(t)!
                    
                    if let _ = playerDrill.drill(idx) {
                        win = checkWin()
                    }
                }
            }
        }
        if win {
            square += 1
            resetBoard()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
