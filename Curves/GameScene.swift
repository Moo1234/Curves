////
////  GameScene.swift
////  CurveFever
////
////  Created by Moritz Martin on 07.03.16.
////  Copyright (c) 2016 Moritz Martin. All rights reserved.
////
import SpriteKit


struct PhysicsCat{
    static let p1Cat : UInt32 = 0x1 << 1
    static let gameAreaCat : UInt32 = 0x1 << 2
    static let p1TailCat : UInt32 = 0x1 << 3
    static let itemCat : UInt32 = 0x1 << 4
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var lineContainer = SKNode()
    var lineCanvas:SKSpriteNode?
    var lineNode = SKShapeNode()
    var linePhy = SKShapeNode()
    
    var firstTime = true
    
    
    var texture = SKTexture()
    var gameArea = SKShapeNode()
    var dead = false
    
    var linePoints = [SKShapeNode()]
    
    var leftBtn = SKShapeNode()
    var rightBtn = SKShapeNode()
    
    var lastDrawTime:Int64 = 0
    var lineCount = 0
    var timeScan:Int64 = 0
    var path = CGPathCreateMutable()
    
    var lastPoint = CGPointZero
    
    var wayPoints: [CGPoint] = []
    
    let p1 = SKShapeNode(circleOfRadius: 3.0)
    var xCurve: CGFloat = 1.0
    var yCurve: CGFloat = 1.0
    
    
    var myTimer1 : NSTimer = NSTimer()
    var myTimer2 : NSTimer = NSTimer()
    var jumpTimer: NSTimer = NSTimer()
    
    
    var btnWidth:CGFloat = 30.0
    var yo = true
    var item = SKSpriteNode()
    
    var test = CGFloat(1)
    
    
    
    override func didMoveToView(view:SKView) {
        scaleMode = .ResizeFill
        backgroundColor = SKColor.blackColor()
        
        physicsWorld.contactDelegate = self
        
        leftBtn = SKShapeNode(rectOfSize: CGSize(width: 2 * btnWidth, height: view.frame.height / 2))
        rightBtn = SKShapeNode(rectOfSize: CGSize(width: 2 * btnWidth, height: view.frame.height / 2))
        
        
        gameArea = SKShapeNode(rect: CGRect(x: 2 * btnWidth + 10, y: 5, width: view.frame.width - (4*btnWidth+20), height: view.frame.height - 10))
        gameArea.lineWidth = 5
        gameArea.strokeColor = SKColor.whiteColor()
        
        
        p1.fillColor = SKColor.greenColor()
        p1.strokeColor = SKColor.greenColor()
        p1.physicsBody = SKPhysicsBody(circleOfRadius: 2)
        p1.physicsBody!.categoryBitMask = PhysicsCat.p1Cat
        p1.physicsBody!.contactTestBitMask = PhysicsCat.gameAreaCat | PhysicsCat.p1Cat | PhysicsCat.p1TailCat
        p1.physicsBody?.affectedByGravity = false
        p1.physicsBody?.linearDamping = 0
        
        leftBtn.position = CGPoint(x: btnWidth, y: view.frame.height / 4 )
        leftBtn.fillColor = SKColor.blueColor()
        
        
        rightBtn.position = CGPoint(x: view.frame.width - btnWidth, y: view.frame.height / 4)
        rightBtn.fillColor = SKColor.blueColor()
        
        
        gameArea.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 2 * btnWidth + 10, y: 5, width: view.frame.width - (4*btnWidth+20), height: view.frame.height - 10))
        gameArea.physicsBody!.categoryBitMask = PhysicsCat.gameAreaCat
        gameArea.physicsBody?.contactTestBitMask = PhysicsCat.p1Cat
        gameArea.physicsBody?.affectedByGravity = false
        gameArea.physicsBody?.dynamic = false
        
        
        addChild(p1)
        addChild(gameArea)
        addChild(leftBtn)
        addChild(rightBtn)
        
       
        addChild(lineContainer)
        lineCanvas = SKSpriteNode(color:SKColor.clearColor(),size:view.frame.size)
        lineCanvas!.anchorPoint = CGPointZero
        lineCanvas!.position = CGPointZero
        lineContainer.addChild(lineCanvas!)
        lastPoint = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
        
        
        
