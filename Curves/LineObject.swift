//
//  LineObject.swift
//  Curves
//
//  Created by Sebastian Haußmann on 28.04.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import Foundation
import SpriteKit

class LineObject{
    var name: String = ""
    var lineWidth: CGFloat = 2.0
    var speed: Int = 80
    let line: SKShapeNode
    
    let myLine: SKShapeNode
    var color: SKColor = SKColor.blueColor()
    
    init(name:String, lineWidth: CGFloat, speed: Int, dotThickness: CGFloat, color: SKColor){
        self.name = name
        self.lineWidth = lineWidth
        self.speed = speed
        self.line = SKShapeNode(circleOfRadius: dotThickness)
        self.myLine = SKShapeNode(path: CGPathCreateMutable())
    }
    
    
    
}