//
//  Activity.swift
//  MyAsthmaApp
//
//  Created by CCM2308 CCM2308 on 28/02/2018.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit

/**
 Protocol that defines the properties and methods for sample activities.
 */
protocol Activity {
    var activityType: ActivityType { get }
    
    func carePlanActivity() -> OCKCarePlanActivity
}


//provides unique identifiers for intervention and assessment activities
enum ActivityType: String {
    case takeNurofen
    case outdoorWalk
    
    case bloodGlucose
    
}
