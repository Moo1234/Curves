//
//  NewAccountViewController.swift
//  Curves
//
//  Created by Moritz Martin on 05.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit

class NewAccountViewController: UIViewController,  NSURLSessionDelegate, UITextFieldDelegate {
    
    var data : NSMutableData = NSMutableData()
    var userList = [AccountModel]()
    
    //vom eigenen pc
    //let urlPath: String = "http://localhost/service.php"
    
    //von fremden geräten
    //    let urlPath: String = "http://134.60.170.88:80/service.php"
    
    let urlPath: String = "http://192.168.178.21:80/service.php"
    let urlRegister: String = "http://192.168.178.21:80/register.php"
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var pwTxtField: UITextField!
    
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
        
        self.emailTxtField.delegate = self
        self.nameTxtField.delegate = self
        self.pwTxtField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func submitButton(sender: AnyObject) {
        if userList.contains({ $0.email == emailTxtField.text}){
            let alert = UIAlertController(title: "fehlerhafte Daten", message: "Die E-Mailadresse ist bereits registriert", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Zurück", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else if userList.contains({ $0.name == nameTxtField.text}){
            let alert = UIAlertController(title: "fehlerhafte Daten", message: "Der Name ist bereits vorgeben", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Zurück", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            
            var url: NSURL = NSURL(string: urlRegister)!
            var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            var bodyData = "email=" + emailTxtField.text!
            bodyData += "&name=" + nameTxtField.text!
            bodyData += "&password=" + pwTxtField.text!
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
                    let alert = UIAlertController(title: "Registrierung erfolgreich", message: "Sie können sich nun einloggen.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
                        self.performSegueWithIdentifier("toLogin", sender:self)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
        }
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
    
    @IBAction func goBack(sender: AnyObject) {
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
