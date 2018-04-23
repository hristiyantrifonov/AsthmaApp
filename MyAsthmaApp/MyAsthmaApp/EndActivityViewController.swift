//
//  EndActivityViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/3/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase

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
    let userID = Auth.auth().currentUser?.uid
    var configurationStatus : Bool = true
    
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
        
        //Find out whether user profile has been configured or not and set the class variable
        FirebaseManager().returnUserField(userID: self.userID!, key: "Profile_Configured", completion: { (value) in
            print("status \(value))")
            self.configurationStatus = value as! Bool
        })
        
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
        print("End Activity Request for \(selectedActivity)")
        let myCarePlanStore = storeManager.myCarePlanStore
        
        var endDateDay : Int,
        endDateMonth: Int,
        endDateYear: Int
        
        //If date picker view is enabled then user wants to specify custom date
        //and we obtain the values from the picker
        //If not - then user selected today or next week
        if datePicker.isEnabled{
            let calendar = Calendar.current
            endDateDay = calendar.component(.day, from: datePicker.date)
            endDateMonth = calendar.component(.month, from: datePicker.date)
            endDateYear = calendar.component(.year, from: datePicker.date)
        }else{
            endDateDay = selectedEndDate.day!
            endDateMonth = selectedEndDate.month!
            endDateYear = selectedEndDate.year!
        }
        
        //The date at which the activity will be ended
        //THIS/////////////////////
        //        let endDate = DateComponents(year: endDateYear, month: endDateMonth, day: endDateDay)
        //        print("End Date Chosen: \(endDate)")
        
        
        print("Configuration status: \(self.configurationStatus)")
        
        //If configuration have been finished on this profile
        if self.configurationStatus == true{
            
            //We try to find patients doctor
            FirebaseManager().findPatientDoctor(patientID: userID!) {
                (doctor) in
                
                //If we find a doctor
                if doctor != nil{
                    
                    //We send a request for his/her approval
                    FirebaseManager().makeAlteringRequest(fromPatient: self.userID!, toDoctor: doctor as! String,
                                                          requestIdentifier: "End Activity", parameters: [self.selectedActivity.lowercased(), endDateDay, endDateMonth, endDateYear])
                    
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                    
                }else{
                    print("You do not have a profile-linked doctor.")
                }
            }
        }else{
            
            ActionPlanAlteringManager().endActivity(withIdentifier: self.selectedActivity.lowercased(),endDay: endDateDay, endMonth: endDateMonth, endYear: endDateYear, completion: {
                    (success) in
                print("Action Plan Altering - \(success)")
            })
            
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
                    print(activity.schedule.endDate)
                    
                    //Show only the activities without an endDate
                    if ((activity.schedule.endDate) == nil) {
                        self.activitiesNames.append(activityName)
                    }
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
