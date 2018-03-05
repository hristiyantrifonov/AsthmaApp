//
//  Assessment.swift
//  MyAsthmaApp
//
//  Created by CCM2308 CCM2308 on 02/03/2018.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit
import ResearchKit

protocol Assessment: Activity {
    func task() -> ORKTask
}

extension Assessment {
    func buildResultForCarePlanEvent(_ event: OCKCarePlanEvent, taskResult: ORKTaskResult) -> OCKCarePlanEventResult {
        // Get the first result for the first step of the task result.
        guard let firstResult = taskResult.firstResult as? ORKStepResult, let stepResult = firstResult.results?.first else { fatalError("Unexepected task results") }
        
        // Determine what type of result should be saved.
        if let scaleResult = stepResult as? ORKScaleQuestionResult, let answer = scaleResult.scaleAnswer {
            return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: "of 10", userInfo: nil, values: [answer])
        }
        else if let numericResult = stepResult as? ORKNumericQuestionResult, let answer = numericResult.numericAnswer {
            return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: numericResult.unit!, userInfo: nil, values: [answer])
        }
        
        fatalError("Unexpected task result type")
    }
}
