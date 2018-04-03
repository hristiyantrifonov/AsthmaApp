//
//  AddActivitiesViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/31/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit


class AddActivitiesViewController: UIViewController {
    
    //Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var summaryTextField: UITextField!
    @IBOutlet weak var instructionsTextField: UITextField!
    var selectedGroupIdentifier : String = ""
    var successAddition : Bool = false
    
    //Group Part Properties
    var activitiesGroupsArray : [String] = []
    @IBOutlet weak var groupsPickerView: UIPickerView!
    @IBOutlet weak var newGroupButton: UIButton!
    @IBOutlet weak var groupPickerPanel: UIView!
    
    @IBOutlet weak var newGroupTextField: UITextField!
    @IBOutlet weak var newGroupPanel: UIView!
    @IBOutlet weak var cancelNewGroupButton: UIButton!
    
    //Schedule Part Properties
    @IBOutlet weak var mondayView: UIView!
    @IBOutlet weak var mondayTextField: UITextField!
    @IBOutlet weak var tuesdayView: UIView!
    @IBOutlet weak var tuesdayTextField: UITextField!
    @IBOutlet weak var wednesdayView: UIView!
    @IBOutlet weak var wednesdayTextField: UITextField!
    @IBOutlet weak var thursdayView: UIView!
    @IBOutlet weak var thursdayTextField: UITextField!
    @IBOutlet weak var fridayView: UIView!
    @IBOutlet weak var fridayTextField: UITextField!
    @IBOutlet weak var saturdayView: UIView!
    @IBOutlet weak var saturdayTextField: UITextField!
    @IBOutlet weak var sundayView: UIView!
    @IBOutlet weak var sundayTextField: UITextField!
    
    //Optionality Part properties and fields
    var optionalChosen = false
    @IBOutlet weak var optionalityButtonPanel: UIView!
    @IBOutlet weak var optionalityButton: UIButton!
    let greenDesignColor = UIColor(red:40/255, green:164/255, blue:40/255, alpha: 1)
    
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var submitAndAddAnotherButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        summaryTextField.delegate = self
        instructionsTextField.delegate = self
        mondayTextField.delegate = self
        tuesdayTextField.delegate = self
        wednesdayTextField.delegate = self
        thursdayTextField.delegate = self
        fridayTextField.delegate = self
        saturdayTextField.delegate = self
        sundayTextField.delegate = self
        newGroupTextField.delegate = self
        
        newGroupPanel.isHidden = true
        
        //Style the buttons with black borders
        newGroupButton.backgroundColor = .clear
        newGroupButton.layer.cornerRadius = 5
        newGroupButton.layer.borderWidth = 1.5
        newGroupButton.layer.borderColor = UIColor.black.cgColor
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderWidth = 1.5
        doneButton.layer.borderColor = UIColor.black.cgColor
        submitAndAddAnotherButton.layer.cornerRadius = 5
        submitAndAddAnotherButton.layer.borderWidth = 1.5
        submitAndAddAnotherButton.layer.borderColor = UIColor.black.cgColor
        cancelNewGroupButton.layer.cornerRadius = 5
        cancelNewGroupButton.layer.borderWidth = 1.5
        cancelNewGroupButton.layer.borderColor = UIColor.black.cgColor
        
        groupsPickerView.delegate = self
        groupsPickerView.dataSource = self
        
        
        findCurrentActivityGroupIdentifiers()
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /***  OPTIONALITY PART  ***/
    //The Optionality button style changes to green when selected and vice-versa
    @IBAction func optinalityChosen(_ sender: Any) {
        print("Optionality Clicked")
        optionalChosen = !optionalChosen //change the optionality bool
        
        if optionalChosen{
            self.optionalityButtonPanel.layer.borderWidth = 3.5
            self.optionalityButtonPanel.layer.borderColor = greenDesignColor.cgColor
            
            optionalityButton.setTitle("Optionality Chosen!", for: .normal)
        }else{
            self.optionalityButtonPanel.layer.borderColor = UIColor.clear.cgColor
            optionalityButton.setTitle("Optional Activity?", for: .normal)
        }
        
    }
    
    @IBAction func newGroupButtonClicked(_ sender: Any) {
        groupPickerPanel.isHidden = true
        newGroupPanel.isHidden = false
        selectedGroupIdentifier = ""
    }
    
