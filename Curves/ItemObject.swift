//
//  ItemObject.swift
//  Curves
//
//  Created by Moritz Martin on 12.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import Foundation
import SpriteKit


class ItemObject: SKSpriteNode{
    
    var imageName = String()
    var itemAction = String()
    var itemPosition = CGPoint()
    var itemName = String()
    
    init (imageName: String, itemAction: String, itemPosition: CGPoint, itemName: String, color:SKColor, size: CGSize) {
        super.init (texture: nil, color: color, size: size)
     
        self.imageName = imageName
        self.itemName = itemName
        self.itemPosition = itemPosition
        self.itemAction = itemAction
        
        
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        self.physicsBody!.categoryBitMask = PhysicsCat.item
        self.physicsBody!.contactTestBitMask =  PhysicsCat.p1Cat
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.linearDamping = 0

        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}