//
//  PeakFlow.swift
//  MyAsthmaApp
//
//  Created by user136629 on 5/1/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit
import ResearchKit

/**
 Struct that conforms to the `Assessment` protocol to define a back pain
 assessment.
 */
struct PeakFlow: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .peakFlow
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Peak Flow", comment: "")
        let summary = NSLocalizedString("Measure Daily", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: "peak flow",
            groupIdentifier: "Assessment",
            title: title,
            text: summary,
            tintColor: UIColor.blue,
            resultResettable: false,
            schedule: schedule,
            userInfo: [AnyHashable("assessmentType") : "quantityAssessment", AnyHashable("descriptions") : "Measure how quickly you can blow air out of your lungs with the peak flow meter", AnyHashable("maxValue") : 1, AnyHashable("minValue") : 0, AnyHashable("quantityTypeIdentifier") : HKQuantityTypeIdentifier.forcedVitalCapacity, AnyHashable("unit") : "l/min", AnyHashable("optionality") : false],
            thresholds: nil,
            optional: false
        )
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        // Get the localized strings to use for the task.
        let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.forcedVitalCapacity)!
        let unit = HKUnit(from: "l/min")
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
        
        // Create a question.
        let title = NSLocalizedString("Measure how quickly you can blow air out of your lungs with the peak flow meter", comment: "")
        let questionStep = ORKQuestionStep(identifier: "peak flow", title: title, answer: answerFormat)
        questionStep.isOptional = false
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: "peak flow", steps: [questionStep])
        
        return task
    }
}
