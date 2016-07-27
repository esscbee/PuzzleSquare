//
//  GameScene.swift
//  PuzzleSquare
//
//  Created by Stephen Brennan on 7/27/16.
//  Copyright (c) 2016 Stephen Brennan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var square = 4
    var board : [ Int ]!
    
    func resetBoard() {
        let size = square * square
        board = [ Int ]()
        for i in 0..<size {
            board.append(i)
        }
        for _ in 1...size {
            let c1 = Int(rand()) % size
            let c2 = Int(rand()) % size
            if c1 == c2 {
                continue
            }
            let t = board[c1]
            board[c1] = board[c2]
            board[c2] = t
        }
    }
    func showBoard() {
        var toRemove = [ Tile ]()
        for c in children {
            if let n = c as? Tile {
                toRemove.append(n)
            }
        }
        removeChildrenInArray(toRemove)
        let maxBlock = square
        let margin = CGFloat(20)
        let totalWidth = frame.width - 2 * margin
        let size = totalWidth / CGFloat(maxBlock)
        var num = 0
        for row in 1...square {
            for col in 1...square {
                let myBlock = Tile(num:board[num], size:size - 4)
                addChild(myBlock)
                let xPos = (CGFloat(col) - 0.5) * size + margin
                let yPos = ((CGFloat(row) - 2.5) * -1.0) * size + frame.height / 2
                myBlock.position = CGPointMake(xPos, yPos)
                num += 1
            }
        }
    }
    override func didMoveToView(view: SKView) {
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand(time)

        resetBoard()
        showBoard()
        
    }
    
    func checkWin() -> Bool {
        for i in board[0..<board.count] {
            if board[i] != (i+1) {
                return false
            }
        }
        return true
    }
    
    enum Direction {
        case UP
        case DOWN
        case LEFT
        case RIGHT
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            for n in nodesAtPoint(location) {
                if let t = n as? Tile {
                    if t.num == 0 {
                        continue
                    }
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
