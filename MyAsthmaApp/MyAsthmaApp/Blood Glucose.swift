//
//  Blood Glucose.swift
//  MyAsthmaApp
//
//  Created by CCM2308 CCM2308 on 02/03/2018.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import ResearchKit
import CareKit

/**
 Struct that conforms to the `Assessment` protocol to define a blood glucose
 assessment.
 */
struct BloodGlucose: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .bloodGlucose
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        let thresholds = [OCKCarePlanThreshold.numericThreshold(withValue: NSNumber.init(value: 70), type: .numericRangeInclusive, upperValue: NSNumber.init(value: 100), title: "Healthy blood glucose."), OCKCarePlanThreshold.numericThreshold(withValue: NSNumber.init(value: 180), type: .numericGreaterThanOrEqual, upperValue: nil, title: "High blood glucose.")] as Array<OCKCarePlanThreshold>;
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Blood Glucose", comment: "")
        let summary = NSLocalizedString("After dinner", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: activityType.rawValue,
            groupIdentifier: "Assessment",
            title: title,
            text: summary,
            tintColor: UIColor.blue,
            resultResettable: false,
            schedule: schedule,
            userInfo: nil,
            thresholds: [thresholds],
            optional: false
        )
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        // Get the localized strings to use for the task.
        let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!
        let unit = HKUnit(from: "mg/dL")
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
        
        // Create a question.
        let title = NSLocalizedString("Input your blood glucose", comment: "")
        let questionStep = ORKQuestionStep(identifier: activityType.rawValue, title: title, answer: answerFormat)
        questionStep.isOptional = false
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [questionStep])
        
        return task
    }
}
