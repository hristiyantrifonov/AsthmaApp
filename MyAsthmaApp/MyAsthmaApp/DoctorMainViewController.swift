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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        patientList = []
        // Do any additional setup after loading the view.
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
            
            for record in allPatientRecords!{
                let rec = record.value as! NSDictionary
                
                if (rec["Doctor"] as! String) == self.doctorUID{
                    self.patientList.append(rec["Patient"]!)
                }
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