//        physicsBody = SKPhysicsBody(polygonFromPath: path)
//        physicsBody?.categoryBitMask = PhysicsCat.p1TailCat
//        physicsBody?.contactTestBitMask = PhysicsCat.p1Cat
        
        
        
        //        wayPoints.append(CGPoint(x: 100,y: 100))
        //        let targetPoint = wayPoints[0]
        //        changeDirection(targetPoint)
        
        
        
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
        let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
        let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
        let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
        xCurve = direction.x * test
        yCurve = direction.y * test
        
        
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
    
    
    func drawLine() {
        if (CGPathIsEmpty(path)) {
            // Create a new line that starts where the previous line ended
            CGPathMoveToPoint(path, nil, lastPoint.x, lastPoint.y)
            lineNode.path = nil
            lineNode.lineWidth = 5.0
            lineNode.strokeColor = SKColor.greenColor()
            
            lineContainer.addChild(lineNode)
        }
        // Add a random line segment
        
        
        var x = lastPoint.x + xCurve
        var y = lastPoint.y + yCurve
        CGPathAddLineToPoint(path, nil, x, y)
        let point = SKShapeNode(circleOfRadius: 2.0)
        lineNode.path = path
        p1.position = CGPoint(x: x, y: y)
        lastPoint = CGPointMake(x, y)
        wayPoints.append(CGPoint(x:x,y:y))
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        var rand = arc4random() % 30
        if rand == 10 && yo == true{
            print("YO")
            item = ItemObject(imageName: "testItem", itemAction: "test", itemPosition: CGPoint(x: 500,y:500), itemName: "test")
            item.setScale(0.5)
//            item1.position = CGPoint(x: 100, y: 100)
            addChild(item)
            yo = false
        }
        
        if !dead{
            drawLine()
            addLinesToTexture()
        }
        
        
        
    }
    
    func addLinesToTexture () {
        // Convert the contents of the line container to an SKTexture
        texture = self.view!.textureFromNode(lineContainer)!
        lineCanvas!.texture = texture
        lineNode.removeFromParent()
        path = CGPathCreateMutable()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        //print("dead " , contact.bodyA == p1.physicsBody , " " , contact.bodyB)
       
        
        if (contact.bodyA.categoryBitMask == PhysicsCat.itemCat) || contact.bodyB.categoryBitMask == PhysicsCat.itemCat{
            item.removeFromParent()
            test = 2
            xCurve = xCurve * 2
            yCurve = yCurve * 2
            
        }else{
            print("dead")
            dead = true
            //      p1.physicsBody?.dynamic = false
        }
        
        
    }
        
    func didEndContact(contact: SKPhysicsContact) {
        print("Yo")
    }

    
}




