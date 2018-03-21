//
//  TestActivity.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/21/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit

struct TestActivity: Activity {
    
    let activityType: ActivityType = .test
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2018, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [2, 6, 3, 1, 3, 1, 2])
        
        // Get the localized strings to use for the activity.
        let title = NSLocalizedString("Test", comment: "")
        let summary = NSLocalizedString("15 mins", comment: "")
        let instructions = NSLocalizedString("lalala.", comment: "")
        
        // Create the intervention activity.
        let activity = OCKCarePlanActivity.intervention(
            withIdentifier: activityType.rawValue,
            groupIdentifier: "Medications",
            title: title,
            text: summary,
            tintColor: UIColor.purple,
            instructions: instructions,
            imageURL: nil,
            schedule: schedule,
            userInfo: nil,
            optional: false
        )
        
        return activity
    }
    
}

