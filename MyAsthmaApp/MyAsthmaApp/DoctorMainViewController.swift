//
//  DoctorMainViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/12/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase

class DoctorMainViewController: UIViewController {
    
    let doctorUID = Auth.auth().currentUser?.uid
    var ref: DatabaseReference!
    var patientList : Array<Any> = []
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var logOutView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gmcNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        patientList = []
        
        self.tabBarItem = UITabBarItem(title: "Main", image: UIImage(named: "main"), selectedImage: UIImage.init(named: "main-filled"))
        
        self.navigationController?.navigationItem.hidesBackButton = true
        self.view.backgroundColor = UIColor.init(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        profileView.layer.borderWidth = 1
        profileView.layer.borderColor = Colors.borderGrey.color.cgColor
        optionsView.layer.borderWidth = 1
        optionsView.layer.borderColor = Colors.borderGrey.color.cgColor
        logOutView.layer.borderWidth = 1
        logOutView.layer.borderColor = Colors.borderGrey.color.cgColor
        
        
        FirebaseManager().getPatientFields(patientID: doctorUID!) {
            (object) in
            let doctorObject = object as! NSDictionary
            
            let doctorForename = doctorObject["Forename"] as! String
            let doctorSurname = doctorObject["Surname"] as! String
            let doctorGMC = doctorObject["GMC_Reference_Number"] as! String
            let doctorEmail = doctorObject["Email"] as! String
            
            self.nameLabel.text = "\(doctorForename) \(doctorSurname)"
            self.gmcNumberLabel.text = doctorGMC
            self.emailLabel.text = doctorEmail
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func viewPatientsClicked(_ sender: Any) {
        
        //Gets all the records from the linker table in the database and then appends the patient ID's to the lst
        //but only the ones that are associated with the logged in doctor
        ref.child("doctors_patients").queryOrderedByKey().observeSingleEvent(of: .value ,with: {
            (snapshot) in
            
            let allPatientRecords = snapshot.value as? NSDictionary
            if ((allPatientRecords?.count) != nil) {
                for record in allPatientRecords!{
                    let rec = record.value as! NSDictionary
                    
                    if (rec["Doctor"] as! String) == self.doctorUID{
                        self.patientList.append(rec["Patient"]!)
                    }
                }
            }else{
                self.patientList.append("No patients.")
            }
            
            
            
            self.performSegue(withIdentifier: "goToPatientRecord", sender: self)
        })
        
        //Clear the list after the segue
        patientList.removeAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goToPatientRecord"){
            let destinationVC = segue.destination as! DoctorsPatientsTableViewController
            destinationVC.patientList = self.patientList
        }
        
        
    }
    
    
    @IBAction func logOutPressed(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            
            print("Logged out")
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            
        }catch{
            print("Could not logout user")
        }
    }
    
}