    @IBAction func cancelNewGroupButtonClicked(_ sender: Any) {
        newGroupTextField.text = ""
        newGroupPanel.isHidden = true
        groupPickerPanel.isHidden = false
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        
        let inputTitle = titleTextField.text!
        let inputSummary = summaryTextField.text!
        let inputInstructions = instructionsTextField.text!
        
        var inputGroupIdentifier = ""
        if (newGroupTextField.text?.isEmpty)!{
            inputGroupIdentifier = selectedGroupIdentifier
        }else{
            inputGroupIdentifier = newGroupTextField.text!
        }
        let mo = Int(mondayTextField.text!) ?? 0
        let tu = Int(tuesdayTextField.text!) ?? 0
        let we = Int(wednesdayTextField.text!) ?? 0
        let th = Int(thursdayTextField.text!) ?? 0
        let fr = Int(fridayTextField.text!) ?? 0
        let sa = Int(saturdayTextField.text!) ?? 0
        let su = Int(sundayTextField.text!) ?? 0
    
        let schedule = [su,mo,tu,we,th,fr,sa]
        
        print(schedule)
        print(inputTitle, inputSummary, inputInstructions, "\(inputGroupIdentifier)", schedule, self.optionalChosen)
        
        //Adding the activity with the specified parameters
        let myCarePlanStore = storeManager.myCarePlanStore
        
        let activityBuilder = ActivityBuilder()
        
        activityBuilder.setActivityDefinitions(title: inputTitle, summary: inputSummary, instructions: inputInstructions, groupIdentifier: "\(inputGroupIdentifier)")
        
        let chosenSchedule = activityBuilder.constructSchedule(occurencesArray: schedule)
        
        let activity = activityBuilder.createActivity(schedule: chosenSchedule, optionality: self.optionalChosen)
        myCarePlanStore.add(activity) {
            (success, error) in
            if error != nil  {
                print("Error adding an activity \(error!)")
            }
            else{
                print("Activity successfully added")
                self.successAddition = true
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)

            }
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helper Functions
    func findCurrentActivityGroupIdentifiers(){
        storeManager.myCarePlanStore.activities {
            (success, activitiesArray, error) in
            
            self.activitiesGroupsArray.append("---") //default value
            
            if success{
                for activity in activitiesArray{
                    let activityGroup = activity.groupIdentifier!
                    if !self.activitiesGroupsArray.contains(activityGroup) && activityGroup != "Assessment"{
                        self.activitiesGroupsArray.append(activityGroup)
                    }
                }
                
            }else{
                print(error!)
            }
        }
    }
    
}

extension AddActivitiesViewController: UIPickerViewDelegate {
    
}

extension AddActivitiesViewController:  UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.activitiesGroupsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.activitiesGroupsArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print("VALUE IN PICKER SELECTED: " + self.activitiesGroupsArray[row])
        self.selectedGroupIdentifier = self.activitiesGroupsArray[row]
        
    }
    
}

extension AddActivitiesViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("TEXTFIELD CLICKED !!!!")
        print(textField.tag)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Did end Editing")
        var tag = textField.tag
        if tag == 1{
            if textField.text != ""{
                mondayView.layer.cornerRadius = 7
                mondayView.layer.borderWidth = 2
                mondayView.layer.borderColor = greenDesignColor.cgColor
            }
        }
        if tag == 2{
            if textField.text != ""{
                tuesdayView.layer.cornerRadius = 7
                tuesdayView.layer.borderWidth = 2
                tuesdayView.layer.borderColor = greenDesignColor.cgColor
            }
        }
        if tag == 3{
            if textField.text != ""{
                wednesdayView.layer.cornerRadius = 7
                wednesdayView.layer.borderWidth = 2
                wednesdayView.layer.borderColor = greenDesignColor.cgColor
            }
        }
        if tag == 4{
            if textField.text != ""{
                thursdayView.layer.cornerRadius = 7
                thursdayView.layer.borderWidth = 2
                thursdayView.layer.borderColor = greenDesignColor.cgColor
            }
        }
        if tag == 5{
            if textField.text != ""{
                fridayView.layer.cornerRadius = 7
                fridayView.layer.borderWidth = 2
                fridayView.layer.borderColor = greenDesignColor.cgColor
            }
        }
        if tag == 6{
            if textField.text != ""{
                saturdayView.layer.cornerRadius = 7
                saturdayView.layer.borderWidth = 2
                saturdayView.layer.borderColor = greenDesignColor.cgColor
            }
        }
        if tag == 7{
            if textField.text != ""{
                sundayView.layer.cornerRadius = 7
                sundayView.layer.borderWidth = 2
                sundayView.layer.borderColor = greenDesignColor.cgColor
            }
        }
    }
}
