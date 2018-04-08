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
    
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                DispatchQueue.main.async { //Because we need to update these from the main thread not background one
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
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
    
//    let activityType: ActivityType = .caffeine
//
//    func carePlanActivity() -> OCKCarePlanActivity {
//        // Create a weekly schedule.
//        let startDate = DateComponents(year: 2016, month: 01, day: 01)
//        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [2, 1, 1, 1, 1, 1, 2])
//
//        // Get the localized strings to use for the activity.
//        let title = NSLocalizedString("Caffeine", comment: "")
//        let summary = NSLocalizedString("Avoid Caffeine.", comment: "")
//        let instructions = NSLocalizedString("Avoid caffeine consumption.", comment: "")
//
//        // Create the read only activity.
//        let activity = OCKCarePlanActivity.readOnly(withIdentifier: activityType.rawValue,
//                                                    groupIdentifier: nil,
//                                                    title: title,
//                                                    text: summary,
//                                                    instructions: instructions,
//                                                    imageURL: nil,
//                                                    schedule: schedule,
//                                                    userInfo: nil)
//
//        return activity
//    }

}
