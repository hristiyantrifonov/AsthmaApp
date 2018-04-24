//
//  InsightSettingsPickerDelegates.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/24/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit


class MainInsightPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let assessmentCategoryTypes = ["--none--", "Vital Capacity", "Inhaler Tracking", "Respiratory Rate"]
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
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

class FirstMedicationInsightPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let assessmentCategoryTypes = ["--none--", "Inhaler Tracking", "Respiratory Rate"]
    
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

class SecondMedicationInsightPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let assessmentCategoryTypes = ["--none--", "Exercise", "Vital Capacity", "Inhaler Tracking", "Respiratory Rate"]
    
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
