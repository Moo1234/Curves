//
//  NewGameViewController.swift
//  Curves
//
//  Created by Sebastian Haußmann on 07.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit
import Firebase

class NewGameViewController: UIViewController, NSURLSessionDelegate, UITableViewDataSource{
    
    @IBOutlet weak var readyForGame: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gameNameLabel: UITextField!
    
    
    
    var game = Game()
    
    var gameId = 0
    var playerInGameID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGame()
        
        let tblView =  UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView!.hidden = true
        tableView.backgroundColor = UIColor.clearColor()
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.view.backgroundColor = UIColor.blackColor()
        
        changeColor()
        
//        reload()
    }
    

    func loadGame(){
        FIRDatabase.database().reference().child("Games").observeSingleEventOfType(.Value) { (snap: FIRDataSnapshot) in
            // Get Game values
            let postArr = snap.value as! NSArray
            for var i = 0; i < postArr.count; i=i+1 {
                if !(postArr[i] is NSNull) && postArr[i].valueForKey("id") as! Int == self.gameId{
                    self.game.id = postArr[i].valueForKey("id") as! Int
                    self.game.name = postArr[i].valueForKey("name") as! String
                }
            }
            self.gameNameLabel.text = self.game.name
        }
        
        FIRDatabase.database().reference().child("PlayersInGames").observeEventType(.Value) { (snap: FIRDataSnapshot) in
            self.game.playerIDs = [String]()
            self.game.playerInGamesIDs = [Int]()
            self.game.readyPlayers = [Bool]()
            self.game.colors = [String]()
            // Get Game values
//            print(snap.value)
            let postArr = snap.value as! NSArray
//            print(postArr.allValues[0].objectForKey("gID") as! Int == self.gameId)
            for var i = 0; i < postArr.count; i=i+1 {
//                print(postArr[i], " " , self.gameId)
                if !(postArr[i] is NSNull) && postArr[i].valueForKey("gID") as! Int == self.gameId{
                    self.game.playerIDs.append(postArr[i].valueForKey("pID") as! String)
                    self.game.playerInGamesIDs.append(postArr[i].valueForKey("id") as! Int)
                    self.game.readyPlayers.append(postArr[i].valueForKey("ready") as! Bool)
                    self.game.colors.append((postArr[i].valueForKey("color") as! String))
                    
                }
            }
            
            //print(self.playerIDs)
            FIRDatabase.database().reference().child("Players").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                // Get Game values
                self.game.players = [String]()
                let postArr = snap.value as! NSArray
                for var i = 0; i < postArr.count; i=i+1 {
                    if !(postArr[i] is NSNull) && self.game.playerIDs.contains(postArr[i].valueForKey("pID") as! String){
                        self.game.players.append(postArr[i].valueForKey("name") as! String)
                        self.game.scores.append(postArr[i].valueForKey("score") as! Int)
                    }
                }
                if !self.game.readyPlayers.contains(false) && self.game.playerIDs.count > 0{
//                    let playerID: String = (FIRAuth.auth()?.currentUser?.uid)!
//                    let idInGame = String(self.playerIDs.indexOf(playerID)!)
                //FIRDatabase.database().reference().child("RunningGame/"+self.playerIDs.first!).child(idInGame).setValue(["positionX": 200, "positionY": 200, "lineWidth": 2])
                    
                    self.performSegueWithIdentifier("startGame", sender:self)
                }
                self.tableView.reloadData()
            }
        }
    }
    
//    func loadGames(){
//        data = NSMutableData()
//        
//        let urlPath: String = OnlineData().urlString + "loadGames.php"
//        UIApplication.sharedApplication().statusBarHidden = false
//        self.view.backgroundColor = UIColor.blackColor()
//        
//        let url: NSURL = NSURL(string: urlPath)!
//        var session: NSURLSession!
//        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
//        
//        
//        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
//        
//        let task = session.dataTaskWithURL(url)
//        
//        task.resume()
//        // NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(NewGameViewController.reload), userInfo: nil, repeats: true)
//    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//print(players)
        return game.players.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! NewGameTableViewCell
        //        print("Table: " , gameList[indexPath.row].name as String)
        //        if(self.game.name != "" || self.game.name != self.gameNameLabel.text){
        //            self.gameNameLabel.text = self.game.name
        //        }
//        let player = game.players.characters.split(",").map(String.init)[indexPath.row]
//        cell.nameTextField.textColor = UIColor.blackColor()
//        cell.nameTextField.backgroundColor = UIColor.clearColor()
//        cell.scoreTextField.textColor = UIColor.blackColor()
//        cell.scoreTextField.backgroundColor = UIColor.clearColor()
//        
//        cell.backgroundColor = UIColor.clearColor()
        cell.nameLabel.text = game.players[indexPath.row]
        cell.scoreLabel.text = String(game.scores[indexPath.row])
        cell.colorButton.backgroundColor = hexStringToUIColor(game.colors[indexPath.row])
        let playerID: String = (FIRAuth.auth()?.currentUser?.uid)!
        if game.playerIDs[indexPath.row] == playerID {
            cell.colorButton.enabled = true
        }else{
            cell.colorButton.enabled =  false
        }
