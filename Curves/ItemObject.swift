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
    let nodeSize = CGSizeMake(20, 50)
    
    init (imageName: String, itemAction: String, itemPosition: CGPoint, itemName: String) {
        super.init (texture: nil, color: UIColor.clearColor(), size: nodeSize)
     
        self.imageName = imageName
        self.itemName = itemName
        self.itemPosition = itemPosition
        self.itemAction = itemAction
        createItem()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createItem(){
        let item = SKSpriteNode(imageNamed: imageName)
        item.position = itemPosition
        item.setScale(0.5)
        item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height / 2)
        item.physicsBody!.categoryBitMask = PhysicsCat.itemCat
        item.physicsBody!.contactTestBitMask =  PhysicsCat.p1Cat
        item.physicsBody?.affectedByGravity = false
        item.physicsBody?.linearDamping = 0
        addChild(item)
        
        
    }
    
    
}