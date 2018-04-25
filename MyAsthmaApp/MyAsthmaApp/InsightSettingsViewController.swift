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
    
    //Picker View Delegate Classes
    let mainInsightPickerDelegate = MainInsightPickerDelegate()
    let firstMedicationPickerDelegate = FirstMedicationInsightPickerDelegate()
    let secondMedicationPickerDelegate = SecondMedicationInsightPickerDelegate()
    
    
    let userID = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainInsightPickerView.delegate = mainInsightPickerDelegate
        mainInsightPickerView.dataSource = mainInsightPickerDelegate
        firstMedicationPickerView.delegate = firstMedicationPickerDelegate
        firstMedicationPickerView.dataSource = firstMedicationPickerDelegate
        secondMedicationPickerView.delegate = secondMedicationPickerDelegate
        secondMedicationPickerView.dataSource = secondMedicationPickerDelegate
        
        // Do any additional setup after loading the view.
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
