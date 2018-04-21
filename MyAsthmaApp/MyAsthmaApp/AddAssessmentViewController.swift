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
        let chosenUnit = unitPickerDelegate.unitTypes[unitIndex]

        let myCarePlanStore = storeManager.myCarePlanStore

        let activityBuilder = ActivityBuilder()

        activityBuilder.setActivityDefinitions(title: inputTitle, summary: inputSummary, instructions: "", groupIdentifier: "")

        let activity: OCKCarePlanActivity

        if assessmentTypeChoiceSegmentedControl.selectedSegmentIndex == 0{

            activity = activityBuilder.createAssessmentActivity(assessmentType: .scaleAssessment, assessmentDescription: scaleAssessmentDescriptionTextField.text!, maxValue: Int(maxValueTextField.text!)!, minValue: Int(minValueTextField.text!)!, optionality: optionalityChosen)
        }else{

            activity = activityBuilder.createAssessmentActivity(assessmentType: .quantityAssessment, assessmentDescription: quantityAssessmentDescriptionTextField.text!, quantityTypeIdentifier: determineQuantityTypeIdentifier(selection: chosenCategory), unit: "mg/dL", optionality: optionalityChosen)
        }
    
        myCarePlanStore.add(activity) {
            (success, error) in
            if error != nil  {
                print("Error adding the assessment activity \(error!)")
            }
            else{
                print("Assessment Activity successfully added")

                DispatchQueue.main.async { //Because we need to update these from the main thread not background one
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)

                }

            }
        }
    }

    
    //MARK: - Helper Functions
    func determineQuantityTypeIdentifier(selection: String) -> HKQuantityTypeIdentifier{
        
        var identifier = HKQuantityTypeIdentifier.respiratoryRate;     //default value
        
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
    
}
