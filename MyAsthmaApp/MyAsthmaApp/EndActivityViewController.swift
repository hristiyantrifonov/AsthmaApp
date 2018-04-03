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
    
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activitiesPickerView.delegate = self
        activitiesPickerView.dataSource = self
        
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
        if segmentedControl.selectedSegmentIndex == 2{
            datePicker.isEnabled = true
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
        
}



