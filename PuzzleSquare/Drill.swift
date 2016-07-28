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
            let pos = zero.position
            zero.position = nonzero.position
            nonzero.position = pos
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
    
    // check for open tile on our row / col
    // idx - index of selected (touched) cell
    func drill(idx : Int) -> Tile? {
        var ret : Tile?
        
        ret = drill(idx, delta: -1, validate: hCheck)
        ret = ret ?? drill(idx, delta: 1, validate: hCheck)
        ret = ret ?? drill(idx, delta: square, validate: vCheck)
        ret = ret ?? drill(idx, delta: -square, validate: vCheck)
        return ret
    }
}

