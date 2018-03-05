//
//  TakeNurofen.swift
//  MyAsthmaApp
//
//  Created by CCM2308 CCM2308 on 02/03/2018.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit

struct TakeNurofen: Activity {
    
    let activityType: ActivityType = .takeNurofen
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2018, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [2, 3, 3, 1, 3, 1, 2])
        
        // Get the localized strings to use for the activity.
        let title = NSLocalizedString("TakeNurofen", comment: "")
        let summary = NSLocalizedString("15 mins", comment: "")
        let instructions = NSLocalizedString("Take a leisurely walk.", comment: "")
        
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
