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
            FirebaseManager().returnUserField(userID: userID, key: "User_Type", completion: {
                (type) in
               
                if let userType = type as? String {
                    if userType == "Patient"{
                        
                        self.performSegue(withIdentifier: "goToRoot", sender: self)
                        SVProgressHUD.dismiss()
                    }else{
                        print("User is not of type Patient")
                        SVProgressHUD.dismiss()
                    }
                }else{
                    print("Could not find user's type ")
                    SVProgressHUD.dismiss()
                }
            })
        }else{
            print("No current logged user")
            SVProgressHUD.dismiss()
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) { }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindFromDoctorSide(segue: UIStoryboardSegue) {
        
    }
}
