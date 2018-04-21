//
//  ActionPlanAlteringManager.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/20/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import Foundation

class ActionPlanAlteringManager {
    
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    typealias Value = (Any?) -> Void
    
    init() {
    }
    
    func endActivity(withIdentifier selectedActivity : String, endDay : Int, endMonth : Int, endYear : Int, completion : @escaping Value){
        let myCarePlanStore = storeManager.myCarePlanStore
        
        let endDate = DateComponents(year: endYear, month: endMonth, day: endDay)
        print("End Date Chosen: \(endDate)")
        
        storeManager.myCarePlanStore.activities {
            (success, activitiesArray, error) in
            
            if success{
                let identifier = selectedActivity.lowercased()
                print("Identifier: \(identifier)")
                
                myCarePlanStore.activity(forIdentifier: identifier) { (success, chosenActivity, error) in
                    if success {
                        print("Found activity with identifier: \(identifier)")
                        
                        myCarePlanStore.setEndDate(endDate, for: chosenActivity!, completion: { (success, updatedActivity, error) in
                            if success{
                                print("Successfully ended activity")
                                completion(true)
                                
                            }else{
                                print("Could not update endDate")
                                completion(false)
                            }
                        })
                        
                    }else{
                        print(error!)
                        completion(false)
                    }
                }
                
            }else{
                print(error!)
                completion(false)
            }
        }
    }
    
    //TODO
    func addActivity(inputTitle : String, inputSummary : String, inputInstructions : String ,
                     inputGroupdIdentifier : String, schedule : [Int], optionalChosen : Bool, completion : @escaping Value) {
        
        let myCarePlanStore = storeManager.myCarePlanStore
        
        let activityBuilder = ActivityBuilder()
        
        activityBuilder.setActivityDefinitions(title: inputTitle, summary: inputSummary, instructions: inputInstructions, groupIdentifier: "\(inputGroupdIdentifier)")
        
        let chosenSchedule = activityBuilder.constructSchedule(occurencesArray: schedule)
        
        let activity = activityBuilder.createInterventionActivity(schedule: chosenSchedule, optionality: optionalChosen)
        myCarePlanStore.add(activity) {
            (success, error) in
            if error != nil  {
                print("Error adding an activity \(error!)")
            }
            else{
                print("Activity successfully added")
//                self.successAddition = true
//                DispatchQueue.main.async { //Because the navigation controller must be updated from the main thread
//                    self.navigationController?.popViewController(animated: true)
//                    self.dismiss(animated: true, completion: nil)
//                    
//                }
            }
        }
        
    }
    
    //TODO
    func addAssessment(){
        
    }
    
}
