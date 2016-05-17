////
////  GameScene.swift
////  CurveFever
////
////  Created by Moritz Martin on 07.03.16.
////  Copyright (c) 2016 Moritz Martin. All rights reserved.
////
import SpriteKit


//Pysics Categories
struct PhysicsCat{
    static let p1Cat : UInt32 = 0x1 << 1
    static let gameAreaCat : UInt32 = 0x1 << 2
    static let p1TailCat : UInt32 = 0x1 << 3
    static let itemCat : UInt32 = 0x1 << 4
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //***********************************************************************************
    //***********************************************************************************
    //                                  Variablen Start
    //***********************************************************************************
    //***********************************************************************************
    
    
    //Curve + Properties
    var lineNode = SKShapeNode()
    var lastPoint = CGPointZero
    var wayPoints: [CGPoint] = []
    let p1 = SKShapeNode(circleOfRadius: 3.0)
    var xCurve: CGFloat = 1.0
    var yCurve: CGFloat = 1.0
    var path = CGPathCreateMutable()
    
    
    
    //Layout
    var texture = SKTexture()
    var gameArea = SKShapeNode()
    var dead = false
    var leftBtn = SKShapeNode()
    var rightBtn = SKShapeNode()
    var btnWidth:CGFloat = 30.0
    var lineContainer = SKNode()
    var lineCanvas:SKSpriteNode?
    var leftBtnImage = SKSpriteNode()
    var rightBtnImage = SKSpriteNode()

   
    
    //Timer
    var myTimer1 : NSTimer = NSTimer()
    var myTimer2 : NSTimer = NSTimer()
    var jumpTimer: NSTimer = NSTimer()
    
    
    
    // Vars for Items
    var item = SKSpriteNode()
    var lineThickness: CGFloat = 5.0
    var gapTimer = true
    var gapLength = 0.17
    var test = CGFloat(1)
    var itemList = [SKSpriteNode]()
    
    
    //***********************************************************************************
    //***********************************************************************************
    //                                  Variablen End
    //***********************************************************************************
    //***********************************************************************************
    
    
    
