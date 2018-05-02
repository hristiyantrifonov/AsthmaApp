//
//  PopUpDoctorCredentialsViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/2/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase

class PopUpDoctorCredentialsViewController: UIViewController {
    
    
    @IBOutlet weak var forenameTextField: UITextField!
    @IBOutlet weak var  surnameTextField: UITextField!
    @IBOutlet weak var GMCNumberTextFIeld: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var authoriseButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var ref: DatabaseReference!
    let patientID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        authoriseButton.backgroundColor = .clear
        authoriseButton.layer.cornerRadius = 7
        authoriseButton.layer.borderWidth = 1
        authoriseButton.layer.borderColor = UIColor.black.cgColor
        closeButton.backgroundColor = .clear
        closeButton.layer.cornerRadius = 7
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.black.cgColor
        
        ref = Database.database().reference()
        showAnimate()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logOnClicked(_ sender: Any) {
        
        print("Initial")
        print(Auth.auth().currentUser?.uid)


        ref.child("users").queryOrdered(byChild: "GMC_Reference_Number").queryEqual(toValue: "\(GMCNumberTextFIeld.text!)").observeSingleEvent(of: .value, with: { (snapshot) in

            //The list of doctors mathching the input details
            let resultObject = snapshot.value as? NSDictionary

            if let doctorUid = resultObject?.allKeys[0]{

                let userObject = resultObject?[doctorUid] as? NSDictionary

                let forename = userObject?["Forename"] as? String ?? ""
                let surname = userObject?["Surname"] as? String ?? ""
                let userType = userObject?["User_Type"] as? String ?? ""

                if forename == self.forenameTextField.text! && surname == self.surnameTextField.text! && userType == "Doctor"{
                    print(forename)
                    print(surname)
                    print(doctorUid)

                    self.ref.child("doctors_patients").childByAutoId().setValue(["Doctor" : doctorUid,"Patient" : self.patientID])

                    print("Doctor - Patient Relationship Registered")

                    //After registering the relationships allow doctor to configure patient's app
                    self.performSegue(withIdentifier: "goToConfiguration", sender: self)


                }else{
                    print("Wrong fields. Display error code TODO in here")
                }


            }

        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.view.removeFromSuperview()
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        removeAnimate()
    }
    
    
    // MARK: - Animation Functions
    
    //For better user interface we animate the pop-up showing and closing
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
}
