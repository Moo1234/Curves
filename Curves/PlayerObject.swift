//
//  PlayerObject.swift
//  Curves
//
//  Created by Sebastian Haußmann on 04.06.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import Foundation

class PlayerObject: NSObject {
    var playerName: String
    var playerInGameID: Int
    var playerID: String
    var ready: Bool
    var score: Int
    var color: String
    
    override init(){
        self.playerName = ""
        self.playerInGameID = -1
        self.playerID = ""
        self.ready = false
        self.score = 0
        self.color = ""
    }
    
    init(playerName: String, playerInGameID: Int, playerID: String, ready: Bool, score: Int, color: String){
        self.playerName = playerName
        self.playerInGameID = playerInGameID
        self.playerID = playerID
        self.ready = ready
        self.score = score
        self.color = color
    }
}