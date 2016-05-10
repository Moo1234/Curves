//
//  FindPlayersViewController.swift
//  Curves
//
//  Created by Moritz Martin on 06.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit

class FindPlayersViewController: UIViewController, NSURLSessionDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data : NSMutableData = NSMutableData()
    var gameList = [Game]()
    var ownUserName = ""
    var newGameObject = Game()
    
    //vom eigenen pc
    //let urlPath: String = "http://localhost/service.php"
    
    //von fremden geräten
    //    let urlPath: String = "http://134.60.170.88:80/service.php"
    let urlPath: String = "http://192.168.178.21:80/loadGames.php"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.view.backgroundColor = UIColor.blackColor()
        
        loadGames()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadGames(){
        data = NSMutableData()
        gameList = [Game]()
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? UITableViewCell
//        print("Table: " , gameList[indexPath.row].name as String)
        if(indexPath.row < gameList.count){
            var gamename = gameList[indexPath.row].name as? String
            cell!.textLabel!.text = gamename
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellName = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text
        newGameObject = gameList[gameList.indexOf({ $0.name == cellName})!]
        
        let urlCreateGame: String = "http://192.168.178.21:80/joinGame.php"
        let url: NSURL = NSURL(string: urlCreateGame)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        var bodyData = "id=" + String(self.newGameObject.id)
        print(ownUserName)
        bodyData += "&players=" + self.newGameObject.players + "," + ownUserName
        request.HTTPMethod = "POST"
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            self.tableView.reloadData()
        })
        self.performSegueWithIdentifier("newGame", sender:self)
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
            for(var i = 0; i < jsonResult.count; i++)
            {
                
                jsonElement = jsonResult[i] as! NSDictionary
                
                //the following insures none of the JsonElement values are nil through optional binding
                if let id = Int((jsonElement["id"] as? String)!),
                    let name = jsonElement["name"] as? String,
                    let players = jsonElement["players"] as? String
                    
                {
                    let game = Game(id: id, name: name, players: players)
                    gameList.append(game)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                    
                }
                
            }
        }
        
    }
    
    @IBAction func createGame(sender: AnyObject) {
        var id = 0
        for (var i=0; i < gameList.count+1; i+=1) {
            if gameList.contains({ $0.id == i }){
                continue
            }else{
                id = i
                break
            }
        }
        let alert = UIAlertController(title: "Spiel erstellen", message: "Bitte geben Sie einen Namen ein.", preferredStyle: UIAlertControllerStyle.Alert)
        var inputTextField: UITextField?
        inputTextField?.delegate = self
        alert.addTextFieldWithConfigurationHandler { textField -> Void in
            inputTextField = textField
        }
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
            self.newGameObject = Game(id: id, name: (inputTextField?.text)!, players: self.ownUserName)
            let urlCreateGame: String = "http://192.168.178.21:80/createGame.php"
            let url: NSURL = NSURL(string: urlCreateGame)!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            var bodyData = "id=" + String(self.newGameObject.id)
            bodyData += "&gamename=" + self.newGameObject.name
            bodyData += "&players=" + self.newGameObject.players
            request.HTTPMethod = "POST"
            
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                self.tableView.reloadData()
            })
            self.performSegueWithIdentifier("newGame", sender:self)
        }))
        alert.addAction(UIAlertAction(title: "Zurück", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newGame" {
            let newGame = segue.destinationViewController as! NewGameViewController
            newGame.ownUserName = ownUserName
            newGame.gameId = newGameObject.id
            
        }
    }
    @IBAction func reloadData(sender: AnyObject) {
        loadGames()
        tableView.reloadData()
    }
    @IBAction func logout(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
