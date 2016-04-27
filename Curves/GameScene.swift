//
//  GameScene.swift
//  CurveFever
//
//  Created by Moritz Martin on 07.03.16.
//  Copyright (c) 2016 Moritz Martin. All rights reserved.
//

import SpriteKit

struct PhysicsCat{
    static let p1 : UInt32 = 0x1 << 1
}

class GameScene: SKScene {
    
    var path = UIBezierPath()
    
    let p1 = SKShapeNode()
    let pathP1 = CGPathCreateMutable()
    var leftBtn = SKShapeNode()
    var rightBtn = SKShapeNode()
    let gameArea = SKSpriteNode()
    
    
    
    override func didMoveToView(view: SKView) {
        var p1X = self.frame.width / 2
        var p1Y = self.frame.height / 2
        backgroundColor = SKColor.blackColor()
        
        
        
        leftBtn = SKShapeNode(rectOfSize: CGSize(width: frame.width / 10, height: frame.height))
        rightBtn = SKShapeNode(rectOfSize: CGSize(width: frame.width / 10, height: frame.height))
        
        p1.path = pathP1
        CGPathMoveToPoint(pathP1, nil, frame.width / 2, frame.height / 2)
        CGPathAddLineToPoint(pathP1, nil, (frame.width / 2) + 20, (frame.height / 2) + 30)
        CGPathCloseSubpath(pathP1)
        //p1.position = CGPoint(x: frame.width / 2, y: frame.height / 2 )
        p1.fillColor = SKColor.greenColor()
        p1.strokeColor = SKColor.greenColor()
        p1.lineWidth = 2.0
        
        leftBtn.position = CGPoint(x: (((frame.width / 10)/2) + frame.width) - frame.width, y: frame.height/2)
        leftBtn.fillColor = SKColor.blueColor()
        
        
        rightBtn.position = CGPoint(x: frame.width - ((frame.width/10)/2), y: frame.height/2)
        rightBtn.fillColor = SKColor.blueColor()
        
        
        
        p1.physicsBody = SKPhysicsBody(circleOfRadius: 2)
        p1.physicsBody?.categoryBitMask = PhysicsCat.p1
        p1.physicsBody?.affectedByGravity = false
        p1.physicsBody?.velocity = CGVectorMake(20 , 20)
        
        
        addChild(leftBtn)
        addChild(rightBtn)
        addChild(p1)
        
        
        
        
        //
        //        let movePoint = SKAction.runBlock({
        //            ()
        //
        //            self.movePlayers(p1X, p1Y: p1Y)
        //        })
        //
        //        let movePointForever = SKAction.repeatActionForever(movePoint)
        //        self.runAction(movePointForever)
        //
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        movePlayers()
        //p1.physicsBody?.velocity = CGVectorMake(-20, 10)
    }
    
    func movePlayers(){
        
        var dx = p1.position.x - self.frame.width / 2
        var dy = p1.position.y - self.frame.height / 2
        
        var rad = atan2(dy, dx)
        
        
        path = UIBezierPath(arcCenter: CGPoint(x: frame.width / 4 , y: frame.height / 4), radius: 120, startAngle: rad, endAngle: rad + CGFloat(M_PI*4), clockwise: true)
        
        let follow = SKAction.followPath(path.CGPath, speed: 100)
        p1.runAction(SKAction.repeatActionForever(follow))
        
        
        
        
        //        let moveX = SKAction.moveBy(CGVectorMake(2, 3), duration: 1.0)
        ////
        ////        let moveX =  SKAction.moveByX(1, y: 1, duration: 0.07)
        //////        let moveY = SKAction.moveByX(0, y: 1, duration: 0.01)
        //////        let seq = SKAction.sequence([moveX, moveY])
        //        let moveP1endless = SKAction.repeatActionForever(moveX)
        //        p1.runAction(moveP1endless)
    }
}
