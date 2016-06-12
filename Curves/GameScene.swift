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
    static var game = Game()
}

class GameScene: SKScene, SKPhysicsContactDelegate, UITableViewDataSource, UITableViewDelegate{
    
    //***********************************************************************************
    //***********************************************************************************
    //                                  Variablen Start
    //***********************************************************************************
    //***********************************************************************************
    
    
//    let refP2 = FIRDatabase.database().reference().child("p2")
    
    
    let ref = FIRDatabase.database().reference()
    
    
    
    
    //Curve + Properties
    var lineNode = SKShapeNode()
    var lastPoint = CGPointZero
    var wayPoints: [CGPoint] = []
    var p1 = SKShapeNode(circleOfRadius: 2.0)
    //    var p2 = SKShapeNode(circleOfRadius: 2.0)
    var p1Size: CGFloat = 2.0
    var xCurve: CGFloat = 1.0
    var yCurve: CGFloat = 1.0
    var curveRadius = 5.0
    var path = CGPathCreateMutable()
    var p1NewSize = SKShapeNode()
    //    var playerID: Int = Int()
    
    
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
    
//    var firstTime = true
    var running = false
    
    var positionList = [CGPoint]()
    
    var gameID = ""
    var ownCurveIndex = -1
    
    // Players
    var scores = [(String, String, Int)]()
    var curves = [LineObject]()
    var players = [PlayerObject]()
    
    // Score
    var scoreView: UIView = UIView()
    var maxScoreLabel = UILabel()
    var scoreTableView: UITableView = UITableView()
    
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
        
        
        //        p1.fillColor = SKColor.cyanColor()
        //        p1.strokeColor = SKColor.cyanColor()
        p1.physicsBody = SKPhysicsBody(circleOfRadius: p1Size)
        p1.physicsBody!.categoryBitMask = PhysicsCat.p1Cat
        p1.physicsBody!.contactTestBitMask = PhysicsCat.gameAreaCat | PhysicsCat.p1Cat | PhysicsCat.p1TailCat
        p1.physicsBody?.affectedByGravity = false
        p1.physicsBody?.linearDamping = 0
        
        
        
        leftBtn.position = CGPoint(x: btnWidth, y: view.frame.height / 4 )
        
        rightBtn.position = CGPoint(x: view.frame.width - btnWidth, y: view.frame.height / 4)
        
        
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
        
