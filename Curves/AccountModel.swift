//
//  AccountModel.swift
//  Curves
//
//  Created by Moritz Martin on 06.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import Foundation


class AccountModel: NSObject{
    
    var email: String!
    var name: String!
    var password: String!
    
    override init() {
        
    }
    
    init(email: String, name: String, password: String) {
        
        self.email = email
        self.name = name
        self.password = password
        
        
    }
    
    override var description: String{
        return "email: \(email), name: \(name), password: \(password)"
    }
    
    
    
    
}