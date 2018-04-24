//
//  RegistrationViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/7/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegistrationViewController: UIViewController {
    
    let PASSWORD_MINIMUM_CHARACTERS : Int = 6
    
    
    @IBOutlet weak var forenameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forenameField.delegate = self
        surnameField.delegate = self
        passwordField.delegate = self
        emailField.delegate = self
        
        registerButton.isEnabled = false
        errorLabel.isHidden = true
        
        //Make this view observer in order to listen for changes
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: Notification.Name.UITextFieldTextDidChange, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Form Validation Methods
    
    /* Validation chekcs for the different fields */
    
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if textField == passwordField{
            return(text.count >= PASSWORD_MINIMUM_CHARACTERS, "The password is too short.")
        }
        
        if textField == emailField{
            return(isValidEmail(text), "The email format is not valid.")
        }
        
        return (text.count > 0, "This field cannot be empty.")
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let test = NSPredicate(format:"SELF MATCHES[c] %@", emailRegex)
        return test.evaluate(with: email)
    }
    
    
    /* Uses the validate functions and checks all the fields in the form,
     and updates the state of the button based on that */
    
    @objc private func textDidChange(_ notification: Notification) {
        var formIsValid = true
        
        for textField in textFields {
            //Validate the text field
            let (valid, _) = validate(textField)
            
            guard valid else {
                formIsValid = false
                break
            }
        }
        registerButton.isEnabled = formIsValid
    }
    
    
    //MARK: - Form Submission
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        print(forenameField.text!)
        print(surnameField.text!)
        print(passwordField.text!)
        print(emailField.text!)
        
        SVProgressHUD.show()
        
        let reference : DatabaseReference!
        reference = Database.database().reference()
        
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) {
            (user, error) in
            
            if error != nil{
                print(error!)
                SVProgressHUD.dismiss()
            }else{
                
                //Send the additional data (forename, surname) to the server
                //User's type is automatically assigned to be a patient, becoming a doctor is only done manually
                reference.child("users").child(user!.uid).setValue(["Forename": self.forenameField.text!, "Surname": self.surnameField.text!,
                                                                    "Email": self.emailField.text!, "User_Type": "Patient",
                                                                    "Profile_Configured" : false])
                
                reference.child("settings").child(user!.uid).setValue(["First" : (["Main-Setting" : "peak flow", "First-Subsetting1" : "--none--", "Second-Subsetting" : "--none--"]),     "Second" : (["Main-Setting" : "--none--", "First-Subsetting1" : "--none--", "Second-Subsetting" : "--none--"]),
                    "Third" : (["Main-Setting" : "--none--", "First-Subsetting1" : "--none--", "Second-Subsetting" : "--none--"]) ])
                print("Registration Successful!")
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "goToRoot", sender: self)
            }
            
        }
    }
    
}

//MARK: - Text Field Delegate Methods

extension RegistrationViewController: UITextFieldDelegate {
    
    //MARK: - Text Field Convenience and Validation
    
    /*  Everytime the user taps return we switch to the next
     field and validate the input by showing errors on the go */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case forenameField:
            print("Go to surname field")
            surnameField.becomeFirstResponder()
        case surnameField:
            print("Go to password field")
            passwordField.becomeFirstResponder()
        case passwordField:
            
            let (validity, message) = validate(textField)
            if validity{
                emailField.becomeFirstResponder()
            }
            self.errorLabel.text = message
            updateErrorLabel(errorLabel, validity)
            
        default:
            let (validity, message) = validate(textField)
            if validity{
                emailField.resignFirstResponder()
            }
            self.errorLabel.text = message
            updateErrorLabel(errorLabel, validity)
        }
        return true;
    }
    
    //MARK: - Helper Functions
    
    func updateErrorLabel(_ label: UILabel!, _ validity: Bool){
        UIView.animate(withDuration: 0.25, animations: {
            label.isHidden = validity
        })
    }
    
}
