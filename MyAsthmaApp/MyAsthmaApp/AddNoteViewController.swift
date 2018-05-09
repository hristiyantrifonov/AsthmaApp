//
//  AddNoteViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/3/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import CareKit

class AddNoteViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var summaryTextField: UITextField!
    @IBOutlet weak var instructionsTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    var successAddition : Bool = false
    let additionText = "Successfully added a new note!"
    
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.backgroundColor = .clear
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderWidth = 1
        doneButton.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func doneButtonClicked(_ sender: Any) {
        
        let inputTitle = titleTextField.text!
        let inputSummary = summaryTextField.text!
        let inputInstructions = instructionsTextField.text!
        
        
        let myCarePlanStore = storeManager.myCarePlanStore
        
        let activityBuilder = ActivityBuilder()
        
        activityBuilder.setActivityDefinitions(title: inputTitle, summary: inputSummary, instructions: inputInstructions, groupIdentifier: "")
        
        let activity = activityBuilder.createNoteActivity()
        myCarePlanStore.add(activity) {
            (success, error) in
            if error != nil  {
                print("Error adding the note \(error!)")
            }
            else{
                print("Note successfully added")
            }
        }
        
    }

}
