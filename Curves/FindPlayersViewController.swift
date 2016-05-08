//
//  FindPlayersViewController.swift
//  Curves
//
//  Created by Moritz Martin on 06.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit

class FindPlayersViewController: UIViewController, NSURLSessionDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data : NSMutableData = NSMutableData()
    var gameList = [Game]()
    
    //vom eigenen pc
    //let urlPath: String = "http://localhost/service.php"
    
    //von fremden geräten
    //    let urlPath: String = "http://134.60.170.88:80/service.php"
    let urlPath: String = "http://192.168.178.21:80/loadGames.php"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.view.backgroundColor = UIColor.blackColor()
        
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? UITableViewCell
//        print("Table: " , gameList[indexPath.row].name as String)
        var gamename = gameList[indexPath.row].name as? String
        cell!.textLabel!.text = gamename
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
