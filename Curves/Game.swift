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
    var players: String!
    
    override init(){
        self.id = 0
        self.name = ""
        self.players = ""
    }
    
    init(id: Int, name: String, players: String) {
        
        self.id = id
        self.name = name
        self.players = players
        
        
    }
    
    override var description: String{
        return "id: \(id), name: \(name), players: \(players)"
    }
    
    
    
    
}