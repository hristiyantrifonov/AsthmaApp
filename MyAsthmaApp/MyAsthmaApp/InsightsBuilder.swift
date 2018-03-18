//
//  InsightsBuilder.swift
//  MyAsthmaApp
//
//  Created by CCM2308 CCM2308 on 26/02/2018.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import Foundation
import CareKit

class InsightsBuilder {
    
    fileprivate(set) var insights = [OCKInsightItem.noInsightsToShowMessage()]
    
    fileprivate let carePlanStore: OCKCarePlanStore
    
    //Operation queue will help assign tasks to different threads, or different queues other than the main one
    //Thus any time-consuming or CPU demanding tasks should run on concurrent or background queues. (and not
    //freeze the main thread aka the users interface)
    
    //here we instantiate a queue that will regulate the execution of a set of operations.
    fileprivate let updateOperationQueue = OperationQueue()
    
    required init(carePlanStore: OCKCarePlanStore){
        self.carePlanStore = carePlanStore
        
        print("INSIGHTS BUILDER CALLED")
    }
    
    
    /*
     Enqueue NSOperation's to query the OCKCarePlanStore and update the 'insights' property
     */
    func updateInsights(_ completion: ((Bool, [OCKInsightItem]?) -> Void)?){
        //Cancel all queued or executing (in-progress) operations
        updateOperationQueue.cancelAllOperations()
        
        //Get the dates of current and previous weeks
        let dateRange = calculateDateRange()
        
        print("PreQUERY OPERATIONS")
        
        /*******  GUERY OPERATIONS  *******/
        
        //Define operations to query for events for the previous week of every activity/assessment
        //Gives us data in the form of enumerated events for activities with particular identifiers - This is our first operation
        
        let outdoorWalkEventsOperation = QueryActivityEventsOperation(store: carePlanStore,
                                                                      startDate: dateRange.start, endDate: dateRange.end,
                                                                      activityIdentifier: ActivityType.outdoorWalk.rawValue)
        
        let takeNurofenEventsOperation = QueryActivityEventsOperation(store: carePlanStore,
                                                                      startDate: dateRange.start, endDate: dateRange.end,
                                                                      activityIdentifier: ActivityType.takeNurofen.rawValue)
        
        let bloodGlucoseEventsOperation = QueryActivityEventsOperation(store: carePlanStore,
                                                                       startDate: dateRange.start, endDate: dateRange.end,
                                                                       activityIdentifier: ActivityType.bloodGlucose.rawValue)
        
        print("AFTER QUERY OPERATIONS")
        
        /*******  BUILD OPERATIONS  *******/
        
        //Now we create "BuildInsightsOperation" to actually make insights from the data collected
        let buildInsightsOperation = BuildInsightsOperation()
        
        print("AFTER BUILD INSIGHTS OPERATION")
        
        //Operation to feed the data from the queries to the BuildInsightsOperation
        let feedDataOperation = BlockOperation {
            buildInsightsOperation.outdoorWalkEvents = outdoorWalkEventsOperation.dailyEvents
            buildInsightsOperation.takeNurofenEvents = takeNurofenEventsOperation.dailyEvents
            buildInsightsOperation.bloodGlucoseEvents = bloodGlucoseEventsOperation.dailyEvents
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
        feedDataOperation.addDependency(outdoorWalkEventsOperation)
        feedDataOperation.addDependency(takeNurofenEventsOperation)
        feedDataOperation.addDependency(bloodGlucoseEventsOperation)
        
        //"BuildInsightsOperation" is dependent on the completion of the data feeding
        buildInsightsOperation.addDependency(feedDataOperation)
        
        
        //Finally add all operations to the operational queue
        updateOperationQueue.addOperations([
            outdoorWalkEventsOperation,
            takeNurofenEventsOperation,
            bloodGlucoseEventsOperation,
            feedDataOperation,
            buildInsightsOperation
            ], waitUntilFinished: false)
        
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

