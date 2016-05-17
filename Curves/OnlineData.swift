//
//  OnlineData.swift
//  Curves
//
//  Created by Sebastian Haußmann on 13.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import Foundation

class OnlineData: NSObject, NSURLSessionDelegate {
//    let urlString: String = "http://192.168.178.21:80/"
    let urlString: String = "http://134.60.166.126:80/"
    
    var data : NSMutableData = NSMutableData()
    var findPlayersVC = FindPlayersViewController()
    var newAccountVC = NewAccountViewController()
    var loginVC = LoginViewController()
    var newGameVC = NewGameViewController()
    
    func register(email: String, name: String, password: String){
        var url: NSURL = NSURL(string: urlString + "register.php")!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        var bodyData = "email=" + email
        bodyData += "&name=" + name
        bodyData += "&password=" + password
        request.HTTPMethod = "POST"
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
        {
            (response, data, error) in
            
            
            if let HTTPResponse = response as? NSHTTPURLResponse {
                let statusCode = HTTPResponse.statusCode
                
                if statusCode == 200 {
                    print("registered")
                    
                }
                else{
                    //                        print(response)
                }
            }
            
        }
    }
    
    func loadUserList(viewController: NewAccountViewController){
        newAccountVC = viewController
        newAccountVC.userList = [AccountModel]()
        
        let url: NSURL = NSURL(string: urlString + "service.php")!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
    }
    
    func loadUserListLogin(viewController: LoginViewController){
        loginVC = viewController
        loginVC.downloadedList = [AccountModel]()
        
        let url: NSURL = NSURL(string: urlString + "service.php")!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
    }

    func loadGames(viewController: FindPlayersViewController){
        findPlayersVC = viewController
        findPlayersVC.gameList = [Game]()
        data = NSMutableData()
        let url: NSURL = NSURL(string: urlString + "loadGames.php")!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
    }
    
    func joinGame(viewController: FindPlayersViewController, newGameObject: Game, ownUserName: String){
        findPlayersVC = viewController
        let urlCreateGame: String = urlString + "joinGame.php"
        let url: NSURL = NSURL(string: urlCreateGame)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        var bodyData = "id=" + String(newGameObject.id)
        bodyData += "&players=" + newGameObject.players + "," + ownUserName
        request.HTTPMethod = "POST"
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            self.findPlayersVC.tableView.reloadData()
        })
    }
    func closeGame(viewController: NewGameViewController, gameId: Int){
        newGameVC = viewController
        let urlCreateGame: String = urlString + "closeGame.php"
        let url: NSURL = NSURL(string: urlCreateGame)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        let bodyData = "id=" + String(gameId)
        request.HTTPMethod = "POST"
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            self.newGameVC.tableView.reloadData()
        })
    }
    
    func leaveGame(viewController: NewGameViewController, gameId: Int, players: String){
        newGameVC = viewController
        let urlCreateGame: String = urlString + "leaveGame.php"
        let url: NSURL = NSURL(string: urlCreateGame)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        var bodyData = "id=" + String(gameId)
        bodyData += "&players=" + players
        request.HTTPMethod = "POST"
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            self.newGameVC.tableView.reloadData()
        })
    }
    
    func createGame(viewController: FindPlayersViewController, newGameObject: Game){
        findPlayersVC = viewController
        let urlCreateGame: String = urlString + "createGame.php"
        let url: NSURL = NSURL(string: urlCreateGame)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        var bodyData = "id=" + String(newGameObject.id)
        bodyData += "&gamename=" + newGameObject.name
        bodyData += "&players=" + newGameObject.players
        request.HTTPMethod = "POST"
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            self.findPlayersVC.tableView.reloadData()
        })
    }
    
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.data.appendData(data);
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("Failed to download data")
        }else {
//            print("Data downloaded")
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
                if String(jsonElement.allKeys) == "[id, name, players]" {
                    if let id = Int((jsonElement["id"] as? String)!),
                        let name = jsonElement["name"] as? String,
                        let players = jsonElement["players"] as? String
                        
                    {
                        let game = Game(id: id, name: name, players: players)
                        findPlayersVC.gameList.append(game)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.findPlayersVC.tableView.reloadData()
                        })
                    }
                }else if String(jsonElement.allKeys) == "[email, name, password]" {
                    if let email = jsonElement["email"] as? String,
                        let name = jsonElement["name"] as? String,
                        let password = jsonElement["password"] as? String
                    {
                        let users = AccountModel()
                    
//                        print(email,name,password)
                        users.email = email
                        users.name = name
                        users.password = password
                        newAccountVC.userList.append(users)
                        //loginVC.downloadedList.append(users)
                    }
                }                
            }
        }
        
    }
}