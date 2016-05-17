//
//  FindPlayersViewController.swift
//  Curves
//
//  Created by Moritz Martin on 06.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit

class FindPlayersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data : NSMutableData = NSMutableData()
    var gameList = [Game]()
    var ownUserName = ""
    var newGameObject = Game()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.view.backgroundColor = UIColor.blackColor()
        
        OnlineData().loadGames(self)
        
       // NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(FindPlayersViewController.reloadData(_:)), userInfo: nil, repeats: true)
        //loadGames()
        
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
        if(indexPath.row < gameList.count){
            let gamename = gameList[indexPath.row].name
            cell!.textLabel!.text = gamename
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellName = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text
        newGameObject = gameList[gameList.indexOf({ $0.name == cellName})!]
        OnlineData().joinGame(self, newGameObject: newGameObject, ownUserName: ownUserName)
        self.performSegueWithIdentifier("newGame", sender:self)
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
            OnlineData().createGame(self, newGameObject: self.newGameObject)
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
        OnlineData().loadGames(self)
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
