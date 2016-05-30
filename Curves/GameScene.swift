////
////  GameScene.swift
////  CurveFever
////
////  Created by Moritz Martin on 07.03.16.
////  Copyright (c) 2016 Moritz Martin. All rights reserved.
////
import SpriteKit
import Firebase



//Pysics Categories
struct PhysicsCat{
    static let p1Cat : UInt32 = 0x1 << 1
    static let gameAreaCat : UInt32 = 0x1 << 2
    static let p1TailCat : UInt32 = 0x1 << 3
    static let itemCat : UInt32 = 0x1 << 4
    static let bombCat : UInt32 = 0x1 << 5
    
}

struct GameData{
    static var id = ""
    static var gID = 0
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    //***********************************************************************************
    //***********************************************************************************
    //                                  Variablen Start
    //***********************************************************************************
    //***********************************************************************************
    
    let refP2 = FIRDatabase.database().reference().child("p2")
    
    
    let ref = FIRDatabase.database().reference()
    
    
    
    
    //Curve + Properties
    var lineNode = SKShapeNode()
    var lastPoint = CGPointZero
    var wayPoints: [CGPoint] = []
    var p1 = SKShapeNode(circleOfRadius: 2.0)
    var p2 = SKShapeNode(circleOfRadius: 2.0)
    var p1Size: CGFloat = 2.0
    var xCurve: CGFloat = 1.0
    var yCurve: CGFloat = 1.0
    var curveRadius = 5.0
    var path = CGPathCreateMutable()
    var p1NewSize = SKShapeNode()
    var playerID: Int = Int()
    
    
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
    var bomb = SKSpriteNode()
    var bombList = [SKSpriteNode]()
    var item = SKSpriteNode()
    var lineThickness: CGFloat = 5.0
    var gapTimer = true
    var gapLength = 0.17
    var curveSpeed = CGFloat(1)
    var itemList = [SKSpriteNode]()
    var switchDirBool = false
    
    var firstTime = true
    
    var positionList = [CGPoint]()
    
    var gameID = ""
    
    // Players
    var playerIDs = [String]()
    var colors = [String]()
    
    //***********************************************************************************
    //***********************************************************************************
    //                                  Variablen End
    //***********************************************************************************
    //***********************************************************************************
    
    
    
    override func didMoveToView(view:SKView) {
        scaleMode = .ResizeFill
        backgroundColor = SKColor.blackColor()
        
        physicsWorld.contactDelegate = self
        playerID = 1
        
        
        
        
        leftBtn = SKShapeNode(rectOfSize: CGSize(width: 2 * btnWidth, height: view.frame.height / 2))
        rightBtn = SKShapeNode(rectOfSize: CGSize(width: 2 * btnWidth, height: view.frame.height / 2))
        
        
        
        gameArea = SKShapeNode(rect: CGRect(x: 2 * btnWidth + 10, y: 5, width: view.frame.width - (4*btnWidth+20), height: view.frame.height - 10))
        gameArea.lineWidth = 5
        gameArea.strokeColor = SKColor.whiteColor()
        
        
        p1.fillColor = SKColor.cyanColor()
        p1.strokeColor = SKColor.cyanColor()
        p2.fillColor = SKColor.redColor()
        p2.strokeColor = SKColor.redColor()
        p1.physicsBody = SKPhysicsBody(circleOfRadius: p1Size)
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
        addChild(p2)
        
       
        addChild(lineContainer)
        lineCanvas = SKSpriteNode(color:SKColor.clearColor(),size:view.frame.size)
        lineCanvas!.anchorPoint = CGPointZero
        lineCanvas!.position = CGPointZero
        lineContainer.addChild(lineCanvas!)
        lastPoint = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
        
        self.gameID = GameData.id
        
        loadPlayers()
        
    }
    
    var lineNode2 = SKShapeNode()
    var lastPoint2 = CGPointZero
    var path2 = CGPathCreateMutable()
    var wayPoints2: [CGPoint] = []
    
