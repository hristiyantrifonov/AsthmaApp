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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                self.errorLabel.text = "There was problem with your login. Pleasy try again."
                
                RegistrationViewController().updateErrorLabel(self.errorLabel, false)
            }else{
                print("Login Successful!")
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "goToRoot", sender: self)
            }
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
