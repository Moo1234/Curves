//
//  NewGameViewController.swift
//  Curves
//
//  Created by Sebastian Haußmann on 07.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import UIKit

class NewGameViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    
}