//
//  AddContactViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/22/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import CareKit
import Firebase

class AddContactViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var relationTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var contactTypeChooser: UISegmentedControl!
    
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        
        let name = nameTextField.text!
        let relation = relationTextField.text!
        let phone = phoneTextField.text!
        let email = emailTextField.text!
        var type = ""
        
        if contactTypeChooser.selectedSegmentIndex == 0 { type = "CareTeam" }
        else { type = "Personal" }
        
        let contactDictionary = ["Name" : name, "Relation" : relation, "Phone" : phone, "Email" : email, "Contact-Type" : type]
        
        
        print(phone)
        print(contactDictionary)
        
        FirebaseManager().addNewContact(patientID: userID!, contactDetails: contactDictionary) {
            (success) in

            if (success != nil){
                
                print("Contact saved")
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }else{
                print("Failed to save contact.")
            }

        }
    }
    
   
    //TODO
    @IBAction func submitAndAddAnotherClicked(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     
     OCKContact(contactType: .careTeam,
     name: "Dr. Maria Ruiz",
     relation: "Physician",
     contactInfoItems: [OCKContactInfo.phone("888-555-5512"), OCKContactInfo.sms("888-555-5512"), OCKContactInfo.email("mruiz2@mac.com")],
     tintColor: UIColor.blue,
     monogram: nil,
     image: nil),
     
     
     OCKContact(contactType: .careTeam,
     name: "Bill James",
     relation: "Nurse",
     contactInfoItems: [OCKContactInfo.phone("888-555-5512"), OCKContactInfo.sms("888-555-5512"), OCKContactInfo.email("billjames2@mac.com")],
     tintColor: UIColor.green,
     monogram: "BJ",
     image: nil),
     
     OCKContact(contactType: .personal,
     name: "Tom Clark",
     relation: "Father",
     contactInfoItems: [OCKContactInfo.phone("888-555-5512"), OCKContactInfo.sms("888-555-5512")],
     tintColor: UIColor.brown,
     monogram: "TC",
     image: nil)
    */

}
