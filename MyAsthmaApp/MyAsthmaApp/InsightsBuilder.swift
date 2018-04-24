//
//  InsightsBuilder.swift
//  MyAsthmaApp
//
//  Created by CCM2308 CCM2308 on 26/02/2018.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import Foundation
import CareKit
import Firebase

class InsightsBuilder {
    
    fileprivate(set) var insights = [OCKInsightItem.noInsightsToShowMessage()]
    
    fileprivate let carePlanStore: OCKCarePlanStore
    
    let patientID = Auth.auth().currentUser?.uid
    
    //Operation queue will help assign tasks to different threads, or different queues other than the main one
    //Thus any time-consuming or CPU demanding tasks should run on concurrent or background queues. (and not
    //freeze the main thread aka the users interface)
    
    //here we instantiate a queue that will regulate the execution of a set of operations.
    fileprivate let updateOperationQueue = OperationQueue()
    let myGroup = DispatchGroup()
    
    required init(carePlanStore: OCKCarePlanStore){
        self.carePlanStore = carePlanStore
        
        
    }
    
    
    /*
     Enqueue NSOperation's to query the OCKCarePlanStore and update the 'insights' property
     */
    func updateInsights(_ completion: ((Bool, [OCKInsightItem]?) -> Void)?){
        //Cancel all queued or executing (in-progress) operations
        myGroup.enter()
        updateOperationQueue.cancelAllOperations()
        
        //Get the dates of current and previous weeks
        let dateRange = calculateDateRange()
        
        
        
        /*******  GUERY OPERATIONS  *******/
        
        //Define operations to query for events for the previous week of every activity/assessment
        //Gives us data in the form of enumerated events for activities with particular identifiers - This is our first operation
        var identifiersArray = ["--none--", "mb1", "mb2"]
        var medicationArraySettingOne = ["mmmmm", "outdoorWalk"]
        var medicationArraySettingTwo = ["mb2", "outdoorWalk"]
        var medicationArraySettingThree = ["mmmmm", "mb1"]
        
        print("------")
//        ["Identifiers" : identifiersDict, "first-meds" : firstSettingMedications, "second-meds" : secondSettingMedications, "third-meds" : thirdSettingMedications]
        FirebaseManager().getPatientMainSettings(patientID: self.patientID!) {
            (settingsDict) in
            
            let dict = settingsDict as! [String : [String]]
            
            identifiersArray = dict["Identifiers"]!
            medicationArraySettingOne = dict["first-meds"]!
            medicationArraySettingTwo = dict["second-meds"]!
            medicationArraySettingThree = dict["third-meds"]!
            
            self.myGroup.leave()
        }
        print("------")
        
//
        
        myGroup.notify(queue: .main) {
            print(identifiersArray)
            print(medicationArraySettingOne)
            print(medicationArraySettingTwo)
            print(medicationArraySettingThree)
        /*******  BUILD OPERATIONS  *******/
        
        //Now we create "BuildInsightsOperation" to actually make insights from the data collected
        let buildInsightsOperation = BuildInsightsOperation()
        
        
        //MARK: - First Setting
        let insightSettingOneEventsOperation = QueryActivityEventsOperation(store: self.carePlanStore,
                                                                  startDate: dateRange.start, endDate: dateRange.end,
                                                                  activityIdentifier: identifiersArray[0])
            //Subsetings - for first setting
        let settingOneFirstSubsetting = QueryActivityEventsOperation(store: self.carePlanStore,
                                                                     startDate: dateRange.start, endDate: dateRange.end,
                                                                     activityIdentifier: medicationArraySettingOne[0])
        
        let settingOneSecondSubsetting = QueryActivityEventsOperation(store: self.carePlanStore,
                                                                      startDate: dateRange.start, endDate: dateRange.end,
                                                                      activityIdentifier: medicationArraySettingOne[1])
        
        //MARK: - Second Setting
        let insightSettingTwoEventsOperation = QueryActivityEventsOperation(store: self.carePlanStore,
                                                                  startDate: dateRange.start, endDate: dateRange.end,
                                                                  activityIdentifier: identifiersArray[1])
        //Subsetings - for second setting
        let settingTwoFirstSubsetting = QueryActivityEventsOperation(store: self.carePlanStore,
                                                                     startDate: dateRange.start, endDate: dateRange.end,
                                                                     activityIdentifier: medicationArraySettingTwo[0])
        
        let settingTwoSecondSubsetting = QueryActivityEventsOperation(store: self.carePlanStore,
                                                                      startDate: dateRange.start, endDate: dateRange.end,
                                                                      activityIdentifier: medicationArraySettingTwo[1])
        
        //MARK: - Third Setting
        let insightSettingThreeEventsOperation = QueryActivityEventsOperation(store: self.carePlanStore,
                                                                  startDate: dateRange.start, endDate: dateRange.end,
                                                                  activityIdentifier: identifiersArray[2])
        
        //Subsetings - for second setting
        let settingThreeFirstSubsetting = QueryActivityEventsOperation(store: self.carePlanStore,
                                                                     startDate: dateRange.start, endDate: dateRange.end,
                                                                     activityIdentifier: medicationArraySettingThree[0])
        
        let settingThreeSecondSubsetting = QueryActivityEventsOperation(store: self.carePlanStore,
                                                                      startDate: dateRange.start, endDate: dateRange.end,
                                                                      activityIdentifier: medicationArraySettingThree[1])
        

        
        //Operation to feed the data from the queries to the BuildInsightsOperation
        let feedDataOperation = BlockOperation {
            
            buildInsightsOperation.settingOneEvents = insightSettingOneEventsOperation.dailyEvents
            buildInsightsOperation.settingOneFirstSubsettingEvents = settingOneFirstSubsetting.dailyEvents
            buildInsightsOperation.settingOneSecondSubsettingEvents = settingOneSecondSubsetting.dailyEvents
            
            buildInsightsOperation.settingTwoEvents = insightSettingTwoEventsOperation.dailyEvents
            buildInsightsOperation.settingTwoFirstSubsettingEvents = settingTwoFirstSubsetting.dailyEvents
            buildInsightsOperation.settingTwoSecondSubsettingEvents = settingTwoSecondSubsetting.dailyEvents
            
            buildInsightsOperation.settingThreeEvents = insightSettingThreeEventsOperation.dailyEvents
            buildInsightsOperation.settingThreeFirstSubsettingEvents = settingThreeFirstSubsetting.dailyEvents
            buildInsightsOperation.settingThreeSecondSubsettingEvents = settingThreeSecondSubsetting.dailyEvents
            
        }
        
        //Use the completion block of the "BuildInsightsOperation" to store the new insights
        buildInsightsOperation.completionBlock = { [unowned buildInsightsOperation] in
            let completed = !buildInsightsOperation.isCancelled
            let newInsights = buildInsightsOperation.insights
            
            // Call the completion block on the main queue.
            OperationQueue.main.addOperation {
                if completed {
                    completion?(true, newInsights)
                }
                else {
                    completion?(false, nil)
                }
            }
        }
        
        /*** ADDING DEPENDENCIES FOR SMOOTH OPERATIONAL FLOW ***/
        //this is instead of semaphore?
        
        //addDependency - make the receiver (feedDataOperation) dependent on the completion of the argument in brackets
        //feedDataOperation is dependent on the QUERY OPERATIONS
        feedDataOperation.addDependency(insightSettingOneEventsOperation)
        feedDataOperation.addDependency(settingOneFirstSubsetting)
        feedDataOperation.addDependency(settingOneSecondSubsetting)
        
        feedDataOperation.addDependency(insightSettingTwoEventsOperation)
        feedDataOperation.addDependency(settingTwoFirstSubsetting)
        feedDataOperation.addDependency(settingTwoSecondSubsetting)
        
        feedDataOperation.addDependency(insightSettingThreeEventsOperation)
        feedDataOperation.addDependency(settingThreeFirstSubsetting)
        feedDataOperation.addDependency(settingThreeSecondSubsetting)
        
        
        //"BuildInsightsOperation" is dependent on the completion of the data feeding
        buildInsightsOperation.addDependency(feedDataOperation)
        
        
        //Finally add all operations to the operational queue
        self.updateOperationQueue.addOperations([
            insightSettingOneEventsOperation,
            settingOneFirstSubsetting,
            settingOneSecondSubsetting,
            insightSettingTwoEventsOperation,
            settingTwoFirstSubsetting,
            settingTwoSecondSubsetting,
            insightSettingThreeEventsOperation,
            settingThreeFirstSubsetting,
            settingThreeSecondSubsetting,
            feedDataOperation,
            buildInsightsOperation
            ], waitUntilFinished: false)
        }
    }
    
