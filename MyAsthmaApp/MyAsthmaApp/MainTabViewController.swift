//
//  MainTabViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/7/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase

class MainTabViewController: UIViewController {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = Auth.auth().currentUser?.uid
        print(userID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //TODO - add Logout button to clear session
    
    //TODO - Display user's name (try using sideway window
    
}
