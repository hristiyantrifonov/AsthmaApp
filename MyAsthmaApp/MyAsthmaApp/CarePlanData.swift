//
//  CarePlanData.swift
//  MyAsthmaApp
//
//  Created by CCM2308 CCM2308 on 28/02/2018.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit


class CarePlanData: NSObject {
    /* Class will be difining activities and adding them to
     the data store  */
    
    //MARK: Properties
    
    let carePlanStore: OCKCarePlanStore
    
    let activities: [Activity] = [
        OutdoorWalk(),
        TakeNurofen(),
        BloodGlucose(),
        BackPain()]
    
    //MARK: Initialisation
    
    init(carePlanStore: OCKCarePlanStore) {
        self.carePlanStore = carePlanStore
        
        //TODO: Define intervention activities
        
        //Add the activities to the store
        for activity in activities {
            let carePlanActivity = activity.carePlanActivity()
            carePlanStore.add(carePlanActivity) {
                (success, error) in
                if error != nil  {
                    print("Error adding ac activity \(error!)")
                    
                }
                else{
                    print("Activity successfully added")
                }
            }
        }
        
        
        //TODO: Define assessment activities
        
        super.init()
        
        //TODO: Add activities to store
    }
    
    
    // MARK: Convenience
    
    /// Returns the `Activity` that matches the supplied `ActivityType`.
    func activityWithType(_ type: ActivityType) -> Activity? {
        for activity in activities where activity.activityType == type {
            return activity
        }
        return nil
    }
    
}