//import SpriteKit
//
//struct PhysicsCat{
//    static let p1Cat : UInt32 = 0x1 << 1
//    static let gameAreaCat : UInt32 = 0x1 << 2
//    static let p1TailCat : UInt32 = 0x1 << 3
//    
//}
//
//class GameScene: SKScene, SKPhysicsContactDelegate {
//    
//    
//    var leftBtn = SKShapeNode()
//    var rightBtn = SKShapeNode()
//    var gameArea = SKShapeNode()
//    var dead = false
//    
//    
//    var wayPoints: [CGPoint] = []
//    var pressed: Bool = false
//    
//    var velocity = CGPoint(x: 0, y: 0)
//    
//    
//    
//    var myTimer1 : NSTimer = NSTimer()
//    var myTimer2 : NSTimer = NSTimer()
//    var test : NSTimer = NSTimer()
//    
//    var lineContainer = SKNode()
//    var lineCanvas:SKSpriteNode?
//    var lineNode = SKShapeNode()
//    
//    var lastPoint = CGPointZero
//    var pathToDraw = CGPathCreateMutable()
//    var xCurve: CGFloat = 3.0
//    var yCurve: CGFloat = 3.0
//    
//    
//    override func didMoveToView(view: SKView) {
//        backgroundColor = SKColor.blackColor()
//        
//        physicsWorld.contactDelegate = self
//        
//        
//        
//        addChild(lineContainer)
//        lineCanvas = SKSpriteNode(color:SKColor.clearColor(),size: frame.size)
//        lineCanvas!.anchorPoint = CGPointZero
//        lineCanvas!.position = CGPointZero
//        lineContainer.addChild(lineCanvas!)
//        lastPoint = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
//        
//        //        gameArea = SKShapeNode(rect: CGRect(x: 130, y: 100, width: frame.width - 250, height: frame.height - 200))
//        //        gameArea.lineWidth = 5
//        //        gameArea.strokeColor = SKColor.whiteColor()
//        //        gameArea.position = CGPoint(x: 0, y: 0 )
//        
//        
//        //        leftBtn = SKShapeNode(rectOfSize: CGSize(width: frame.width / 10, height: self.frame.height / 2))
//        //        rightBtn = SKShapeNode(rectOfSize: CGSize(width: frame.width / 10, height: frame.height / 2))
//        //
//        //
//        //
//        //
//        //        leftBtn.position = CGPoint(x: (((frame.width / 10)/2) + frame.width) - frame.width, y: (frame.height /
//        //            2 - frame.height / 4) + 100)
//        //        leftBtn.fillColor = SKColor.blueColor()
//        //
//        //
//        //        rightBtn.position = CGPoint(x: frame.width - ((frame.width/10)/2), y: frame.height/2)
//        //        rightBtn.fillColor = SKColor.blueColor()
//        //
//        
//        
//        //
//        //        p1.position = CGPoint(x: frame.width / 2, y: frame.height / 2 )
//        //        p1.fillColor = SKColor.greenColor()
//        //        p1.strokeColor = SKColor.greenColor()
//        //        p1.lineWidth = 2.0
//        //        p1.physicsBody = SKPhysicsBody(circleOfRadius: 2)
//        //        p1.physicsBody!.categoryBitMask = PhysicsCat.p1Cat
//        //        p1.physicsBody!.contactTestBitMask = PhysicsCat.gameAreaCat | PhysicsCat.p1Cat | PhysicsCat.p1TailCat
//        //        p1.physicsBody?.affectedByGravity = false
//        //        p1.physicsBody?.linearDamping = 0
//        
//        // gameArea.addChild(p1)
//        
//        
//        //SKPhysicsBody(rectangleOfSize: CGSize(width:frame.width - 250 , height: frame.height - 600))
//        //        gameArea.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 130, y: 100, width: frame.width - 250, height: frame.height - 200))
//        //        gameArea.physicsBody!.categoryBitMask = PhysicsCat.gameAreaCat
//        //        gameArea.physicsBody?.contactTestBitMask = PhysicsCat.p1Cat
//        //        gameArea.physicsBody?.affectedByGravity = false
//        //        gameArea.physicsBody?.dynamic = false
//        
//        
//        //        wayPoints.append(CGPoint(x: 100,y: 100))
//        //        let targetPoint = wayPoints[0]
//        //        changeDirection(targetPoint)
//        //
//        
//        
//        //        addChild(gameArea)
//        //        addChild(leftBtn)
//        //        addChild(rightBtn)
//    }
//    
//    
//    
//    
//    func drawLine() {
//        if (CGPathIsEmpty(pathToDraw)) {
//            // Create a new line that starts where the previous line ended
//            CGPathMoveToPoint(pathToDraw, nil, lastPoint.x, lastPoint.y)
//            lineNode.path = nil
//            lineNode.lineWidth = 5.0
//            lineNode.strokeColor = SKColor.greenColor()
//            lineContainer.addChild(lineNode)
//        }
//        var x = lastPoint.x + xCurve
//        var y = lastPoint.y + yCurve
//        CGPathAddLineToPoint(pathToDraw, nil, x, y)
//        lineNode.path = pathToDraw
//        lastPoint = CGPointMake(x, y)
//        wayPoints.append(CGPoint(x:x,y:y))
//    }
//    
//    func addLinesToTexture () {
//        // Convert the contents of the line container to an SKTexture
//        let texture = self.view!.textureFromNode(lineContainer)
//        // Display the texture
//        lineCanvas!.texture = texture
//        // Start a new line
//        lineNode.removeFromParent()
//        pathToDraw = CGPathCreateMutable()
//    }
//    
//    
//    override func update(currentTime: NSTimeInterval) {
//        //
//        drawLine()
//        addLinesToTexture()
//        
//        //        let pathToDraw: CGMutablePath = CGPathCreateMutable()
//        //        let myLine: SKShapeNode = SKShapeNode(path: pathToDraw)
//        //
//        //
//        //
//        //        if !dead {
//        //            dispatch_async(dispatch_get_main_queue(), {
//        //
//        //
//        //                CGPathMoveToPoint(pathToDraw, nil, self.oldPosX, self.oldPosY)
//        //                CGPathAddLineToPoint(pathToDraw, nil, locationX, locationY)
//        //
//        //                self.oldPosX = locationX
//        //                self.oldPosY = locationY
//        //
//        //                myLine.path = pathToDraw
//        //                myLine.strokeColor = SKColor.greenColor()
//        //                myLine.lineWidth = 3.0
//        //
//        //
//        //
//        //
//        //                self.gameArea.addChild(myLine)
//        //
//        //            })
//        //        }
//        //
//    }
//    
//    
//    
//    func pointToRadian(targetPoint: CGPoint) -> Double{
//        let deltaX = targetPoint.x;
//        let deltaY = targetPoint.y;
//        let rad = atan2(deltaY, deltaX); // In radians
//        return ( Double(rad) * (180 / M_PI))
//    }
//    
//    func radianToPoint(rad: Double) -> CGPoint{
//        return CGPoint(x: cos(rad*(M_PI/180))*141, y: sin(rad*(M_PI/180))*141)
//    }
//    
//    func changeDirection(targetPoint: CGPoint){
//        let currentPosition = position
//        let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
//        let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
//        let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
//        //p1.physicsBody?.velocity = CGVectorMake(direction.x * 80, direction.y * 80)
//        xCurve = direction.x * 3
//        yCurve = direction.y * 3
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            if leftBtn.containsPoint(location){
//                
//                changeDirectionL()
//                myTimer1 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionL), userInfo: nil, repeats: true)
//                
//            }
//            else if rightBtn.containsPoint(location){
//                changeDirectionR()
//                
//                myTimer2 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionR), userInfo: nil, repeats: true)
//            }
//        }
//        
//    }
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        myTimer1.invalidate()
//        myTimer2.invalidate()
//    }
//    
//    func didBeginContact(contact: SKPhysicsContact) {
//        //        print("dead " , contact.bodyA == p1.physicsBody , " " , contact.bodyB)
//        print("dead")
//        dead = true
//        //        p1.physicsBody?.dynamic = false
//    }
//    
//    func didEndContact(contact: SKPhysicsContact) {
//        print("Yo")
//    }
//    
//    func changeDirectionL(){
//        //        print(timer.userInfo)
//        let alt = pointToRadian(wayPoints[0])
//        wayPoints[0] = radianToPoint(alt+5)
//        changeDirection(wayPoints[0])
//    }
//    func changeDirectionR(){
//        let alt = pointToRadian(wayPoints[0])
//        wayPoints[0] = radianToPoint(alt-5)
//        changeDirection(wayPoints[0])
//    }
//    
//    
//}



//
//  GameScene.swift
//  test
//
//  Created by Moritz Martin on 28.04.16.
//  Copyright (c) 2016 Moritz Martin. All rights reserved.
//

