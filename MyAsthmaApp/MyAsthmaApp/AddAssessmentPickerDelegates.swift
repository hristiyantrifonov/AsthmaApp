//
//  AddAssessmentPickerDelegates.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/11/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class CategoryTypePickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let assessmentCategoryTypes = ["---", "Exercise", "Vital Capacity", "Inhaler Tracking", "Respiratory Rate"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return assessmentCategoryTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return assessmentCategoryTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("VALUE IN PICKER SELECTED: " + self.assessmentCategoryTypes[row])
    }
    
}

class UnitTypePickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    /*
     Main Guidance:
     HKQuantityTypeIdentifier AppleExerciseTime - measured in SECOND/ MINUTE / CALORIE / TIME
     HKQuantityTypeIdentifier ForcedVitalCapacity - measured in LITER
     HKQuantityTypeIdentifier InhalerUsage - measured in COUNT
     HKQuantityTypeIdentifier RespiratoryRate - measured in COUNT / TIME
     
     Extra units added:
        meter
        mile
    */
    let unitTypes = ["---", "second", "minute", "calorie", "liter", "count", "time" , "meter", "mile"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unitTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return unitTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("VALUE IN PICKER SELECTED: " + self.unitTypes[row])
        
    }
    
}
