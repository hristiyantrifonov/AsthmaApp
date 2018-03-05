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
    
//    fileprivate(set) var insights = [OCKInsightItem.emptyInsightsMessage()]
    
    fileprivate let carePlanStore: OCKCarePlanStore
    fileprivate let updateOperationQueue = OperationQueue()
    
    required init(carePlanStore: OCKCarePlanStore){
        self.carePlanStore = carePlanStore
    }
    
}

protocol InsightsBuilderDelegate: class {
    func insightsBuilder(_ insightsBuilder: InsightsBuilder, didUpdateInsights insights: [OCKInsightItem])
}
