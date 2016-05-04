//
//  GameScene.swift
//  CurveFever
//
//  Created by Moritz Martin on 07.03.16.
//  Copyright (c) 2016 Moritz Martin. All rights reserved.
//

import SpriteKit

struct PhysicsCat{
    static let p1Cat : UInt32 = 0x1 << 1
    static let gameAreaCat : UInt32 = 0x1 << 2

}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var path = UIBezierPath()
    
    let p1 = SKShapeNode(circleOfRadius: 2.0)
    let pathP1 = CGPathCreateMutable()
    var leftBtn = SKShapeNode()
    var rightBtn = SKShapeNode()
    var gameArea = SKShapeNode()
    var dead = false
    
    
    var wayPoints: [CGPoint] = []
    var pressed: Bool = false
    
     var velocity = CGPoint(x: 0, y: 0)
    
    var oldPosX: CGFloat = 0.0
    var oldPosY: CGFloat = 0.0
    var newPosX: CGFloat = 0.0
    var newPosY: CGFloat = 0.0
    
    var i = 0
    
    
    var myTimer1 : NSTimer = NSTimer()
    var myTimer2 : NSTimer = NSTimer()
    var test : NSTimer = NSTimer()
    
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        physicsWorld.contactDelegate = self
        
        
        gameArea = SKShapeNode(rect: CGRect(x: 130, y: 100, width: frame.width - 250, height: frame.height - 200))
        gameArea.lineWidth = 5
        gameArea.strokeColor = SKColor.whiteColor()
        gameArea.position = CGPoint(x: 0, y: 0 )
//        gameArea.fillColor = SKColor.blackColor()

            
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
        
        oldPosX = p1.position.x
        oldPosY = p1.position.y
        
        p1.physicsBody = SKPhysicsBody(circleOfRadius: 2)
        p1.physicsBody!.categoryBitMask = PhysicsCat.p1Cat
        p1.physicsBody!.contactTestBitMask = PhysicsCat.gameAreaCat | PhysicsCat.p1Cat
        p1.physicsBody?.affectedByGravity = false
        p1.physicsBody?.linearDamping = 0
        
        
        //SKPhysicsBody(rectangleOfSize: CGSize(width:frame.width - 250 , height: frame.height - 600))
        gameArea.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 130, y: 100, width: frame.width - 250, height: frame.height - 200))
        gameArea.physicsBody!.categoryBitMask = PhysicsCat.gameAreaCat
        gameArea.physicsBody?.contactTestBitMask = PhysicsCat.p1Cat
        gameArea.physicsBody?.affectedByGravity = false
        gameArea.physicsBody?.dynamic = false
        
      
        wayPoints.append(CGPoint(x: 100,y: 100))
        let targetPoint = wayPoints[0]
        changeDirection(targetPoint)
        
        CGPathMoveToPoint(pathToDraw, nil, self.oldPosX, self.oldPosY)

        
        myLine.path = pathToDraw
        myLine.strokeColor = SKColor.greenColor()
        myLine.lineWidth = 3.0
        
        
        self.gameArea.addChild(myLine)

        addChild(gameArea)
        addChild(leftBtn)
        addChild(rightBtn)
//        addChild(p1)
        gameArea.addChild(p1)
        
        test = NSTimer.scheduledTimerWithTimeInterval(0.0001, target: self, selector: #selector(GameScene.update2), userInfo: nil, repeats: true)

    }
    
    
    let pathToDraw: CGMutablePath = CGPathCreateMutable()
    let myLine: SKShapeNode = SKShapeNode()
    
    func update2(){
      
        var locationX = p1.position.x
        var locationY = p1.position.y
        
        
        if (myLine.containsPoint(CGPoint(x: locationX, y: locationY))) {
        
            print("YO")
        } else{
            myLine.path = pathToDraw
            CGPathAddLineToPoint(pathToDraw, nil, locationX, locationY)
        
            self.oldPosX = locationX
            self.oldPosY = locationY
        }
        
    }
    
    
    
//    override func update(currentTime: NSTimeInterval) {
//        
//        let pathToDraw: CGMutablePath = CGPathCreateMutable()
//        let myLine: SKShapeNode = SKShapeNode(path: pathToDraw)
//        
//        
//        var locationX = p1.position.x
//        var locationY = p1.position.y
////        print(p1.physicsBody)
//        
//        
//        if !dead {
//            dispatch_async(dispatch_get_main_queue(), {
//                
//                
//                CGPathMoveToPoint(pathToDraw, nil, self.oldPosX, self.oldPosY)
//                CGPathAddLineToPoint(pathToDraw, nil, locationX, locationY)
//                
//                self.oldPosX = locationX
//                self.oldPosY = locationY
//                
//                myLine.path = pathToDraw
//                myLine.strokeColor = SKColor.greenColor()
//                myLine.lineWidth = 3.0
//              
//                
//                self.gameArea.addChild(myLine)
//                
//            })
//        }
//
//        
//        
//        
//    }

    
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
        let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
        let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
        let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
        p1.physicsBody?.velocity = CGVectorMake(direction.x * 80, direction.y * 80)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            if leftBtn.containsPoint(location){
                
                changeDirectionL()
                myTimer1 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionL), userInfo: nil, repeats: true)
                
            }
            else if rightBtn.containsPoint(location){
                changeDirectionR()
                
                myTimer2 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionR), userInfo: nil, repeats: true)
            }
        }
    
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        myTimer1.invalidate()
        myTimer2.invalidate()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("dead")
        dead = true
        p1.physicsBody?.dynamic = false
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        print("Yo")
    }
    
    func changeDirectionL(){
//        print(timer.userInfo)
        let alt = pointToRadian(wayPoints[0])
        wayPoints[0] = radianToPoint(alt+5)
        changeDirection(wayPoints[0])
    }
    func changeDirectionR(){
        let alt = pointToRadian(wayPoints[0])
        wayPoints[0] = radianToPoint(alt-5)
        changeDirection(wayPoints[0])
    }
    
    
}