//
//  TaskBuilder.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/7/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit
import ResearchKit

//provides unique identifiers for intervention and assessment activities
enum AssessmentType: String {
    case scaleAssessment
    case quantityAssessment
}

//Class for building the task associated with assessment activities
class TaskBuilder {
    
    //MARK: - Properties
    var assessmentActivityIdentifier : String?
    
    //MARK: - Initialisation
    init() { }
    
    func createScaleAssessmentTask(descriptionQuestion: String, maxValue: Int, minValue: Int, optionality: Bool) -> ORKTask {
        
        print("YAYAYYAYAY")
        print("optionality: \(optionality)")
        
        let displayedQuestion = NSLocalizedString(descriptionQuestion, comment: "")
        let maximumValueDescription = NSLocalizedString("Very much", comment: "")
        let minimumValueDescription = NSLocalizedString("Not at all", comment: "")
        
        //Defining the answer format for the assessment
        let answerFormat = ORKScaleAnswerFormat(
            maximumValue: maxValue,
            minimumValue: minValue,
            defaultValue: -1,
            step: Int(maxValue/10),
            vertical: false,
            maximumValueDescription: maximumValueDescription,
            minimumValueDescription: minimumValueDescription
        )
        
        let questionStep = ORKQuestionStep(identifier: assessmentActivityIdentifier!, title: displayedQuestion, answer: answerFormat)
        questionStep.isOptional = optionality
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: assessmentActivityIdentifier!, steps: [questionStep])
        
        return task
    }
    
    func createQuantityAssessmentTask(descriptionTitle: String, quantityTypeIdentifier: HKQuantityTypeIdentifier, unitString: String, optionality: Bool) -> ORKTask {
//        HKQuantityTypeIdentifier.appleExerciseTime
//        HKQuantityTypeIdentifier.forcedVitalCapacity - amount of air forcibly exhaled after deepest breath
//        HKQuantityTypeIdentifier.inhalerUsage
//        HKQuantityTypeIdentifier.respiratoryRate
        
        //Task describing strings
        let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier)!
        let unit = HKUnit(from: unitString)
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
        
        //Create the questions and the assessment
        let title = NSLocalizedString(descriptionTitle, comment: "")
        let questionStep = ORKQuestionStep(identifier: assessmentActivityIdentifier!, title: title, answer: answerFormat)
        
        //Define optionality of the task
        questionStep.isOptional = optionality
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: assessmentActivityIdentifier!, steps: [questionStep])
        
        return task

    }
}


//BLOOD GLUCOSE
//func task() -> ORKTask {
//    // Get the localized strings to use for the task.
//    let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!
//    let unit = HKUnit(from: "mg/dL")
//    let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
//
//    // Create a question.
//    let title = NSLocalizedString("Input your blood glucose", comment: "")
//    let questionStep = ORKQuestionStep(identifier: activityType.rawValue, title: title, answer: answerFormat)
//    questionStep.isOptional = false
//
//    // Create an ordered task with a single question.
//    let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [questionStep])
//
//    return task
//}


//BACK PAIN
//func task() -> ORKTask {
//    // Get the localized strings to use for the task.
//    let question = NSLocalizedString("How was your pain today?", comment: "")
//    let maximumValueDescription = NSLocalizedString("Very much", comment: "")
//    let minimumValueDescription = NSLocalizedString("Not at all", comment: "")
//
//    // Create a question and answer format.
//    let answerFormat = ORKScaleAnswerFormat(
//        maximumValue: 10,
//        minimumValue: 1,
//        defaultValue: -1,
//        step: 1,
//        vertical: false,
//        maximumValueDescription: maximumValueDescription,
//        minimumValueDescription: minimumValueDescription
//    )
//
//    let questionStep = ORKQuestionStep(identifier: activityType.rawValue, title: question, answer: answerFormat)
//    questionStep.isOptional = false
//
//    // Create an ordered task with a single question.
//    let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [questionStep])
//
//    return task
//}

