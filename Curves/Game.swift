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
    var playerObject = [PlayerObject]()
    
    
    override init(){
        self.id = 0
        self.name = ""
        self.playerObject = [PlayerObject]()
    }
    
    init(id: Int, name: String, playerObject: [PlayerObject]) {
        
        self.id = id
        self.name = name
        self.playerObject = playerObject
        
        
    }
    
//    override var description: String{
//        return "id: \(id), name: \(name), players: \(players)"
//    }
    
    
    
    
}