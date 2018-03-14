//
//  WelcomeViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/8/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class WelcomeViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If the user have logged in previously then immediately enter the system
        if let userID = Auth.auth().currentUser?.uid {
            SVProgressHUD.init()
            
            performSegue(withIdentifier: "goToRoot", sender: self)
            
            SVProgressHUD.dismiss()
        }else{
            print("No current logged user")
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonPressed(_ sender: UIButton) { }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
}