    override func didMoveToView(view:SKView) {
        scaleMode = .ResizeFill
        backgroundColor = SKColor.blackColor()
        
        physicsWorld.contactDelegate = self
        
        leftBtn = SKShapeNode(rectOfSize: CGSize(width: 2 * btnWidth, height: view.frame.height / 2))
        rightBtn = SKShapeNode(rectOfSize: CGSize(width: 2 * btnWidth, height: view.frame.height / 2))
        
        
        
        gameArea = SKShapeNode(rect: CGRect(x: 2 * btnWidth + 10, y: 5, width: view.frame.width - (4*btnWidth+20), height: view.frame.height - 10))
        gameArea.lineWidth = 5
        gameArea.strokeColor = SKColor.whiteColor()
        
        
        p1.fillColor = SKColor.blueColor()
        p1.strokeColor = SKColor.blueColor()
        p1.physicsBody = SKPhysicsBody(circleOfRadius: 2)
        p1.physicsBody!.categoryBitMask = PhysicsCat.p1Cat
        p1.physicsBody!.contactTestBitMask = PhysicsCat.gameAreaCat | PhysicsCat.p1Cat | PhysicsCat.p1TailCat
        p1.physicsBody?.affectedByGravity = false
        p1.physicsBody?.linearDamping = 0
        
        leftBtn.position = CGPoint(x: btnWidth, y: view.frame.height / 4 )
        leftBtn.fillColor = p1.fillColor
        
        rightBtn.position = CGPoint(x: view.frame.width - btnWidth, y: view.frame.height / 4)
        rightBtn.fillColor = p1.fillColor
        
        
        gameArea.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 2 * btnWidth + 10, y: 5, width: view.frame.width - (4*btnWidth+20), height: view.frame.height - 10))
        gameArea.physicsBody!.categoryBitMask = PhysicsCat.gameAreaCat
        gameArea.physicsBody?.contactTestBitMask = PhysicsCat.p1Cat
        gameArea.physicsBody?.affectedByGravity = false
        gameArea.physicsBody?.dynamic = false
        
        
        
        leftBtnImage = SKSpriteNode(imageNamed: "leftBtn")
        leftBtnImage.position = CGPoint(x: btnWidth, y: view.frame.height / 4 )
        leftBtnImage.setScale(1.2)
        rightBtnImage = SKSpriteNode(imageNamed: "rightBtn")
        rightBtnImage.position = CGPoint(x: view.frame.width - btnWidth, y: view.frame.height / 4)
        rightBtnImage.setScale(1.2)
        
        
        addChild(p1)
        addChild(gameArea)
        addChild(leftBtn)
        addChild(leftBtnImage)
        addChild(rightBtn)
        addChild(rightBtnImage)
        
       
        addChild(lineContainer)
        lineCanvas = SKSpriteNode(color:SKColor.clearColor(),size:view.frame.size)
        lineCanvas!.anchorPoint = CGPointZero
        lineCanvas!.position = CGPointZero
        lineContainer.addChild(lineCanvas!)
        lastPoint = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
        
    }
    
    
    
    //***********************************************************************************
    //***********************************************************************************
    //                                  Functions Start
    //***********************************************************************************
    //***********************************************************************************
    
    
    
    // Für Kurve -> Punkt zu Radius
    func pointToRadian(targetPoint: CGPoint) -> Double{
        let deltaX = targetPoint.x;
        let deltaY = targetPoint.y;
        let rad = atan2(deltaY, deltaX); // In radians
        return ( Double(rad) * (180 / M_PI))
    }
    
    //Für Kurve -> Radius zu Punkt
    func radianToPoint(rad: Double) -> CGPoint{
        return CGPoint(x: cos(rad*(M_PI/180))*141, y: sin(rad*(M_PI/180))*141)
    }
    
    
    
    //Für Kurve + Geschwindigkeit
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
    
    //Linkskurve
    func changeDirectionL(){
        //        print(timer.userInfo)
        let alt = pointToRadian(wayPoints[0])
        wayPoints[0] = radianToPoint(alt+5)
        changeDirection(wayPoints[0])
    }
    
    //Rechtskurve
    func changeDirectionR(){
        let alt = pointToRadian(wayPoints[0])
        wayPoints[0] = radianToPoint(alt-5)
        changeDirection(wayPoints[0])
        
    }
    
    
    //Erstellt + zeichnet linie, macht Lücken
    func drawLine() {
        if (CGPathIsEmpty(path)) {
            // Create a new line that starts where the previous line ended
            CGPathMoveToPoint(path, nil, lastPoint.x, lastPoint.y)
            lineNode.path = nil
            lineNode.lineWidth = lineThickness
            lineNode.strokeColor = SKColor.blueColor()
            var holeRandom = arc4random() % 100
            
            if holeRandom == 5{
                gapTimer = false
                let holeTimer = NSTimer.scheduledTimerWithTimeInterval(gapLength, target: self, selector: #selector(GameScene.makeHole), userInfo: nil, repeats: false)
                
            }else if gapTimer{
                lineContainer.addChild(lineNode)
            }
            
        }
        var x = lastPoint.x + xCurve
        var y = lastPoint.y + yCurve
        CGPathAddLineToPoint(path, nil, x, y)
        let point = SKShapeNode(circleOfRadius: 2.0)
        lineNode.path = path
        p1.position = CGPoint(x: x, y: y)
        lastPoint = CGPointMake(x, y)
        wayPoints.append(CGPoint(x:x,y:y))
    }
    
    func makeHole(){
        gapTimer = true
    }
    
    
    
    
    override func update(currentTime: CFTimeInterval) {

        var rand = arc4random() % 500
        if rand == 10{

            makeRandomItems()
        }
        
        if !dead{
            drawLine()
            addLinesToTexture()
        }
  
    }

    //Erstellt zufällige Items, mit zufälligen Positionen
    func makeRandomItems(){
        
        var pos = CGPoint()
        var imageName = String()
        let minX = (2*btnWidth+20)
        let maxX = view!.frame.width
        let minY: CGFloat = 20.0
        let maxY = view!.frame.height
        
        pos.x = minX +  CGFloat(arc4random()) % (maxX - (2*minX))
        pos.y = minY + CGFloat(arc4random()) % (maxY - 2*minY)
        
        //item = ItemObject(imageName: "testItem", itemAction: "test",itemPosition: pos, itemName: "test")
//        item!.position = pos
//        item.name = "test" + String(ii)
        
        
        //wenn es mehr Items gibt, zahl erhöhen
        var nameRandom = 1 + arc4random() % 2
        
        switch nameRandom{
        
        case 1:
            imageName = "testItem"
        case 2:
            imageName = "fatItem"
            
        //wenn mehr Items
        //case 3:...
        default:
            break
        }
        item = SKSpriteNode(imageNamed: imageName)
        item.name = imageName
        item.setScale(0.6)
        item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height / 2)
        item.physicsBody!.categoryBitMask = PhysicsCat.itemCat
        item.physicsBody!.contactTestBitMask =  PhysicsCat.p1Cat
        item.physicsBody?.affectedByGravity = false
        item.physicsBody?.linearDamping = 0
        item.position = pos
        if !(item.position == CGPoint(x: 0.0, y: 0.0)){
            addChild(item)
            itemList.append(item)
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

        if (contact.bodyA.categoryBitMask == PhysicsCat.itemCat) || contact.bodyB.categoryBitMask == PhysicsCat.itemCat{
            for var i = 0; i < itemList.count; i = i+1{
                if contact.bodyB.node!.position == itemList[i].position{
                    itemList[i].removeFromParent()
                    
                    switch contact.bodyB.node!.name!{
                    
                    case "testItem":
                        test = 2
                        gapLength = 0.09
                        xCurve = xCurve * 2
                        yCurve = yCurve * 2
                        _ = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(GameScene.lowerSpeed), userInfo: nil, repeats: false)
                    case "fatItem":
                        lineThickness = lineThickness + 4.0
                        gapLength = gapLength + 0.05
                        _ = NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: #selector(GameScene.lowerThickness), userInfo: nil, repeats: false)
                    default:
                        break
                    }
                    
                    
                }
                
            }
        }else{
            print("dead")
            dead = true
            //      p1.physicsBody?.dynamic = false
        }
   
    }
        
    func didEndContact(contact: SKPhysicsContact) {
        print("Yo")
    }
    
    //***********************************************************************************
    //***********************************************************************************
    //                                  Item-Functions Start
    //***********************************************************************************
    //***********************************************************************************
    
    func lowerSpeed(){
        test = 1
        gapLength = 0.17
//        xCurve = xCurve / 2
//        yCurve = yCurve / 2
    }
    
    func lowerThickness(){
        lineThickness = lineThickness - 4.0
        gapLength = gapLength-0.05
    }

    //***********************************************************************************
    //***********************************************************************************
    //                                  Functions End
    //***********************************************************************************
    //***********************************************************************************
    
}



