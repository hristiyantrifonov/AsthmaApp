//
//  GMCNumberSubmissionViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/12/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase

class GMCNumberSubmissionViewController: UIViewController {

    @IBOutlet weak var gmcNumberTextField: UITextField!
    
    var ref: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func submitButtonClicked(_ sender: Any) {
        print("Submission")
        
        let GMCNumber = gmcNumberTextField.text!
        
        if let userID = userID {
            
            //Get the user
            ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let userObject = snapshot.value as? NSDictionary
                
                //We set the GMC Number and we change the value of the initial login so that we do not
                //get this page for GMC Number setup again
                userObject?.setValue(GMCNumber, forKey: "GMC_Reference_Number")
                userObject?.setValue(false, forKey: "First_Login")
                
                //Perform the change and save to the real-time database
                self.ref.child("users").child(userID).setValue(userObject)
                
                self.performSegue(withIdentifier: "goToDoctorMain", sender: self)
                
            }) { (error) in
                print(error.localizedDescription)
                
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
