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
    var board : [ Tile ]!
//    weak var zeroTile : Tile!
    
    func resetBoard() {
        let boardSize = square * square
        var locBoard = [Int]()
        for i in 0..<boardSize {
            locBoard.append(i)
        }
        for _ in 1...boardSize {
            let c1 = Int(rand()) % boardSize
            let c2 = Int(rand()) % boardSize
            if c1 == c2 {
                continue
            }
            let t = locBoard[c1]
            locBoard[c1] = locBoard[c2]
            locBoard[c2] = t
        }
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
            
            let theTile = Tile(num:locBoard[idx], size:size - 4)
            board.append(theTile)
            addChild(theTile)
            let xPos = (CGFloat(col) + 0.5) * size + margin
            let yPos = ((CGFloat(row) - 1.5) * -1.0) * size + frame.height / 2
            theTile.position = CGPointMake(xPos, yPos)
        }
    }
    override func didMoveToView(view: SKView) {
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand(time)

        resetBoard()
        
    }
    
    func checkWin() -> Bool {
        for i in 0..<board.count {
            if board[i].num != (i+1) {
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
    
    static let allDirections : [ Direction ] = [ .UP, .DOWN, .LEFT, .RIGHT ]
    
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
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            for n in nodesAtPoint(location) {
                if let t = n as? Tile {
                    if t.num == 0 {
                        continue
                    }
                    
                    let idx = board.indexOf(t)!
                    
                    var found = nil != drill(idx, delta: -1, validate: hCheck)
                    found = found || nil != drill(idx, delta: 1, validate: hCheck)
                    found = found || nil != drill(idx, delta: square, validate: vCheck)
                    found = found || nil != drill(idx, delta: -square, validate: vCheck)
                    if found {
                        checkWin()
                    }
                }
            }
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
