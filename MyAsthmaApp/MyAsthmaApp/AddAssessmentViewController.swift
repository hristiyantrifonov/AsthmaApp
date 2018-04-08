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
    
    let assessmentCategoryTypes = ["---", "Exercise (sec)", "Vital Capacity", "Inhaler Tracking", "Respiratory Rate"]
    
    //Scale Assessment Panel & it's Properties
    @IBOutlet weak var scaleAssessmentPanel: UIView!
    @IBOutlet weak var scaleAssessmentDescriptionTextField: UITextField!
    @IBOutlet weak var maxValueTextField: UITextField!
    @IBOutlet weak var minValueTextField: UITextField!
    
    //Quantity Assessment Panle & it's Properties
    @IBOutlet weak var quantityAssessmentPanel: UIView!
    @IBOutlet weak var quantityAssessmentDescriptionTextField: UITextField!
    @IBOutlet weak var categoryTypePickerView: UIPickerView!
    @IBOutlet weak var unitTextField: UITextField!
    
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Style the Done button
        doneButton?.layer.cornerRadius = 5
        doneButton?.layer.borderWidth = 1.5
        doneButton?.layer.borderColor = UIColor.black.cgColor
        
        scaleAssessmentPanel.isHidden = false
        quantityAssessmentPanel.isHidden = true
        
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
        
        let myCarePlanStore = storeManager.myCarePlanStore
        
        let activityBuilder = ActivityBuilder()
        let taskBuilder = TaskBuilder()
        
        activityBuilder.setActivityDefinitions(title: inputTitle, summary: inputSummary, instructions: "", groupIdentifier: "")
        
        let activity = activityBuilder.createAssessmentActivity()
        myCarePlanStore.add(activity) {
            (success, error) in
            if error != nil  {
                print("Error adding the assessment activity \(error!)")
            }
            else{
                print("Assessment Activity successfully added")
                
                //Set the task builder's identifier to the create assessment identifier
                taskBuilder.assessmentActivityIdentifier = activity.identifier
                
                DispatchQueue.main.async { //Because we need to update these from the main thread not background one
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }
        
        //If we have set the Task Builder's identifier we continue
        if (taskBuilder.assessmentActivityIdentifier != nil){
            if assessmentTypeChoiceSegmentedControl.selectedSegmentIndex == 0{
                let task = taskBuilder.createScaleAssessmentTask(descriptionQuestion: scaleAssessmentDescriptionTextField.text!, maxValue: Int(maxValueTextField.text!)!,
                                                      minValue: Int(minValueTextField.text!)!, optionality: optionalityChosen)
                
                //TODO - find out how the task part is added/associated with activity
                
                print("Created Scale Assessment Task")
            }else{
                let task = taskBuilder.createQuantityAssessmentTask(descriptionTitle: quantityAssessmentDescriptionTextField.text!, quantityTypeIdentifier: HKQuantityTypeIdentifier.respiratoryRate, unitString: unitTextField.text!, optionality: optionalityChosen)
                print("Created Quantitu Assessment Task")
            }
        }
        
        
    }
    
}

//MARK: - Picker View Extensions & Methods

extension AddAssessmentViewController: UIPickerViewDelegate {
    
}

extension AddAssessmentViewController:  UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return assessmentCategoryTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return assessmentCategoryTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print("VALUE IN PICKER SELECTED: " + self.assessmentCategoryTypes[row])
        
    }
    
}