    func loadPlayers(){
        let pID: String = (FIRAuth.auth()?.currentUser?.uid)!
        FIRDatabase.database().reference().child("PlayersInGames").observeSingleEventOfType(.Value, withBlock: { (snap: FIRDataSnapshot) in
            // Get gameID

            let postArr = snap.value as! NSArray
            for var i = 0; i < postArr.count; i=i+1 {
                if postArr[i].valueForKey("gID") as! Int == GameData.gID {
                    if postArr[i].valueForKey("pID") as! String != pID {
                        self.playerIDs.append(postArr[i].valueForKey("pID") as! String)
                    }else{
                        self.p1.fillColor = self.hexStringToUIColor(postArr[i].valueForKey("color") as! String)
                        self.p1.strokeColor = self.hexStringToUIColor(postArr[i].valueForKey("color") as! String)
                    }
                    self.colors.append(postArr[i].valueForKey("color") as! String)
                }
            }
            
            // set own Player settings
            if self.gameID == pID {
                self.ref.child("RunningGame/"+self.gameID).child("Items").setValue(["category": 0, "posX": 0, "posY": 0])
                if self.gameID != "" {
                    FIRDatabase.database().reference().child("RunningGame/"+self.gameID+"/Players").child(pID).setValue(["pID": pID, "PositionX": self.p1.position.x,"PositionY": self.p1.position.y,"lineWidth":self.p1Size])
                }
            }
            
            if self.gameID != pID {
                FIRDatabase.database().reference().child("RunningGame/"+self.gameID).child("Items").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                    // Get Items
                    let postArr2 = snap.value as! NSDictionary
                    let pos = CGPoint(x: postArr2.valueForKey("posX") as! CGFloat, y: postArr2.objectForKey("posY") as! CGFloat)
                    let nameRandom = postArr2.objectForKey("category") as! Int
                    self.makeItems(pos, nameRandom: UInt32(nameRandom))
                }
            }
            
            
            
            
            
            // load other players
            FIRDatabase.database().reference().child("RunningGame/"+self.gameID).child("Players").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                // Get user value
                let postArr3 = snap.value as! NSDictionary
                for var i = 0; i < postArr3.allValues.count; i=i+1 {
                    if (postArr3.allValues[i].objectForKey("pID") as! String) != pID {
                        self.p2.position.x = postArr3.allValues[i].objectForKey("PositionX") as! CGFloat
                        self.p2.position.y = postArr3.allValues[i].objectForKey("PositionY") as! CGFloat
//                        self.p2.position.y = postArr3.allValues[i].objectForKey("lineWidth") as! CGFloat
                        
                        self.drawLine2(self.p2.position)
                        self.addLinesToTexture2()
                    }
                }
                
                
//                self.p2.position.x = snap.value?.objectForKey("PositionX") as! CGFloat
//                self.p2.position.y = snap.value?.objectForKey("PositionY") as! CGFloat
    
//                self.drawLine2(self.p2.position)
//                self.addLinesToTexture2()
                
            }
        })
    }
    
    func drawLine2(pPosition: CGPoint){
       
        
        
        if (CGPathIsEmpty(path2)) {
            CGPathMoveToPoint(path2, nil, pPosition.x, pPosition.y)
            lineNode2.path = nil
            lineNode2.lineWidth = lineThickness
            lineNode2.strokeColor = SKColor.redColor()
            lineContainer.addChild(lineNode2)
            
        }
        
        var x = pPosition.x + xCurve
        var y = pPosition.y + yCurve
        
        CGPathAddLineToPoint(path2, nil, x, y)
        lineNode2.path = path2
        p2.position = CGPoint(x: x, y: y)
        
//        pPosition = CGPointMake(x, y)
        wayPoints2.append(CGPoint(x:x,y:y))

        
        
    }
    
    func addLinesToTexture2 () {
        // Convert the contents of the line container to an SKTexture
        texture = self.view!.textureFromNode(lineContainer)!
        lineCanvas!.texture = texture
        lineNode2.removeFromParent()
        path2 = CGPathCreateMutable()
        
    }
    
    func pixelFromTexture(texture: SKTexture, position: CGPoint) -> SKColor {
        let view = SKView(frame: CGRectMake(0, 0, 1, 1))
        let scene = SKScene(size: CGSize(width: 1, height: 1))
        let sprite  = SKSpriteNode(texture: texture)
        sprite.anchorPoint = CGPointZero
        sprite.position = CGPoint(x: -floor(position.x), y: -floor(position.y))
        scene.anchorPoint = CGPointZero
        scene.addChild(sprite)
        view.presentScene(scene)
        var pixel: [UInt8] = [0, 0, 0, 0]
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(&pixel, 1, 1, 8, 4,CGColorSpaceCreateDeviceRGB(), bitmapInfo.rawValue)
        UIGraphicsPushContext(context!);
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        UIGraphicsPopContext()
        return SKColor(red: CGFloat(pixel[0]) / 255.0, green: CGFloat(pixel[1]) / 255.0, blue: CGFloat(pixel[2]) / 255.0, alpha: CGFloat(pixel[3]) / 255.0)
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
        xCurve = direction.x * curveSpeed
        yCurve = direction.y * curveSpeed
        
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            if leftBtn.containsPoint(location){
                
                if !switchDirBool{
                    changeDirectionL()
                    myTimer1 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionL), userInfo: nil, repeats: true)
                }else{
                    changeDirectionR()
                    
                    myTimer2 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionR), userInfo: nil, repeats: true)
                }
                
                
            }
            else if rightBtn.containsPoint(location){
                
                if !switchDirBool{
                    changeDirectionR()
                    
                    myTimer2 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionR), userInfo: nil, repeats: true)
                }else{
                    changeDirectionL()
                    myTimer1 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionL), userInfo: nil, repeats: true)
                }
                
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
        wayPoints[0] = radianToPoint(alt+curveRadius)
        changeDirection(wayPoints[0])
    }
    
    //Rechtskurve
    func changeDirectionR(){
        let alt = pointToRadian(wayPoints[0])
        wayPoints[0] = radianToPoint(alt-curveRadius)
        changeDirection(wayPoints[0])
        
    }
    
    
    //Erstellt + zeichnet linie, macht Lücken
    func drawLine() {
        if (CGPathIsEmpty(path)) {
            CGPathMoveToPoint(path, nil, lastPoint.x, lastPoint.y)
            lineNode.path = nil
            lineNode.lineWidth = lineThickness
            lineNode.strokeColor = p1.strokeColor
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
        lineNode.path = path
        p1.position = CGPoint(x: x, y: y)
        pushLine()

        lastPoint = CGPointMake(x, y)
        wayPoints.append(CGPoint(x:x,y:y))
    }
    
    
    func pushLine(){
        let pID: String = (FIRAuth.auth()?.currentUser?.uid)!
        if self.gameID != "" {
            FIRDatabase.database().reference().child("RunningGame/"+self.gameID+"/Players").child(pID).setValue(["pID": pID, "PositionX": self.p1.position.x,"PositionY": self.p1.position.y,"lineWidth":self.p1Size])
        }
//        self.ref.child("p"+String(playerID)+"/PositionX").setValue(p1.position.x)
//        self.ref.child("p"+String(playerID)+"/PositionY").setValue(p1.position.y)
    
    }
    
    func pushItem(category: UInt32, posX: CGFloat, posY: CGFloat){
        self.ref.child("RunningGame/"+gameID).child("Items").setValue(["category": Int(category), "posX": posX, "posY": posY])
    }
    
    func makeHole(){
        gapTimer = true
    }
    
 
    override func update(currentTime: CFTimeInterval) {
        let pID: String = (FIRAuth.auth()?.currentUser?.uid)!
        if gameID == pID {
            let rand = arc4random() % 500
            if rand == 10{
                //wenn es mehr Items gibt, zahl erhöhen
                let nameRandom = 1 + arc4random() % 4
                
                let pos = makeRandomPos()
                pushItem(nameRandom, posX: pos.x, posY: pos.y)
                makeItems(pos, nameRandom: nameRandom)
            }
        }
        if !dead{
            drawLine()
            addLinesToTexture()
        }
  
        
        
    }

    //Erstellt zufällige Items, mit zufälligen Positionen
    func makeItems(pos: CGPoint, nameRandom: UInt32){
        
//        var pos =
        var imageName = String()
        
        
        //item = ItemObject(imageName: "testItem", itemAction: "curveSpeed",itemPosition: pos, itemName: "curveSpeed")
//        item!.position = pos
//        item.name = "curveSpeed" + String(ii)
        
        
        //wenn es mehr Items gibt, zahl erhöhen
//        var nameRandom = 1 + arc4random() % 4
        
        //        var nameRandom = 3
        
        switch nameRandom{
        
        case 1:
            imageName = "speedItem"
        case 2:
            imageName = "fatItem"
        case 3:
            imageName = "bombItem"
        case 4:
            imageName = "switchDir"
            
        //wenn mehr Items
        //case 4:...
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
                    
                    case "speedItem":
                        increaseSpeed()
                    case "fatItem":
                        increaseThickness()
                    case "bombItem":
                        createBombs()
                    case "switchDir":
                        switchDir()
                    default:
                        break
                    }
                    
                    
                }
                
            }
        }else if (contact.bodyA.categoryBitMask == PhysicsCat.bombCat) || contact.bodyB.categoryBitMask == PhysicsCat.bombCat{
        
            for var i = 0; i < bombList.count; i = i+1{
                if contact.bodyB.node!.position == bombList[i].position{
                    bombList[i].removeFromParent()
                    print("deadiii")
                    dead = true
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
    
    
    func makeRandomPos() -> CGPoint{
        var pos = CGPoint()
        let minX = (2*btnWidth+20)
        let maxX = view!.frame.width
        let minY: CGFloat = 20.0
        let maxY = view!.frame.height
        
        pos.x = minX +  CGFloat(arc4random()) % (maxX - (2*minX))
        pos.y = minY + CGFloat(arc4random()) % (maxY - 2*minY)
        
        
        return pos
    }
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //***********************************************************************************
    //***********************************************************************************
    //                                  Item-Functions Start
    //***********************************************************************************
    //***********************************************************************************
    
    
    func increaseSpeed(){
        curveSpeed = 2
        gapLength = 0.09
        xCurve = xCurve * 2
        yCurve = yCurve * 2
        curveRadius = curveRadius * (3 / 2)
        _ = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(GameScene.lowerSpeed), userInfo: nil, repeats: false)
    }
    
    func lowerSpeed(){
        curveSpeed = 1
        gapLength = 0.17
        curveRadius = curveRadius * (2 / 3)
//        xCurve = xCurve / 2
//        yCurve = yCurve / 2
    }
    
    
    func increaseThickness(){
        lineThickness = lineThickness + 4.0
        gapLength = gapLength + 0.05
        _ = NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: #selector(GameScene.lowerThickness), userInfo: nil, repeats: false)
        p1Size = p1Size + 3.5
        p1.lineWidth = p1Size
//        p1NewSize = SKShapeNode(circleOfRadius: p1Size)
        
        
    }
    
    func lowerThickness(){
        lineThickness = lineThickness - 4.0
        gapLength = gapLength-0.05
        p1Size = p1Size - 3.5
        p1.lineWidth = p1Size
    }
    
    func createBombs(){
        
        for var i = 0; i<5; i=i+1{
            var pos = makeRandomPos()
            
            bomb = SKSpriteNode(imageNamed: "bomb")
            bomb.setScale(0.5)
            
            bomb.physicsBody = SKPhysicsBody(circleOfRadius: bomb.size.width / 1.9)
            bomb.physicsBody!.categoryBitMask = PhysicsCat.bombCat
            bomb.physicsBody!.contactTestBitMask =  PhysicsCat.p1Cat
            bomb.physicsBody?.affectedByGravity = false
            bomb.physicsBody?.linearDamping = 0
            bomb.position = pos
            bombList.append(bomb)
            addChild(bomb)
            
        }
    
    }
    
    func switchDir(){
        switchDirBool = true
        _ = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(GameScene.normalDir), userInfo: nil, repeats: false)
        
    }
    
    func normalDir(){
        switchDirBool = false
    }

    //***********************************************************************************
    //***********************************************************************************
    //                                  Functions End
    //***********************************************************************************
    //***********************************************************************************
    
}



