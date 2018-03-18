//
//  QueryActivityEventsOperation.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/16/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit

class QueryActivityEventsOperation : Operation {
    
    //MARK: - Properties
    
    fileprivate let store: OCKCarePlanStore
    fileprivate let startDate: DateComponents
    fileprivate let endDate: DateComponents
    
    fileprivate let activityIdentifier: String
    
    //the property is read-only outside of this class definition
    fileprivate(set) var dailyEvents: DailyEvents?
    
    //MARK: - Initialisation
    
    init(store: OCKCarePlanStore, startDate: DateComponents, endDate: DateComponents, activityIdentifier: String){
        self.store = store
        self.startDate = startDate
        self.endDate = endDate
        self.activityIdentifier = activityIdentifier
        
        print("QueryActivityEventsOperation CALLED")
    }
    
    
    //MARK: - The Operation
    
    override func main() {
        
        print("BEGIN OPERATION")
        
        //If operation is cancelled we exit
        guard !isCancelled else { return }
        
        print("IS NOT CANCELLED FOR: \(activityIdentifier)")
        
        //If we do not find the requested activity we exit
        guard let activity = findActivity() else { return }
        
        print("ACTIVITY: \(activityIdentifier) - \(activity)")
        
        //semaphore to wait for the asynchronous call to "enumerateEventsOfActivity" to complete
        let semaphore = DispatchSemaphore(value: 0)
        
        //Query instance for obtaining activities between the requested date
        self.dailyEvents = DailyEvents()
        
        //DispatchQueu manages the execution of work items.
        //Here we enumerate each event (between the start and the end date) of an activity
        DispatchQueue.main.async {
            //enumerates all the events associated with activity within a given range
            self.store.enumerateEvents(of: activity, startDate: self.startDate as DateComponents,
                                       endDate: self.endDate as DateComponents, handler: { event, _ in
                if let event = event {
                    self.dailyEvents?[event.date].append(event)
                }
            }, completion: { (_,_) in
                semaphore.signal() //signal that the query is completed
            })
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)    //wait to be signalled again
    }
    
    //MARK: - Convenience
    
    //Finding the tasks the user has in his action plan
    //In a sesnse we guard the "activityForIdentifier" queries towards our CarePlanStore
    //so that we do not block it and they are done one by one (from the InsightsBuilder where we declare
    //them one after another, which calls this)
    fileprivate func findActivity() -> OCKCarePlanActivity? {
        
        //Whenever we would like to use one shared resource, we send a request to its semaphore
        //Once the semaphore gives us green light we use the resource and after we finish we signal
        //tne sempahore in order to assign the rosource to the others to use it.
        
        let semaphore = DispatchSemaphore(value: 0)  //semaphore to wait for the asynchronous call to "activityForIdentifier"
        var activity: OCKCarePlanActivity?
        
        //Get the activity with the provided identifier
        store.activity(forIdentifier: activityIdentifier) {
            (success, foundActivity, error) in
            
            activity = foundActivity
            
            if !success { print(error?.localizedDescription as Any) }
            
            semaphore.signal()  //send signal that query is complete
        }
        
        //Wait for the semaphore to be signalled
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return activity
    }
    
}



//Structure - allow us to encapsulate related properties and behaviors and then use it in the code
struct DailyEvents {
    
    //MARK: - Properties
    
    //mappedEvents is a dictionary of DateComponents(days) where each day has array of OCKCarePlanEvents (events recorded during that day
    fileprivate var mappedEvents: [DateComponents: [OCKCarePlanEvent]]
    
    var allEvents: [OCKCarePlanEvent]{ return Array(mappedEvents.values.joined())}    //values = the events
    
    var allDays: [DateComponents] { return Array(mappedEvents.keys) }  //keys = the days
    
    
    //Subscripts are used to access information from a collection, sequence and a
    //list in Classes, Structures and Enumerations without using a method
    
    //We declare the subscript so that calling DailyEvents(day: Tuesday) will gives us all of the days events (or set them)
    subscript(day: DateComponents) -> [OCKCarePlanEvent] {
        get {
            if let events = mappedEvents[day]{
                return events
            }
            else {
                return []
            }
        }
        
        set(newValue){
            mappedEvents[day] = newValue
        }
    }
    
    //MARK: - Initialisation
    init(){
        mappedEvents = [:] //empty dictionary literal - to match every hashable protocol
    }
    
}


