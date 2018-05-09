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
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
    
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) {
            (user, error) in
            
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                self.errorLabel.text = "There was a problem with your login. Try again!"
                
                RegistrationViewController().updateErrorLabel(self.errorLabel, false)
            }else{
                print("Login Successful!")
                SVProgressHUD.dismiss()
                
                if let userID = user?.uid {
                    
                    //Finds the current user in the RealTime Database in Firebase and
                    //obtains the users' values for displaying in the app
                    self.ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let userObject = snapshot.value as? NSDictionary
                        
                        let userType = userObject?["User_Type"] as? String ?? ""
                        let firstLogin = userObject?["First_Login"] as? Bool 
                        
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
                
            }
            
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func newUnwind(segue: UIStoryboardSegue){
        if let sourceVC = segue.source as? ConfigurationTableViewController{
            self.errorLabel.text = "Configuration Complete!"
            self.errorLabel.textColor = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
            RegistrationViewController().updateErrorLabel(self.errorLabel, false)
        }
    }
    
    @IBAction func unwindToLoginFromInsights(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? InsightSettingsViewController{
            self.errorLabel.text = "Your settings were updated! Please log in."
            self.errorLabel.textColor = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
            RegistrationViewController().updateErrorLabel(self.errorLabel, false)
        }
    }
    
}
