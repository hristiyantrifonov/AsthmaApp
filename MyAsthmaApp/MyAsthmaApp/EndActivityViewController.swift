//
//  EndActivityViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/3/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class EndActivityViewController: UIViewController {
    
    @IBOutlet weak var activitiesPickerView: UIPickerView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    
    var activitiesNames : [String] = []
    var selectedActivity : String = ""
    var selectedEndDate : DateComponents = DateComponents()
    
    let calendar = Calendar.current
    let todaysDate = Date()
    
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activitiesPickerView.delegate = self
        activitiesPickerView.dataSource = self
        
        //By default the submission end date is today
        let year = calendar.component(.year, from: todaysDate)
        let month = calendar.component(.month, from: todaysDate)
        let day = calendar.component(.day, from: todaysDate)
        selectedEndDate = DateComponents(year: year, month: month, day: day)
        
        doneButton?.layer.cornerRadius = 5
        doneButton?.layer.borderWidth = 1.5
        doneButton?.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
        
        findAllActivitiesNames()
        
        datePicker.isEnabled = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Enable date picker if user wants to specify date
    @IBAction func segmentControlClicked(_ sender: Any) {
        //Today's date
        let year = calendar.component(.year, from: todaysDate)
        let month = calendar.component(.month, from: todaysDate)
        let day = calendar.component(.day, from: todaysDate)
        
        if segmentedControl.selectedSegmentIndex == 0{ //from today
            datePicker.isEnabled = false
            selectedEndDate.day = day
            selectedEndDate.month = month
            selectedEndDate.year = year
        }
        else if segmentedControl.selectedSegmentIndex == 1{ //from next week
            datePicker.isEnabled = false
            let currentWeekEnd = todaysDate.endOfWeek
            print(currentWeekEnd)
            let theLastDayOfCurrentWeek = calendar.component(.day, from: currentWeekEnd!)
            let theFirstDayOfNextWeek = calendar.component(.day, from: currentWeekEnd!)+1
            
            selectedEndDate.day = theFirstDayOfNextWeek
            
            if theFirstDayOfNextWeek > theLastDayOfCurrentWeek{
                selectedEndDate.month = month
            }else{
                selectedEndDate.month =  month+1
            }
            selectedEndDate.year = year
        }
        else if segmentedControl.selectedSegmentIndex == 2{
            datePicker.isEnabled = true
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        
        print(selectedActivity)
        
        if datePicker.isEnabled{
            let calendar = Calendar.current
            print(calendar.component(.day, from: datePicker.date))
            print(calendar.component(.month, from: datePicker.date))
            print(calendar.component(.year, from: datePicker.date))
        }else{
            
            print(selectedEndDate.day!)
            print(selectedEndDate.month!)
            print(selectedEndDate.year!)
        }
    }
    //MARK: - Helper Functions
    
    func findAllActivitiesNames() {
        storeManager.myCarePlanStore.activities {
            (success, activitiesArray, error) in
            
            self.activitiesNames.append("--")
            
            if success{
                for activity in activitiesArray{
                    let activityName = activity.title
                    print("HEREEEE")
                    self.activitiesNames.append(activityName)
                }
            }else{
                print(error!)
            }
        }
    }
}

extension EndActivityViewController: UIPickerViewDelegate{
    
}

extension EndActivityViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.activitiesNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.activitiesNames[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("ActivitySelected")
        if self.activitiesNames[row] != "--"{
            selectedActivity = self.activitiesNames[row]
        }else{
            print("Wrong value selected")
        }
        
    }
}


extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
}