//        print(indexPath.row, " " , readyPlayers.count)
        if game.readyPlayers[indexPath.row]{
            cell.backgroundColor = UIColor.greenColor()
        }else{
            cell.backgroundColor = UIColor.blackColor()
        }
        return cell
    }
    
    
    // change Color of your player
    @IBAction func changeColor(sender: AnyObject) {
        changeColor()
    }
    func changeColor(){
        var randomColors = ["#ffff00","#ff0000", "#0000ff", "#00ff00", "#bf8040", "#9900ff", "#ff33ff", "#ff8000", "#1ac6ff", "#94b8b8"]
        for var i=0; i < game.colors.count; i=i+1 {
            randomColors = randomColors.filter {!$0.containsString(game.colors[i])}
            //            randomColors.filter(game.colors[i])
        }
        let colorInt = arc4random_uniform(UInt32(randomColors.count))
        FIRDatabase.database().reference().child("PlayersInGames").child(String(playerInGameID)).child("color").setValue(randomColors[Int(colorInt)])
    }
    
    
    
    // change hex color to UIColor
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
    
//    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
//        self.data.appendData(data);
//        
//    }
//    
//    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
//        if error != nil {
//            print("Failed to download data")
//        }else {
//            print("Data downloaded")
//            self.parseJSON()
//        }
//        
//    }
//    
//    func parseJSON() {
//        
//        var jsonResult: NSMutableArray = NSMutableArray()
//        
//        if self.data.length != 2{
//            do{
//                jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
//                
//            } catch let error as NSError {
//                print(error)
//                
//            }
//            
//            var jsonElement: NSDictionary = NSDictionary()
//            for(var i = 0; i < jsonResult.count; i += 1)
//            {
//                
//                jsonElement = jsonResult[i] as! NSDictionary
//                
//                //the following insures none of the JsonElement values are nil through optional binding
//                if let id = Int((jsonElement["gID"] as? String)!),
//                    let name = jsonElement["name"] as? String,
//                    let players = jsonElement["players"] as? String
//                    
//                {
//                    if(gameId == id){
//                        game = Game(id: id, name: name, players: players)
//                    }
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.tableView.reloadData()
//                        if(self.game.name != "" || self.game.name != self.gameNameLabel.text){
//                            self.gameNameLabel.text = self.game.name
//                        }
//                    })
//                    
//                }
//                
//            }
//        }
//        
//    }
    
    @IBAction func leaveGame(sender: AnyObject) {
        FIRDatabase.database().reference().child("PlayersInGames").observeSingleEventOfType(.Value) { (snap: FIRDataSnapshot) in
            let postArr = snap.value as! NSArray
            for var i = 0; i < postArr.count; i=i+1 {
                if !(postArr[i] is NSNull) && postArr[i].valueForKey("gID") as! Int == self.gameId{
                    FIRDatabase.database().reference().child("PlayersInGames/"+String(self.playerInGameID)).removeValueWithCompletionBlock({ (err, ref) in
                        if self.game.playerIDs.count < 1{
                            FIRDatabase.database().reference().child("Games").child(String(self.gameId)).removeValue()
                        }
                    })
                }
            }
        }
//        FIRDatabase.database().reference().child("PlayersInGames").queryEqualToValue(String(gameId), childKey: "gID")
        

        
//        if game.players.characters.split(",").count == 1 {
//            OnlineData().closeGame(self, gameId: gameId)
//        }else{
//            let playernames = game.players.characters.split(",").map(String.init)
//            var players = ""
//            for(var i = 0; i < playernames.count; i += 1){
//                if(playernames[i] != ownUserName){
//                    if(players != ""){
//                        players += ","
//                    }
//                    players += playernames[i]
//                }
//            }
//            OnlineData().leaveGame(self, gameId: gameId, players: players)
//        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func readyForGame(sender: AnyObject) {
        if readyForGame.currentTitle == "Bereit" {
            readyForGame.setTitle("Stop", forState: UIControlState.Normal)
            FIRDatabase.database().reference().child("PlayersInGames/"+String(playerInGameID)+"/ready").setValue(true)
            
        }else{
            readyForGame.setTitle("Bereit", forState: UIControlState.Normal)
            FIRDatabase.database().reference().child("PlayersInGames/"+String(playerInGameID)+"/ready").setValue(false)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "startGame" {
            GameData.id = self.game.playerIDs[0]
            GameData.gID = self.gameId
        }
    }

}