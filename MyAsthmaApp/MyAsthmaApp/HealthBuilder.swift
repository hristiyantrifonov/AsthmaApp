//
//  HealthBuilder.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/7/18.
//  Copyright (c) 2016, Apple Inc. All rights reserved.
//

import ResearchKit

/*
 A protocol that defines the methods and properties required to be able to save
 an "ORKTaskResult" to a "ORKCarePlanStore"
 */
protocol HealthSampleBuilder {
    var quantityType: HKQuantityType { get }
    
    var unit: HKUnit { get }
    
    func buildSampleWithTaskResult(_ result: ORKTaskResult) -> HKQuantitySample
    
    func localizedUnitForSample(_ sample: HKQuantitySample) -> String
}
