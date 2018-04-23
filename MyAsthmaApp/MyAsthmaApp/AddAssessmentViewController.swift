//
//  AddAssessmentViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/3/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import CareKit
import ResearchKit
import Firebase

class AddAssessmentViewController: UIViewController {
    
    //MARK: - Properties
    
    //The General Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var summaryTextField: UITextField!
    @IBOutlet weak var assessmentTypeChoiceSegmentedControl: UISegmentedControl!
    
    var optionalityChosen = false
    @IBOutlet weak var optionalityButtonPanel: UIView!
    @IBOutlet weak var optionalityButton: UIButton!
    let greenDesignColor = UIColor(red:40/255, green:164/255, blue:40/255, alpha: 1)
    
    
    
    //Scale Assessment Panel & it's Properties
    @IBOutlet weak var scaleAssessmentPanel: UIView!
    @IBOutlet weak var scaleAssessmentDescriptionTextField: UITextField!
    @IBOutlet weak var maxValueTextField: UITextField!
    @IBOutlet weak var minValueTextField: UITextField!
    
    //Quantity Assessment Panle & it's Properties
    @IBOutlet weak var quantityAssessmentPanel: UIView!
    @IBOutlet weak var quantityAssessmentDescriptionTextField: UITextField!
    @IBOutlet weak var categoryTypePickerView: UIPickerView!
    @IBOutlet weak var unitPickerView: UIPickerView!
    
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    @IBOutlet weak var doneButton: UIButton!
    
    //Picker View Delegate Classes
    let categoryPickerDelegate = CategoryTypePickerDelegate()
    let unitPickerDelegate = UnitTypePickerDelegate()
    
    
    //MARK - Firebase Properties
    let userID = Auth.auth().currentUser?.uid
    //Users profile configuration
    var configurationStatus : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Style the Done button
        doneButton?.layer.cornerRadius = 5
        doneButton?.layer.borderWidth = 1.5
        doneButton?.layer.borderColor = UIColor.black.cgColor
        
        scaleAssessmentPanel.isHidden = false
        quantityAssessmentPanel.isHidden = true
        
        //We use two sepaatee classes in order to manage correctly the
        //functionality of the two picker views in this view
        categoryTypePickerView.delegate = categoryPickerDelegate
        categoryTypePickerView.dataSource = categoryPickerDelegate
        unitPickerView.delegate = unitPickerDelegate
        unitPickerView.dataSource = unitPickerDelegate
        
