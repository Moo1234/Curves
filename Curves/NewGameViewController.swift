//
//  NewGameViewController.swift
//  Curves
//
//  Created by Sebastian Haußmann on 07.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit

class NewGameViewController: UIViewController, NSURLSessionDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gameNameLabel: UITextField!
    
    var data : NSMutableData = NSMutableData()
    var game = Game()
    
    var ownUserName = ""
    var gameId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reload()
    }
    
    func loadGames(){
        data = NSMutableData()
        
        let urlPath: String = "http://134.60.166.126:80/loadGames.php"
        UIApplication.sharedApplication().statusBarHidden = false
        self.view.backgroundColor = UIColor.blackColor()
        
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
        // NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(NewGameViewController.reload), userInfo: nil, repeats: true)
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(game.players.characters.count > 0 && game.players.characters.split(",").count == 0){
            return 1
        }
        return game.players.characters.split(",").count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? UITableViewCell
        //        print("Table: " , gameList[indexPath.row].name as String)
        //        if(self.game.name != "" || self.game.name != self.gameNameLabel.text){
        //            self.gameNameLabel.text = self.game.name
        //        }
        let player = game.players.characters.split(",").map(String.init)[indexPath.row]
        cell!.textLabel!.text = player
        return cell!
    }
    
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.data.appendData(data);
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("Failed to download data")
        }else {
            print("Data downloaded")
            self.parseJSON()
        }
        
    }
    
    func parseJSON() {
        
        var jsonResult: NSMutableArray = NSMutableArray()
        
        if self.data.length != 2{
            do{
                jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
                
            } catch let error as NSError {
                print(error)
                
            }
            
            var jsonElement: NSDictionary = NSDictionary()
            for(var i = 0; i < jsonResult.count; i += 1)
            {
                
                jsonElement = jsonResult[i] as! NSDictionary
                
                //the following insures none of the JsonElement values are nil through optional binding
                if let id = Int((jsonElement["id"] as? String)!),
                    let name = jsonElement["name"] as? String,
                    let players = jsonElement["players"] as? String
                    
                {
                    if(gameId == id){
                        game = Game(id: id, name: name, players: players)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                        if(self.game.name != "" || self.game.name != self.gameNameLabel.text){
                            self.gameNameLabel.text = self.game.name
                        }
                    })
                    
                }
                
            }
        }
        
    }
    
    @IBAction func leaveGame(sender: AnyObject) {
        if game.players.characters.split(",").count == 1 {
            OnlineData().closeGame(self, gameId: gameId)
        }else{
            let playernames = game.players.characters.split(",").map(String.init)
            var players = ""
            for(var i = 0; i < playernames.count; i += 1){
                if(playernames[i] != ownUserName){
                    if(players != ""){
                        players += ","
                    }
                    players += playernames[i]
                }
            }
            OnlineData().leaveGame(self, gameId: gameId, players: players)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reload(){
        loadGames()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            if(self.game.name != "" || self.game.name != self.gameNameLabel.text){
                self.gameNameLabel.text = self.game.name
            }
        })
    }
    
    @IBAction func reloadData(sender: AnyObject) {
        reload()
    }
    
}