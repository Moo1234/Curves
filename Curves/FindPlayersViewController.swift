//
//  FindPlayersViewController.swift
//  Curves
//
//  Created by Moritz Martin on 06.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit
import Firebase

class FindPlayersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data : NSMutableData = NSMutableData()
    var gameList = [Game]()
    var gameID = 0
    var ownUserName = ""
    var playerInGameID = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.view.backgroundColor = UIColor.blackColor()
        
//        OnlineData().loadGames(self)
        
        loadGames()
        
      //  getUser()
        
       // NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(FindPlayersViewController.reloadData(_:)), userInfo: nil, repeats: true)
        //loadGames()
        
        // Do any additional setup after loading the view.
    }
    
    
    func getUser(){
        if let user = FIRAuth.auth()?.currentUser {
            let name = user.displayName
            let email = user.email
            let uid = user.uid;  // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with
            // your backend server, if you have one. Use
            // getTokenWithCompletion:completion: instead.
            print("User: " , user , " " , name, " " , email, " " , uid)
        } else {
            // No user is signed in.
            print("not logged in")
        }
    }
    
    func loadGames(){
        FIRDatabase.database().reference().child("Games").observeEventType(.Value) { (snap: FIRDataSnapshot) in
            // Get Game values
            self.gameList = [Game]()
            if snap.value is NSNull {
                print("No Games yet")
            }else{
                let postArr = snap.value as! NSArray
                for var i = 0; i < postArr.count; i=i+1 {
                    if !(postArr[i] is NSNull){
                        let game = Game()
                        game.id = postArr[i].valueForKey("id") as! Int
                        game.name = postArr[i].valueForKey("name") as! String
                        self.gameList.append(game)
                    }
                }
            }
        
            self.tableView.reloadData()
        }
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
        if(indexPath.row < gameList.count){
            let gamename = gameList[indexPath.row].name
            cell!.textLabel!.text = gamename
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cellName = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text
//        newGameObject = gameList[gameList.indexOf({ $0.name == cellName})!]
//        OnlineData().joinGame(self, newGameObject: newGameObject, ownUserName: ownUserName)
//        tableView.userInteractionEnabled = false
        
        // Join Game
        var freeID = 0
        var playerInGamesIDs = [Int]()
        FIRDatabase.database().reference().child("PlayersInGames").observeSingleEventOfType(.Value) { (snap: FIRDataSnapshot) in
            // Get free ID
            let postArr = snap.value as! NSArray
            for var i = 0; i < postArr.count; i=i+1 {
                if !(postArr[i] is NSNull){
                    playerInGamesIDs.append(postArr[i].valueForKey("id") as! Int)
                }
            }
            for var i=0; i < playerInGamesIDs.count+1; i=i+1 {
                if !playerInGamesIDs.contains(i) {
                    freeID = i
                    break
                }
            }
            let pID: String = (FIRAuth.auth()?.currentUser?.uid)!
            FIRDatabase.database().reference().child("PlayersInGames/"+String(freeID)).setValue(["id": freeID, "gID": self.gameList[indexPath.row].id, "pID": pID, "ready": false, "color": ""])
            self.playerInGameID = freeID
            
            
            self.gameID = self.gameList[indexPath.row].id
            self.performSegueWithIdentifier("newGame", sender:self)
        }
        
    }
    
    @IBAction func createGame(sender: AnyObject) {
        let alert = UIAlertController(title: "Spiel erstellen", message: "Bitte geben Sie einen Namen ein.", preferredStyle: UIAlertControllerStyle.Alert)
        var inputTextField: UITextField?
        inputTextField?.delegate = self
        alert.addTextFieldWithConfigurationHandler { textField -> Void in
            inputTextField = textField
        }
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
//            self.newGameObject = Game(id: id, name: (inputTextField?.text)!, players: self.ownUserName)
//            OnlineData().createGame(self, newGameObject: self.newGameObject)
//            self.performSegueWithIdentifier("newGame", sender:self)
            self.gameID = self.findFreeGameId()
            FIRDatabase.database().reference().child("Games/"+String(self.gameID)).setValue(["id": self.gameID, "name": (inputTextField?.text)!])
            var freeID = 0
            var playerInGamesIDs = [Int]()
            FIRDatabase.database().reference().child("PlayersInGames").observeSingleEventOfType(.Value) { (snap: FIRDataSnapshot) in
                // Get free ID
                if !(snap.value is NSNull){
                    let postArr = snap.value as! NSArray
                    for var i = 0; i < postArr.count; i=i+1 {
                        if !(postArr[i] is NSNull){
                            playerInGamesIDs.append(postArr[i].valueForKey("id") as! Int)
                        }
                    }
                    for var i=0; i < playerInGamesIDs.count+1; i=i+1 {
                        if !playerInGamesIDs.contains(i) {
                            freeID = i
                            break
                        }
                    }
                }
                let pID: String = (FIRAuth.auth()?.currentUser?.uid)!
                FIRDatabase.database().reference().child("PlayersInGames/"+String(freeID)).setValue(["id": freeID, "gID": self.gameID, "pID": pID, "ready": false, "color": "#d3d3d3"])
                self.playerInGameID = freeID
                self.performSegueWithIdentifier("newGame", sender:self)
            }
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
//            print(gameID)
            newGame.gameId = gameID
            newGame.playerInGameID = self.playerInGameID
            
        }
    }
    @IBAction func reloadData(sender: AnyObject) {
        OnlineData().loadGames(self)
    }

    @IBAction func logout(sender: AnyObject) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
//            performSegueWithIdentifier(Constants.Segues.FpToSignIn, sender: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
        
    }
    
    func findFreeGameId() -> Int{
        var id = 0
        for (var i=0; i < gameList.count+1; i+=1) {
            if gameList.contains({ $0.id == i }){
                continue
            }else{
                id = i
                break
            }
        }
        return id
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