        // Score View After each round
        scoreView = UIView(frame: CGRect(x: 2 * btnWidth + 10, y: 5, width: view.frame.width - (4*btnWidth+20), height: view.frame.height - 10))
        scoreTableView = UITableView(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: view.frame.width - (4*btnWidth+20), height: view.frame.height - 10)))
        scoreView.addSubview(scoreTableView)
        scoreView.hidden = true
        scoreTableView.dataSource = self
        scoreTableView.delegate = self
        scoreTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let tblView =  UIView(frame: CGRectZero)
        scoreTableView.tableFooterView = tblView
        scoreTableView.tableFooterView!.hidden = true
        scoreTableView.backgroundColor = UIColor.clearColor()
        
        // maximum rounds
        maxScoreLabel = UILabel(frame:CGRect(origin: CGPoint(x: view.frame.minX, y: view.frame.minY+10 ), size: CGSize(width: 2 * btnWidth, height: 20)))
        maxScoreLabel.font = UIFont.boldSystemFontOfSize(25)
        maxScoreLabel.textAlignment = NSTextAlignment.Center
        maxScoreLabel.textColor = UIColor.whiteColor()
        
        
        
        self.view?.addSubview(scoreView)
        self.view?.addSubview(maxScoreLabel)
        
        self.gameID = GameData.id
        
        
        randomStartingPosition()
        loadPlayers()
        waitForRunning()
    }
    
    // Clear GameArea, remove Items and set new player locations if game is not over
    func newRound(){
        var maxScore = 0
        for var i = 0; i < scores.count; i = i+1 {
            if scores[i].2 > maxScore {
                maxScore = scores[i].2
            }
        }
        if maxScore >= players.count * 10 + 5 {
            print("Game Over")
        }else{
            let pID: String = (FIRAuth.auth()?.currentUser?.uid)!
            self.ref.child("RunningGame/"+self.gameID+"/Players").child(pID).child("dead").setValue(false)
            lineContainer.removeAllChildren()
            lineCanvas = SKSpriteNode(color:SKColor.clearColor(),size:view!.frame.size)
            lineCanvas!.anchorPoint = CGPointZero
            lineCanvas!.position = CGPointZero
            lineContainer.addChild(lineCanvas!)
            texture = SKTexture()
            addLinesToTexture()
            randomStartingPosition()
            for var i = 0; i < itemList.count; i = i+1{
                itemList[i].removeFromParent()
            }
            itemList.removeAll()
            for var i = 0; i < bombList.count; i = i+1{
                bombList[i].removeFromParent()
            }
            bombList.removeAll()
            waitForRunning()
            
            dead = false
            scoreView.hidden = true
        }
    }
    
    // load all Game Attributes
    func loadPlayers(){
        let pID: String = (FIRAuth.auth()?.currentUser?.uid)!
        self.players = GameData.game.playerObject.filter {($0.playerID != pID)}
        
        maxScoreLabel.text = String(players.count * 10 + 5)
        for var i = 0; i < GameData.game.playerObject.count; i=i+1 {
            let color: UIColor = self.hexStringToUIColor(GameData.game.playerObject[i].color)
            if GameData.game.playerObject[i].playerID != pID {
//                self.colors.append(color)
            }else{
                self.p1.fillColor = color
                self.p1.strokeColor = color
                self.leftBtn.fillColor = color
                self.rightBtn.fillColor = color
            }
        }
        
        // create own entries in Firebase
        let pName: String = (FIRAuth.auth()?.currentUser?.displayName)!
        self.ref.child("RunningGame/"+self.gameID).child("Items").setValue(["category": 0, "posX": 0, "posY": 0])
        self.ref.child("RunningGame/"+self.gameID).child("Score").child(pID).setValue(["pID": pID, "name": pName, "score": 0])
        // set own Player settings
//        if self.gameID == pID {
        self.ref.child("RunningGame/"+self.gameID+"/Players").child(pID).setValue(["pID": pID, "PositionX": self.p1.position.x,"PositionY": self.p1.position.y,"lineWidth":self.p1Size, "dead": false])
//        }
        
        // load GameItems if not player is not Host
        if self.gameID != pID {
            self.ref.child("RunningGame/"+self.gameID).child("Items").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                // Get Items
                let postArr2 = snap.value as! NSDictionary
                let pos = CGPoint(x: postArr2.valueForKey("posX") as! CGFloat, y: postArr2.objectForKey("posY") as! CGFloat)
                let nameRandom = postArr2.objectForKey("category") as! Int
                self.makeItems(pos, nameRandom: UInt32(nameRandom))
            }
        }
        
        
        // load attributes from opponent players
        for var i = 0; i < self.players.count; i=i+1{
            var line = LineObject(point: SKShapeNode(circleOfRadius: 2.0),position: CGPoint(), path: CGPathCreateMutable(), lineNode: SKShapeNode(), wayPoints: [], dead: false)
            self.curves.append(line)
            self.addChild(line.point)
            
        }
        var i = -1
        while i + 1 < self.players.count{
            i = i + 1
//            print(players[i].playerID)
            self.ref.child("RunningGame/"+self.gameID).child("Players").child(self.players[i].playerID).observeEventType(.Value) { (snap: FIRDataSnapshot) in
                // Get user value
                if !(snap.value is NSNull) {
                    let postArr3 = snap.value as! NSDictionary
                    let point = CGPoint(x: postArr3.objectForKey("PositionX") as! CGFloat, y: postArr3.objectForKey("PositionY") as! CGFloat)
                    self.curves[i].dead = postArr3.objectForKey("dead") as! Bool
                    self.curves[i].position = point
                    self.curves[i].point.fillColor = self.hexStringToUIColor(self.players[i].color)
                    self.curves[i].point.strokeColor = self.hexStringToUIColor(self.players[i].color)
                    self.drawLine2(i)
                    
                    self.checkAllDead()
                }
            }
        }
        
        // load score for tableview
        self.ref.child("RunningGame/"+self.gameID).child("Score").observeEventType(.Value) { (snap: FIRDataSnapshot) in
            self.scores = [(String, String, Int)]()
            let postArr4 = snap.value as! NSDictionary
            for var i = 0; i < postArr4.allValues.count; i=i+1 {
                self.scores.append((postArr4.allValues[i].objectForKey("pID") as! String, postArr4.allValues[i].objectForKey("name") as! String, postArr4.allValues[i].objectForKey("score") as! Int))
            }
            self.scores.sortInPlace() { $0.2 > $1.2 }
            self.scoreTableView.reloadData()
        }
        
        // load other players
        //            self.ref.child("RunningGame/"+self.gameID).child("Players").observeEventType(.Value) { (snap: FIRDataSnapshot) in
        //                // Get user value
        //                let postArr3 = snap.value as! NSDictionary
        //                print(postArr3.allValues.count)
        //                var pIDused:Int = 0
        //                for var i = 0; i < postArr3.allValues.count; i=i+1 {
        //                    if (postArr3.allValues[i].objectForKey("pID") as! String) != pID {
        ////                        self.p2.position.x = postArr3.allValues[i].objectForKey("PositionX") as! CGFloat
        ////                        self.p2.position.y = postArr3.allValues[i].objectForKey("PositionY") as! CGFloat
        //                        let point = CGPoint(x: postArr3.allValues[i].objectForKey("PositionX") as! CGFloat, y: postArr3.allValues[i].objectForKey("PositionY") as! CGFloat)
        //                        self.curves[i-pIDused].position = point
        ////                        self.p2.position.y = postArr3.allValues[i].objectForKey("lineWidth") as! CGFloat
        //
        //                        self.curves[i-pIDused].point.fillColor = SKColor.redColor()
        //                        self.curves[i-pIDused].point.strokeColor = SKColor.redColor()
        ////                        self.addChild(self.curves[i].point)
        //                        self.drawLine2(i-pIDused)
        //                    }else{
        //                        pIDused = pIDused + 1
        //                    }
        //                }
        //
        //
        ////                self.p2.position.x = snap.value?.objectForKey("PositionX") as! CGFloat
        ////                self.p2.position.y = snap.value?.objectForKey("PositionY") as! CGFloat
        //
        ////                self.drawLine2(self.p2.position)
        ////                self.addLinesToTexture2()
        //
        //            }
        //        })
    }
    
    
    // create own random position
    func randomStartingPosition(){
        let posX = CGFloat(arc4random_uniform(UInt32(view!.frame.width - (4*btnWidth+20) - 100))) + 2 * btnWidth + 10 + 50
        let posY = CGFloat(arc4random_uniform(UInt32(view!.frame.height - (4*btnWidth+20) - 100))) + 5 + 50
        let startingPosition = CGPoint(x: posX, y: posY)
        //        print(startingPosition)
        
        lastPoint = CGPointMake(posX, posY)
        wayPoints.append(startingPosition)
        
        let startingDirection = Double(arc4random_uniform(360))
        curveRadius = startingDirection
        changeDirectionL()
        curveRadius = 5.0
    }
    
    // draw opponents
    func drawLine2(i: Int){
        if (CGPathIsEmpty(curves[i].path)) {
            CGPathMoveToPoint(curves[i].path, nil, curves[i].position.x, curves[i].position.y)
            curves[i].lineNode.path = nil
            curves[i].lineNode.lineWidth = lineThickness
            curves[i].lineNode.strokeColor = self.hexStringToUIColor(players[i].color)
            if running {
                lineContainer.addChild(curves[i].lineNode)
            }
            
        }
        
        var x = curves[i].position.x + xCurve
        var y = curves[i].position.y + yCurve
        
        CGPathAddLineToPoint(curves[i].path, nil, x, y)
        curves[i].lineNode.path = curves[i].path
        curves[i].position = CGPoint(x: x, y: y)
        
        //        pPosition = CGPointMake(x, y)
        curves[i].wayPoints.append(CGPoint(x:x,y:y))
        
        
        self.addLinesToTexture2(i)
        
    }
    
    func addLinesToTexture2 (i: Int) {
        // Convert the contents of the line container to an SKTexture
        texture = self.view!.textureFromNode(lineContainer)!
        lineCanvas!.texture = texture
        curves[i].lineNode.removeFromParent()
        curves[i].path = CGPathCreateMutable()
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
    
    func waitForRunning(){
        running = false
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(GameScene.setRunning), userInfo: nil, repeats: false)
    }
    
    func setRunning(){
        running = true
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
                
//                if !switchDirBool{
                    changeDirectionL()
                    myTimer1 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionL), userInfo: nil, repeats: true)
