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
    
    
    
    var data : NSMutableData = NSMutableData()
    var game = Game()
    var players = [String]()
    var playerInGamesIDs = [Int]()
    var readyPlayers = [Bool]()
    
    var playerID = 0
    var gameId = 0
    var playerInGameID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGame()
        
        let tblView =  UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView!.hidden = true
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorColor = UIColor.clearColor()
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.view.backgroundColor = UIColor.blackColor()
        
        
//        reload()
    }
    

    func loadGame(){
        FIRDatabase.database().reference().child("Games").observeEventType(.Value) { (snap: FIRDataSnapshot) in
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
            var playerIDs = [String]()
            self.playerInGamesIDs = [Int]()
            self.readyPlayers = [Bool]()
            // Get Game values
//            print(snap.value)
            let postArr = snap.value as! NSArray
//            print(postArr.allValues[0].objectForKey("gID") as! Int == self.gameId)
            for var i = 0; i < postArr.count; i=i+1 {
                if !(postArr[i] is NSNull) && postArr[i].valueForKey("gID") as! Int == self.gameId{
                    playerIDs.append(postArr[i].valueForKey("pID") as! String)
                    self.playerInGamesIDs.append(postArr[i].valueForKey("id") as! Int)
                    self.readyPlayers.append(postArr[i].valueForKey("ready") as! Bool)
                }
            }
            
            self.players = [String]()
//            print(playerIDs)
            FIRDatabase.database().reference().child("Players").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                // Get Game values
                let postArr = snap.value as! NSArray
                for var i = 0; i < postArr.count; i=i+1 {
                    if !(postArr[i] is NSNull) && playerIDs.contains(postArr[i].valueForKey("pID") as! String){
                        self.players.append(postArr[i].valueForKey("name") as! String)
                    }
                }
                if !self.readyPlayers.contains(false){
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

        return players.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? UITableViewCell
        //        print("Table: " , gameList[indexPath.row].name as String)
        //        if(self.game.name != "" || self.game.name != self.gameNameLabel.text){
        //            self.gameNameLabel.text = self.game.name
        //        }
//        let player = game.players.characters.split(",").map(String.init)[indexPath.row]
        cell?.textLabel?.textColor = UIColor.blackColor()
        cell?.textLabel?.backgroundColor = UIColor.clearColor()
        cell?.backgroundColor = UIColor.clearColor()
        cell!.textLabel!.text = players[indexPath.row]
        if readyPlayers[indexPath.row]{
            cell?.textLabel?.backgroundColor = UIColor.greenColor()
        }else{
            cell?.textLabel?.backgroundColor = UIColor.whiteColor()
        }
        return cell!
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
                        
                        if self.players.count <= 1{
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
        let playerID: String = (FIRAuth.auth()?.currentUser?.uid)!
        if readyForGame.currentTitle == "Bereit" {
            readyForGame.setTitle("Stop", forState: UIControlState.Normal)
            FIRDatabase.database().reference().child("PlayersInGames/"+String(playerInGameID)).setValue(["id": playerInGameID, "gID": gameId, "pID": playerID, "ready": true])
            
        }else{
            readyForGame.setTitle("Bereit", forState: UIControlState.Normal)
            FIRDatabase.database().reference().child("PlayersInGames/"+String(playerInGameID)).setValue(["id": playerInGameID, "gID": gameId, "pID": playerID, "ready": false])
        }
        
    }
    
    
//    
//    func reload(){
//        loadGames()
//        dispatch_async(dispatch_get_main_queue(), {
//            self.tableView.reloadData()
//            if(self.game.name != "" || self.game.name != self.gameNameLabel.text){
//                self.gameNameLabel.text = self.game.name
//            }
//        })
//    }
    
    @IBAction func reloadData(sender: AnyObject) {
//        reload()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "startGame" {
            print("StartGame")
        }
    }
    
}