    //MARK: - Helper Functions
    
    fileprivate func calculateDateRange() -> (start: DateComponents, end: DateComponents){
        let calendar = Calendar.current
        let currentDate = Date()
        
        let currentWeekRange = calendar.weekDatesForDate(currentDate)
        let previousWeekRange = calendar.weekDatesForDate(currentWeekRange.start.addingTimeInterval(-1))
        
        let queryRangeStart = calendar.dateComponents([.year, .month, .day, .era], from: previousWeekRange.start)
        let queryRangeEnd = calendar.dateComponents([.year, .month, .day, .era], from: currentDate)
        
        return (start: queryRangeStart, end: queryRangeEnd)
    }
    
}

protocol InsightsBuilderDelegate: class {
    func insightsBuilder(_ insightsBuilder: InsightsBuilder, didUpdateInsights insights: [OCKInsightItem])
}


//MARK: - READ AGAIN ( Calendar extension)

//NOTE: Perhaps might need to write my own
extension Calendar {
    /**
     Returns a tuple containing the start and end dates for the week that the
     specified date falls in.
     */
    func weekDatesForDate(_ date: Date) -> (start: Date, end: Date) {
        var interval: TimeInterval = 0
        var start: Date = Date()
        _ = dateInterval(of: .weekOfYear, start: &start, interval: &interval, for: date)
        let end = start.addingTimeInterval(interval)
        
        return (start as Date, end as Date)
    }
}

