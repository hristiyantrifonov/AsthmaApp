//
//  InsightSettingsViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/24/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase
import CareKit

class InsightSettingsViewController: UIViewController {
    
    @IBOutlet weak var mainInsightPickerView: UIPickerView!
    @IBOutlet weak var firstMedicationPickerView: UIPickerView!
    @IBOutlet weak var secondMedicationPickerView: UIPickerView!
    
    @IBOutlet weak var settingChooser: UISegmentedControl!
    @IBOutlet weak var updateButton: UIButton!
    
    //Picker View Delegate Classes
    let mainInsightPickerDelegate = MainInsightPickerDelegate()
    let firstMedicationPickerDelegate = FirstMedicationInsightPickerDelegate()
    let secondMedicationPickerDelegate = SecondMedicationInsightPickerDelegate()
    
    
    let userID = Auth.auth().currentUser?.uid
    var settingsDictionary : [String : [String]] = [:]
    
    var identifiers : [String] = []
    var firstMeds : [String] = []
    var secondMeds : [String] = []
    var thirdMeds : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButton.backgroundColor = .clear
        updateButton.layer.cornerRadius = 7
        updateButton.layer.borderWidth = 1
        updateButton.layer.borderColor = UIColor.black.cgColor
        
        mainInsightPickerView.delegate = mainInsightPickerDelegate
        mainInsightPickerView.dataSource = mainInsightPickerDelegate
        firstMedicationPickerView.delegate = firstMedicationPickerDelegate
        firstMedicationPickerView.dataSource = firstMedicationPickerDelegate
        secondMedicationPickerView.delegate = secondMedicationPickerDelegate
        secondMedicationPickerView.dataSource = secondMedicationPickerDelegate
        
        FirebaseManager().getPatientMainSettings(patientID: userID!) {
            (settingsDict) in
            self.settingsDictionary = (settingsDict as! NSDictionary) as! [String : [String]]
            self.identifiers = self.settingsDictionary["Identifiers"]!
            self.firstMeds = self.settingsDictionary["first-meds"]!
            self.secondMeds = self.settingsDictionary["second-meds"]!
            self.thirdMeds = self.settingsDictionary["third-meds"]!
            
            print(self.settingsDictionary)
            print(self.identifiers)
            print(self.firstMeds)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateSettings(_ sender: Any) {
        let targetSetting = settingChooser.selectedSegmentIndex
        
        let chosenMainInsight = mainInsightPickerDelegate.mainInsightOptions[mainInsightPickerView.selectedRow(inComponent: 0)]
        let chosenFirstMedication = firstMedicationPickerDelegate.firstMedicationOptions[firstMedicationPickerView.selectedRow(inComponent: 0)]
        let chosenSecondMedication = secondMedicationPickerDelegate.secondMedicationOptions[secondMedicationPickerView.selectedRow(inComponent: 0)]
        
        if targetSetting == 0{
            FirebaseManager().updatePatientSettings(patientID: userID!, settingIdentifier: "First",
                                                    newMain: chosenMainInsight, newFirst: chosenFirstMedication, newSecond: chosenSecondMedication, completion: { _ in
                                                        
                                                        do{
                                                            try Auth.auth().signOut()
                                                            print("Logged out")
                                                            
                                                        }catch{
                                                            print("Error signing out")
                                                        }
            })
            
        }else if targetSetting == 1{
            FirebaseManager().updatePatientSettings(patientID: userID!, settingIdentifier: "Second",
                                                    newMain: chosenMainInsight, newFirst: chosenFirstMedication, newSecond: chosenSecondMedication, completion: {_ in
                                                        do{
                                                            try Auth.auth().signOut()
                                                            print("Logged out")
                                                            
                                                        }catch{
                                                            print("Error signing out")
                                                        }
            })
            
        }else {
            FirebaseManager().updatePatientSettings(patientID: userID!, settingIdentifier: "Third",
                                                    newMain: chosenMainInsight, newFirst: chosenFirstMedication, newSecond: chosenSecondMedication, completion: {_ in
                                                        do{
                                                            try Auth.auth().signOut()
                                                            print("Logged out")
                                                            
                                                        }catch{
                                                            print("Error signing out")
                                                        }
            })
        }
        
    }
    
}
