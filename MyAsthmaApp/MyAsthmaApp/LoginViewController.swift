//
//  LoginViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/8/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        errorLabel.isHidden = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeBackground(_ sender: Any) {
         view.backgroundColor = UIColor.blue
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) {
            (user, error) in
            
            
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                self.errorLabel.text = "There was problem with your login. Pleasy try again."
                
                RegistrationViewController().updateErrorLabel(self.errorLabel, false)
            }else{
                print("Login Successful!")
                SVProgressHUD.dismiss()
                
                print("JA")
                print(user?.uid)
        
                
                if let userID = user?.uid {
                    
                    //Finds the current user in the RealTime Database in Firebase and
                    //obtains the users' values for displaying in the app
                    self.ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let userObject = snapshot.value as? NSDictionary
                        
                        let userType = userObject?["User_Type"] as? String ?? ""
                        let firstLogin = userObject?["First_Login"] as? Bool 
                        
                        print("DA")
                        print(userType)
                        
                        if userType == "Doctor"{
                            if firstLogin == true{
                                self.performSegue(withIdentifier: "goToGMCSetup", sender: self)
                            }else{
                                self.performSegue(withIdentifier: "goToDoctorMain", sender: self)
                            }
                        }else{
                            self.performSegue(withIdentifier: "goToRoot", sender: self)
                        }
                        
                    }) { (error) in
                        print(error.localizedDescription)
                        
                    }
                    
                }
                
//                self.performSegue(withIdentifier: "goToRoot", sender: self)
            }
            
        
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
    }
    

}