        FirebaseManager().returnUserField(userID: self.userID!, key: "Profile_Configured", completion: { (value) in
            print("status \(value))")
            self.configurationStatus = value as! Bool
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedControlClicked(_ sender: Any) {
        if assessmentTypeChoiceSegmentedControl.selectedSegmentIndex == 0{
            scaleAssessmentPanel.isHidden = false
            quantityAssessmentPanel.isHidden = true
        }else if assessmentTypeChoiceSegmentedControl.selectedSegmentIndex == 1{
            scaleAssessmentPanel.isHidden = true
            quantityAssessmentPanel.isHidden = false
        }
    }
    
    
    @IBAction func optionalityButtonClicked(_ sender: Any) {
        print("Optionality Clicked")
        optionalityChosen = !optionalityChosen //change the optionality bool
        
        if optionalityChosen{
            self.optionalityButtonPanel.layer.borderWidth = 3.5
            self.optionalityButtonPanel.layer.borderColor = greenDesignColor.cgColor
            
            optionalityButton.setTitle("Optionality Chosen!", for: .normal)
        }else{
            self.optionalityButtonPanel.layer.borderColor = UIColor.clear.cgColor
            optionalityButton.setTitle("Optional Activity?", for: .normal)
        }
    }
    
    //MARK: - Adding Assessment
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        let inputTitle = titleTextField.text!
        let inputSummary = summaryTextField.text!
        let categoryIndex = categoryTypePickerView.selectedRow(inComponent: 0) //index of selected row
        let unitIndex = unitPickerView.selectedRow(inComponent: 0)
        let chosenCategory = categoryPickerDelegate.assessmentCategoryTypes[categoryIndex] //get the  string value
        let chosenUnit = determineUnitIdentifier(rawValue: unitPickerDelegate.unitTypes[unitIndex])
        
        let assessmentTypeChoice = assessmentTypeChoiceSegmentedControl.selectedSegmentIndex
        
        let assessmentTypeIdentifier =  determineQuantityTypeIdentifier(selection: chosenCategory)
        
        
        print("Configuration status: \(self.configurationStatus)")
        
        //If configuration have been finished on this profile
        if self.configurationStatus == true{
            
            //We try to find patients doctor
            FirebaseManager().findPatientDoctor(patientID: userID!) {
                (doctor) in
                
                //If we find a doctor
                if doctor != nil{
                    
                    print("Found Doctor")
                    
                    //We send a request for his/her approval based on the type of assessment (two different types of requests for the assessment activities)
                    if assessmentTypeChoice == 0 {
                        
                        FirebaseManager().makeAlteringRequest(fromPatient: self.userID!, toDoctor: doctor as! String, requestIdentifier: "Add Scale Assessment", parameters:
                            [inputTitle, inputSummary, self.scaleAssessmentDescriptionTextField.text!, Int(self.maxValueTextField.text!)!, Int(self.minValueTextField.text!)!, self.optionalityChosen ])
                        
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                        
                    }else {
                        
                        FirebaseManager().makeAlteringRequest(fromPatient: self.userID!, toDoctor: doctor as! String, requestIdentifier: "Add Quantity Assessment", parameters:
                            [inputTitle, inputSummary, self.quantityAssessmentDescriptionTextField.text!, chosenCategory, chosenUnit, self.optionalityChosen ])
                        
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                }else{
                    print("You do not have a profile-linked doctor.")
                }
            }
        }else{
            
            if assessmentTypeChoice == 0{ //Scale type of assessment is desired
                
                ActionPlanAlteringManager().addScaleAssessment(inputTitle: inputTitle, inputSummary: inputSummary, scaleAssessmentDescription: scaleAssessmentDescriptionTextField.text!,
                    selectedMaxValue: Int(maxValueTextField.text!)!, selectedMinValue: Int(minValueTextField.text!)!, optionalityChosen: optionalityChosen, completion: {
                    (success) in
                    print("Action Plan Altering - \(success) (for Adding Scale Assessment)")
                })
                
            }else{ //Quantity type of assessment is desired
                
                ActionPlanAlteringManager().addQuantityAssessment(inputTitle: inputTitle, inputSummary: inputSummary, quantityAssessmentDesciption: quantityAssessmentDescriptionTextField.text!, quantityAssessmentTypeIdentifier: assessmentTypeIdentifier, unitChosen: chosenUnit, optionalityChosen: optionalityChosen, completion: {
                    (success) in
                    print("Action Plan Altering - \(success) (for Adding Quantity Assessment)")
                })
            }
            
        }
    }

    
    //MARK: - Helper Functions
    func determineQuantityTypeIdentifier(selection: String) -> HKQuantityTypeIdentifier{
        
        var identifier = HKQuantityTypeIdentifier.respiratoryRate     //default value
        
        if selection == "Exercise"{
            identifier = HKQuantityTypeIdentifier.appleExerciseTime
        }
        else if selection == "Vital Capacity"{
            identifier = HKQuantityTypeIdentifier.forcedVitalCapacity
        }
        else if selection == "Inhaler Tracking"{
            identifier = HKQuantityTypeIdentifier.inhalerUsage
        }
        
        return identifier
    }
    
//    let unitTypes = ["---", "seconds", "minutes", "calories","liters", "liters/min", "count","meter","mile"]
    func determineUnitIdentifier(rawValue: String) -> String{
        var unitIdentifier = "count"    //default value
        
        if rawValue == "seconds"{
            unitIdentifier = "s"
        }
        else if rawValue == "minutes"{
            unitIdentifier = "min"
        }
        else if rawValue == "calories"{
            unitIdentifier = "cal"
        }
        else if rawValue == "liters"{
            unitIdentifier = "l"
        }
        else if rawValue == "liters/min"{
            unitIdentifier = "l/min"
        }
        else if rawValue == "meter"{
            unitIdentifier = "m"
        }
        else if rawValue == "kilometers"{
            unitIdentifier = "km"
        }
        else if rawValue == "mile"{
            unitIdentifier = "mi"
        }
        
        return unitIdentifier
    }
    
}
