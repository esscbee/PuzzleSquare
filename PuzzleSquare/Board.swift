//
//  Board.swift
//  PuzzleSquare
//
//  Created by Stephen Brennan on 7/28/16.
//  Copyright © 2016 Stephen Brennan. All rights reserved.
//

import Foundation

class Board {
    private var board = [Tile]()
    private var _square : Int
    var square : Int {
        get {
            return _square
        }
    }
    var count : Int {
        get {
            return board.count
        }
    }
    init(square: Int) {
        self._square = square
    }
    func append(t : Tile) {
        board.append(t)
    }
    subscript(i : Int) -> Tile {
        get {
            return board[i]
        }
        set {
            board[i] = newValue
        }
    }
    
    func indexOf(t : Tile) -> Int? {
        return board.indexOf(t)
    }
    
    
}