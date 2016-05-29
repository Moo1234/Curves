//
//  Game.swift
//  Curves
//
//  Created by Sebastian Haußmann on 09.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import Foundation


class Game: NSObject{
    
    var id: Int
    var name: String!
    var players = [String]()
    var playerInGamesIDs = [Int]()
    var playerIDs = [String]()
    var readyPlayers = [Bool]()
    var scores = [Int]()
    var colors = [String]()
    
    
    override init(){
        self.id = 0
        self.name = ""
        self.players = [String]()
        self.playerInGamesIDs = [Int]()
        self.playerIDs = [String]()
        self.readyPlayers = [Bool]()
        self.scores = [Int]()
        self.colors = [String]()
    }
    
    init(id: Int, name: String, players: [String], playerInGamesIDs: [Int], playerIDs: [String], readyPlayers: [Bool], scores: [Int], colors: [String]) {
        
        self.id = id
        self.name = name
        self.players = players
        self.playerInGamesIDs = playerInGamesIDs
        self.playerIDs = playerIDs
        self.readyPlayers = readyPlayers
        self.scores = scores
        self.colors = colors
        
        
    }
    
//    override var description: String{
//        return "id: \(id), name: \(name), players: \(players)"
//    }
    
    
    
    
}