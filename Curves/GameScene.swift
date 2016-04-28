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
    
    let p1 = SKShapeNode(circleOfRadius: 2.0)
    let pathP1 = CGPathCreateMutable()
    var leftBtn = SKShapeNode()
    var rightBtn = SKShapeNode()
    let gameArea = SKSpriteNode()
    
    var wayPoints: [CGPoint] = []
    var pressed: Bool = false
    
    var velocity = CGPoint(x: 0, y: 0)
    
    var oldPosX: CGFloat = 0.0
    var oldPosY: CGFloat = 0.0
    var newPosX: CGFloat = 0.0
    var newPosY: CGFloat = 0.0
    
    var i = 0
    
    
    
    override func didMoveToView(view: SKView) {
        var p1X = self.frame.width / 2
        var p1Y = self.frame.height / 2
        backgroundColor = SKColor.blackColor()
        
        
        
        leftBtn = SKShapeNode(rectOfSize: CGSize(width: frame.width / 10, height: frame.height))
        rightBtn = SKShapeNode(rectOfSize: CGSize(width: frame.width / 10, height: frame.height))
        
        p1.position = CGPoint(x: frame.width / 2, y: frame.height / 2 )
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
        //   p1.physicsBody?.velocity = CGVectorMake(20 , 20)
        p1.physicsBody?.linearDamping = 0
        
        
        let currentPosition = position
        var newPosition = position
        wayPoints.append(CGPoint(x: 100,y: 100))
        let targetPoint = wayPoints[0]
        changeDirection(targetPoint)
        
        //                        let circle = UIBezierPath(arcCenter: CGPoint(x: 100,y: 100), radius: CGFloat(50), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        //                        let followCircle = SKAction.followPath(circle.CGPath, asOffset: true, orientToPath: true, duration: 5.0)
        //                        let endless = SKAction.repeatActionForever(followCircle)
        //                        p1.runAction(endless)
        
        addChild(leftBtn)
        addChild(rightBtn)
        addChild(p1)
        
        //        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 100,y: 100), radius: CGFloat(20), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        //
        //        let shapeLayer = CAShapeLayer()
        //        shapeLayer.path = circlePath.CGPath
        //
        //        //change the fill color
        //        shapeLayer.fillColor = UIColor.clearColor().CGColor
        //        //you can change the stroke color
        //        shapeLayer.strokeColor = UIColor.redColor().CGColor
        //        //you can change the line width
        //        shapeLayer.lineWidth = 3.0
        //
        //        view.layer.addSublayer(shapeLayer)
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
    
    func pointToRadian(targetPoint: CGPoint) -> Double{
        let deltaX = targetPoint.x;
        let deltaY = targetPoint.y;
        let rad = atan2(deltaY, deltaX); // In radians
        return ( Double(rad) * (180 / M_PI))
    }
    
    func radianToPoint(rad: Double) -> CGPoint{
        return CGPoint(x: cos(rad*(M_PI/180))*141, y: sin(rad*(M_PI/180))*141)
    }
    
    func changeDirection(targetPoint: CGPoint){
        let currentPosition = position
        var newPosition = position
        let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
        let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
        let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
        p1.physicsBody?.velocity = CGVectorMake(direction.x * 80, direction.y * 80)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var alt = pointToRadian(wayPoints[0])
        for touch in touches {
            let location = touch.locationInNode(self)
            if leftBtn.containsPoint(location){
                print("left")
                //                print(p1.position.x)
                //                let circle = UIBezierPath(arcCenter: CGPoint(x: 100,y: 100), radius: CGFloat(20), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
                //                let followCircle = SKAction.followPath(circle.CGPath, asOffset: true, orientToPath: true, duration: 10.0)
                //                let endless = SKAction.repeatActionForever(followCircle)
                //                p1.runAction(endless)
                wayPoints[0] = radianToPoint(alt+10)
                changeDirection(wayPoints[0])
                pressed = true
                myTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "changeDirectionL", userInfo: nil, repeats: pressed)
                
            }
            else if rightBtn.containsPoint(location){
                print("right")
                wayPoints[0] = radianToPoint(alt-10)
                changeDirection(wayPoints[0])
                pressed = true
                myTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "changeDirectionR", userInfo: nil, repeats: pressed)
            }
        }
        //movePlayers()
        
    }
    var myTimer : NSTimer = NSTimer()
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        pressed = false
        myTimer.invalidate()
    }
    
    func changeDirectionL(){
        var alt = pointToRadian(wayPoints[0])
        wayPoints[0] = radianToPoint(alt+10)
        changeDirection(wayPoints[0])
    }
    func changeDirectionR(){
        var alt = pointToRadian(wayPoints[0])
        wayPoints[0] = radianToPoint(alt-10)
        changeDirection(wayPoints[0])
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        let pathToDraw: CGMutablePath = CGPathCreateMutable()
        let myLine: SKShapeNode = SKShapeNode(path: pathToDraw)
        
        
        
        
        var locationX = p1.position.x
        var locationY = p1.position.y
        
        
        //        wayPoints.append(CGPoint(x: locationX, y: locationY))
        //
        //        locationX = locationX * POINTS_PER_SEC
        //        locationY = locationY * POINTS_PER_SEC
        
        
        // move()
        
        
        CGPathMoveToPoint(pathToDraw, nil, oldPosX, oldPosY)
        CGPathAddLineToPoint(pathToDraw, nil, locationX, locationY)
        
        oldPosX = locationX
        oldPosY = locationY
        
        myLine.path = pathToDraw
        myLine.strokeColor = SKColor.greenColor()
        myLine.lineWidth = 3.0
        let myLineNew = myLine
        
        
        
        
        if i % 2 == 0 {
            myLineNew.removeFromParent()
            self.addChild(myLine)
        }else{
            myLine.removeFromParent()
            self.addChild(myLineNew)
        }
        
        i += 1
    }
    
    
    func movePlayers(){
        //        var alt = pointToRadian(wayPoints[0])
        //        print(alt)
        //        wayPoints[0] = radianToPoint(alt+10)
        //
        //        changeDirection(radianToPoint(alt+10))
        
        
        
        //        let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
        //        let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
        //        let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
        //        p1.physicsBody?.velocity = CGVectorMake(direction.x * 80, direction.y * 80)
        
        //        var dx = p1.position.x - self.frame.width / 2
        //        var dy = p1.position.y - self.frame.height / 2
        //
        //        var rad = atan2(dy, dx)
        //        print(p1.physicsBody?.velocity.dx)
        //        p1.physicsBody?.velocity = CGVectorMake((p1.physicsBody?.velocity.dx)!+10, (p1.physicsBody?.velocity.dy)!-10)
        
        //   path = UIBezierPath(arcCenter: CGPoint(x: frame.width / 4 , y: frame.height / 4), radius: 120, startAngle: rad, endAngle: rad + CGFloat(M_PI*4), clockwise: true)
        
        //   let follow = SKAction.followPath(path.CGPath, speed: 100)
        //   p1.runAction(SKAction.repeatActionForever(follow))
        
        
        
        
        //        let moveX = SKAction.moveBy(CGVectorMake(2, 3), duration: 1.0)
        ////
        ////        let moveX =  SKAction.moveByX(1, y: 1, duration: 0.07)
        //////        let moveY = SKAction.moveByX(0, y: 1, duration: 0.01)
        //////        let seq = SKAction.sequence([moveX, moveY])
        //        let moveP1endless = SKAction.repeatActionForever(moveX)
        //        p1.runAction(moveP1endless)
    }
}