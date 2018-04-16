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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findPatients() {
        ref.child("doctors_patients").queryOrderedByKey().observeSingleEvent(of: .value) {
            (snapshot) in
            
            print(snapshot.value)
        }
    }
    
    @IBAction func viewPatientsClicked(_ sender: Any) {
        findPatients()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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