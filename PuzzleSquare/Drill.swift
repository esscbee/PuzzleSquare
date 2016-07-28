//
//  Drill.swift
//  PuzzleSquare
//
//  Created by Stephen Brennan on 7/28/16.
//  Copyright © 2016 Stephen Brennan. All rights reserved.
//

import SpriteKit


class Drill {
    
    var board : Board
    var square : Int
    
    init(board : Board) {
        self.board = board
        self.square = board.square
    }
    func swap(zero : Tile, target : Tile) {
        let pos = zero.position
        zero.position = target.position
        target.position = pos
    }
    // drill in a direction
    //
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
            swap(zero, target: nonzero)
            return zero
        }
        return nil
    }
    func hCheck(idx : Int, nidx : Int) -> Bool {
        // check for same line
        if idx / square != nidx / square {
            return false
        }
        // check on board
        return vCheck(idx, nidx: nidx)
    }
    func vCheck(idx : Int, nidx : Int) -> Bool {
        return nidx >= 0 && nidx < board.count
    }
    
    func beginDrill() {
        
    }
    func endDrill(cancel : Bool) {
        
    }
    
    // check for open tile on our row / col
    // idx - index of selected (touched) cell
    func drill(idx : Int, lastTile : Tile?) -> Tile? {
        var ret : Tile?
        
        if board[idx] == lastTile {
            return nil
        }
        
        beginDrill()
        
        ret = drill(idx, delta: -1, validate: hCheck)
        ret = ret ?? drill(idx, delta: 1, validate: hCheck)
        ret = ret ?? drill(idx, delta: square, validate: vCheck)
        ret = ret ?? drill(idx, delta: -square, validate: vCheck)
        
        endDrill(ret == nil)
        return ret
    }
    
    func drill(idx : Int) -> Tile? {
        return drill(idx, lastTile: nil)
    }
}

class ShuffleDrill : Drill {
    
    var tilePositions = [ Tile : CGPoint ] ()
    var animations = [[Tile : SKAction ]]()
    
    var currentAnimation : [ Tile : SKAction ]!
    
    override func beginDrill() {
        currentAnimation = [ Tile : SKAction ]()
    }
    
    override func endDrill(cancel: Bool) {
        animations.append(currentAnimation)
    }
    func getPos(t : Tile) -> CGPoint {
        if let pt = tilePositions[t] {
            return pt
        }
        return t.position
    }
    
    func setPos(t : Tile, pt : CGPoint ) {
        currentAnimation[t] = SKAction.moveTo(pt, duration: 0.1)
        tilePositions[t] = pt
    }
    
    func playAnimations() -> Bool {
        if animations.isEmpty {
            return false;
        }
        let ad = animations.removeFirst()
        for t in ad {
            t.0.runAction(t.1)
        }
        return true
    }
    override func swap(zero: Tile, target: Tile) {
        let zp = getPos(zero)
        let tp = getPos(target)
        setPos(zero, pt: tp)
        setPos(target, pt: zp)
    }
    func performAnimations(scene : SKNode) -> Bool {
        if !animations.isEmpty {
            var anyMoving = false
            for c in scene.children {
                if let t = c as? Tile {
                    if t.hasActions() {
                        anyMoving = true
                    }
                }
            }
            if !anyMoving {
                playAnimations()
            }
            return true
        }
        return false
    }
    
}


