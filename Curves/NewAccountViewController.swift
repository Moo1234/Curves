//
//  NewAccountViewController.swift
//  Curves
//
//  Created by Moritz Martin on 05.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit
import Firebase

class NewAccountViewController: UIViewController, UITextFieldDelegate {
    
    var userList = [AccountModel]()
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var pwTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // OnlineData().loadUserList(self)
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.view.backgroundColor = UIColor.blackColor()
        
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
//        if userList.contains({ $0.email == emailTxtField.text}){
//            let alert = UIAlertController(title: "fehlerhafte Daten", message: "Die E-Mailadresse ist bereits registriert", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Zurück", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }else if userList.contains({ $0.name == nameTxtField.text}){
//            let alert = UIAlertController(title: "fehlerhafte Daten", message: "Der Name ist bereits vorgeben", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Zurück", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }else{
//            OnlineData().register(self, id: findFreeId(), email: emailTxtField.text!, name: nameTxtField.text!, password: pwTxtField.text!.hash)
//            let alert = UIAlertController(title: "Registrierung erfolgreich", message: "Sie können sich nun einloggen.", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
//                self.dismissViewControllerAnimated(true, completion: nil)
//            }))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
        
        FIRAuth.auth()?.createUserWithEmail(emailTxtField.text!, password: pwTxtField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                let alert = UIAlertController(title: "fehlerhafte Daten", message: "Bitte überprüfen Sie ihre Eingaben", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Zurück", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    func findFreeId() -> Int{
//        var id = 0
//        for (var i=0; i < userList.count+1; i+=1) {
//            if userList.contains({ $0.id == i }){
//                continue
//            }else{
//                id = i
//                break
//            }
//        }
//        return id
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
