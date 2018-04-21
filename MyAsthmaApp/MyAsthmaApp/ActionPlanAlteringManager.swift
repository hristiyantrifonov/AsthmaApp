//
//  ActionPlanAlteringManager.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/20/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import Foundation
import CareKit

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
                completion(false)
            }
            else{
                print("Activity successfully added")
                completion(true)
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
    func addScaleAssessment(inputTitle : String, inputSummary : String, scaleAssessmentDescription : String, selectedMaxValue : Int, selectedMinValue : Int,
                            optionalityChosen : Bool, completion: @escaping Value){
        
        let myCarePlanStore = storeManager.myCarePlanStore
        
        let activityBuilder = ActivityBuilder()
        
        activityBuilder.setActivityDefinitions(title: inputTitle, summary: inputSummary, instructions: "", groupIdentifier: "")
        
        let activity: OCKCarePlanActivity
        
        activity = activityBuilder.createAssessmentActivity(assessmentType: .scaleAssessment, assessmentDescription: scaleAssessmentDescription, maxValue: selectedMaxValue, minValue: selectedMinValue, optionality: optionalityChosen)
        
        
        myCarePlanStore.add(activity) {
            (success, error) in
            if error != nil  {
                print("Error adding the assessment activity \(error!)")
                completion(false)
            }
            else{
                print("Scale Assessment Activity successfully added")
                completion(true)
                //                DispatchQueue.main.async { //Because we need to update these from the main thread not background one
                //                    self.navigationController?.popViewController(animated: true)
                //                    self.dismiss(animated: true, completion: nil)
                //
                //                }
                
            }
        }
    }
    
    func addQuantityAssessment(inputTitle : String, inputSummary : String, quantityAssessmentDesciption : String, quantityAssessmentTypeIdentifier : HKQuantityTypeIdentifier,
                               optionalityChosen : Bool, completion: @escaping Value){
        
        let myCarePlanStore = storeManager.myCarePlanStore
        
        let activityBuilder = ActivityBuilder()
        
        activityBuilder.setActivityDefinitions(title: inputTitle, summary: inputSummary, instructions: "", groupIdentifier: "")
        
        let activity: OCKCarePlanActivity
        
        activity = activityBuilder.createAssessmentActivity(assessmentType: .quantityAssessment, assessmentDescription: quantityAssessmentDesciption, quantityTypeIdentifier: quantityAssessmentTypeIdentifier, unit: "mg/dL", optionality: optionalityChosen)
        
        
        myCarePlanStore.add(activity) {
            (success, error) in
            if error != nil  {
                print("Error adding the assessment activity \(error!)")
                completion(false)
            }
            else{
                print("Quantity Assessment Activity successfully added")
                completion(true)
                
                
            }
        }
        
    }
    
    
}
