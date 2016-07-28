//
//  GameScene.swift
//  PuzzleSquare
//
//  Created by Stephen Brennan on 7/27/16.
//  Copyright (c) 2016 Stephen Brennan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var square = 3
    var board : [ Tile ]!
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
        board = [Tile]()
        for idx in 0..<boardSize {
            let row = idx / square
            let col = idx % square
            
            let theTile = Tile(num:idx, size:size - 4)
            board.append(theTile)
            addChild(theTile)
            let xPos = (CGFloat(col) + 0.5) * size + margin
            let yPos = ((CGFloat(row) - 1.5) * -1.0) * size + frame.height / 2
            theTile.position = CGPointMake(xPos, yPos)
        }
        
        var counter = 0
        let target = square * square
        while counter < target {
            let idx = random() % board.count
            if let _ = drill(idx) {
                counter++
            }
        }
        
        
    }
    override func didMoveToView(view: SKView) {
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand(time)

        resetBoard()
        
    }
    
    func checkWin() -> Bool {
        for i in 0..<board.count-1 {
            if board[i].num != (i+1) {
                return false
            }
        }
        return true
    }
    
    func drill(idx : Int, delta : Int, validate : (Int, Int) -> Bool) -> Tile? {
        if board[idx].num == 0 {
            return board[idx]
        }
        let nidx = idx + delta
        if !validate(idx, nidx) {
            return nil
        }
        if let zero = drill(nidx, delta: delta, validate: validate) {
            let nonzero = board[idx]
            board[nidx] = nonzero
            board[idx] = zero
            let pos = zero.position
            zero.position = nonzero.position
            nonzero.position = pos
            return zero
        }
        return nil
    }
    func hCheck(idx : Int, nidx : Int) -> Bool {
        if idx / square != nidx / square {
            return false
        }
        return nidx >= 0 && nidx < board.count
    }
    func vCheck(idx : Int, nidx : Int) -> Bool {
        return nidx >= 0 && nidx < board.count
    }
    
    func drill(idx : Int) -> Tile? {
        var ret : Tile?
        
        ret = drill(idx, delta: -1, validate: hCheck)
        ret = ret ?? drill(idx, delta: 1, validate: hCheck)
        ret = ret ?? drill(idx, delta: square, validate: vCheck)
        ret = ret ?? drill(idx, delta: -square, validate: vCheck)
        return ret
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
                    
                    if let _ = drill(idx) {
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