//                }else{
//                    changeDirectionR()
//                    
//                    myTimer2 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionR), userInfo: nil, repeats: true)
//                }
                
                
            }
            else if rightBtn.containsPoint(location){
                
//                if !switchDirBool{
                    changeDirectionR()
                    
                    myTimer2 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionR), userInfo: nil, repeats: true)
//                }else{
//                    changeDirectionL()
//                    myTimer1 = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameScene.changeDirectionL), userInfo: nil, repeats: true)
//                }
                
            }
        }
        
    }
    
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        myTimer1.invalidate()
        myTimer2.invalidate()
    }
    
    //Linkskurve
    func changeDirectionL(){
        let alt = pointToRadian(wayPoints[0])
        if switchDirBool {
            wayPoints[0] = radianToPoint(alt-curveRadius)
        }else{
            wayPoints[0] = radianToPoint(alt+curveRadius)
        }
        changeDirection(wayPoints[0])
    }
    
    //Rechtskurve
    func changeDirectionR(){
        let alt = pointToRadian(wayPoints[0])
        if switchDirBool {
            wayPoints[0] = radianToPoint(alt+curveRadius)
        }else{
            wayPoints[0] = radianToPoint(alt-curveRadius)
        }
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
                if running {
                    lineContainer.addChild(lineNode)
                }
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
            self.ref.child("RunningGame/"+self.gameID+"/Players").child(pID).updateChildValues(["pID": pID, "PositionX": self.p1.position.x,"PositionY": self.p1.position.y])
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
//        print(curves.contains({ obj -> Bool in obj.dead == false }))
        if gameID == pID && (!dead || curves.contains({ obj -> Bool in obj.dead == false })) {
            
            let rand = arc4random() % 500
            if rand == 10{
                //wenn es mehr Items gibt, zahl erhöhen
                let nameRandom = 1 + arc4random() % 4
                
                let pos = makeRandomPos()
                pushItem(nameRandom, posX: pos.x, posY: pos.y)
                makeItems(pos, nameRandom: nameRandom)
            }
        }
        if !dead {
            drawLine()
            if running{
                addLinesToTexture()
            }
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
        let pID: String = (FIRAuth.auth()?.currentUser?.uid)!
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
//                    curves[ownCurveIndex].dead = true
                    self.ref.child("RunningGame/"+self.gameID+"/Players").child(pID).child("dead").setValue(true)
                    dead = true
                    let currentScore = scores.filter { triple -> Bool in triple.0 == pID }[0].2
                    self.ref.child("RunningGame/"+self.gameID+"/Score").child(pID).child("score").setValue(currentScore + (curves.filter { obj -> Bool in obj.dead == true }.count))
                    checkAllDead()
                }
            }
            
            
        }else{
            print("dead")
            self.ref.child("RunningGame/"+self.gameID+"/Players").child(pID).child("dead").setValue(true)
//            curves[ownCurveIndex].dead = true
            dead = true
            let currentScore = scores.filter { triple -> Bool in triple.0 == pID }[0].2
            self.ref.child("RunningGame/"+self.gameID+"/Score").child(pID).child("score").setValue(currentScore + (curves.filter { obj -> Bool in obj.dead == true }.count))
            //      p1.physicsBody?.dynamic = false
            checkAllDead()
        }
    }
    
    func checkAllDead(){
        
        if (self.dead && (!self.curves.contains({ obj -> Bool in obj.dead == false }) || self.curves.count == 0)) {
//            print("All dead")
            self.scoreTableView.reloadData()
            self.scoreView.hidden = false
            NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(GameScene.newRound), userInfo: nil, repeats: false)
            
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
        curveSpeed = curveSpeed * 2
        gapLength = gapLength / 2
//        xCurve = xCurve * 2
//        yCurve = yCurve * 2
        curveRadius = curveRadius * (3 / 2)
        _ = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(GameScene.lowerSpeed), userInfo: nil, repeats: false)
    }
    
    func lowerSpeed(){
        curveSpeed = curveSpeed / 2
        gapLength = gapLength * 2
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
    
    
    //***********************************************************************************
    //***********************************************************************************
    //                                  Score Table View Start
    //***********************************************************************************
    //***********************************************************************************
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
//        print(scores[indexPath.row])
        let player = players.filter {($0.playerID == scores[indexPath.row].0)}
        if player.count == 0{
            cell.textLabel?.textColor = p1.fillColor
        }else{
            cell.textLabel?.textColor = hexStringToUIColor(player[0].color)
        }
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(25)
        cell.textLabel?.text = scores[indexPath.row].1
        cell.detailTextLabel?.text = String(scores[indexPath.row].2)
        return cell
    }
    
    
    
    //***********************************************************************************
    //***********************************************************************************
    //                                  Score Table View End
    //***********************************************************************************
    //***********************************************************************************
}



