//
//  AccountModel.swift
//  Curves
//
//  Created by Moritz Martin on 06.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import Foundation


class AccountModel: NSObject{
    
    var id: Int!
    var email: String!
    var name: String!
    var password: Int!
    
    override init() {
        self.id = 0
        self.email = ""
        self.name = ""
        self.password = 0
    }
    
    init(id: Int, email: String, name: String, password: Int) {
        self.id = id
        self.email = email
        self.name = name
        self.password = password
        
        
    }
    
    override var description: String{
        return "id: \(id), email: \(email), name: \(name), password: \(password)"
    }
    
    
    
    
}