//
//  InsightSettingsPickerDelegates.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/24/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class MainInsightPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var mainInsightOptions = ["--none--"]
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mainInsightOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        storeManager.myCarePlanStore.activities(with: .assessment) { (success, activities, errorOrNil) in
            guard success else {
                // perform proper error handling here
                fatalError(errorOrNil!.localizedDescription)
            }
            
            for i in activities{
                self.mainInsightOptions.append(i.identifier)
            }
            
        }
        
        return mainInsightOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("VALUE IN PICKER SELECTED: " + self.mainInsightOptions[row])
    }
    
}

class FirstMedicationInsightPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var firstMedicationOptions = ["--none--"]
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return firstMedicationOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        storeManager.myCarePlanStore.activities(with: .intervention ) { (success, activities, errorOrNil) in
            guard success else {
                // perform proper error handling here
                fatalError(errorOrNil!.localizedDescription)
            }
            
            for i in activities{
                self.firstMedicationOptions.append(i.identifier)
            }
            
        }
        
        return firstMedicationOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("VALUE IN PICKER SELECTED: " + self.firstMedicationOptions[row])
    }
    
}

class SecondMedicationInsightPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var secondMedicationOptions = ["--none--"]
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return secondMedicationOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        storeManager.myCarePlanStore.activities(with: .intervention ) { (success, activities, errorOrNil) in
            guard success else {
                // perform proper error handling here
                fatalError(errorOrNil!.localizedDescription)
            }
            
            for i in activities{
                self.secondMedicationOptions.append(i.identifier)
            }
            
        }
        
        return secondMedicationOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("VALUE IN PICKER SELECTED: " + self.secondMedicationOptions[row])
    }
    
}
