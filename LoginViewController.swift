//
//  LoginViewController.swift
//  Curves
//
//  Created by Moritz Martin on 05.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,  NSURLSessionDelegate {

    var data : NSMutableData = NSMutableData()
    
    //vom eigenen pc
    //let urlPath: String = "http://localhost/service.php"
    
    //von fremden geräten
//    let urlPath: String = "http://134.60.170.88:80/service.php"
    let urlPath: String = "http://192.168.178.21:80/service.php"
    
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var pwTxtField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    
//    var nameTxt: String = String()
//    var pwTxt: String = String()
//    
    
    var userList = [AccountModel]()
    
    
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
    
    
    
    
    
    
    @IBAction func loginButton(sender: AnyObject) {
        
        checkData()
        
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
            if let email = jsonElement["email"] as? String,
                let name = jsonElement["name"] as? String,
                let password = jsonElement["password"] as? String

            {
                let users = AccountModel()

                print(email,name,password)
                users.email = email
                users.name = name
                users.password = password
                userList.append(users)
                
            }
            
        }
        print(userList)
        
    }

    func checkData(){
        if userList.contains({ $0.name == nameTxtField.text && $0.password == pwTxtField.text}){
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("loginSuccessfull", sender: self)
            })
        }else{
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertController(title: "Login fehlgeschlagen", message: "Sie haben ein falsches Passwort oder einen falschen Benutzernamen eingegeben", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Zurück", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
