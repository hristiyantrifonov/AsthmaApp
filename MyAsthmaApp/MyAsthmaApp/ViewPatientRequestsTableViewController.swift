//
//  ViewPatientRequestsTableViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/20/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase
import CareKit

class PatientSideRequestCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var status: UILabel!
    
}

class ViewPatientRequestsTableViewController: UITableViewController {
    
    var userID = Auth.auth().currentUser?.uid
    var requests : Array<Any> = []
    var selectedRequestID : String!
    
    @IBOutlet weak var finaliseChangesButton: UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disableSubmitButton()
        disableDeleteButton()
        
        FirebaseManager().fetchPatientSubmittedRequests(patientID: userID!) {
            (fetchedRequests) in
            if fetchedRequests != nil{
                self.requests = fetchedRequests as! Array<Any>
                self.tableView.reloadData()
            }else{
                print("No requests found")
            }
            
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enableSubmitButton(){
        finaliseChangesButton.isEnabled = true
        finaliseChangesButton.backgroundColor = UIColor(red: 0/255, green: 179/255, blue: 179/255, alpha: 1)
    }
    
    func enableDeleteButton(){
        deleteButton.isEnabled = true
    }
    
    func disableSubmitButton(){
        finaliseChangesButton.isEnabled = false
        finaliseChangesButton.backgroundColor = UIColor.gray
    }
    
    func disableDeleteButton(){
        deleteButton.isEnabled = false
    }
    @IBAction func dismissClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var count = 1
        if requests.count > 0{
            count = requests.count
        }

        return count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientSideRequestCell", for: indexPath) as! PatientSideRequestCell
        cell.statusLabel.isHidden = false
        cell.status.isHidden = false
        
        if requests.count > 0{
            
            // Configure the cell...
            let requestID = requests[indexPath.row]
            
            FirebaseManager().getRequestFields(requestID: requestID as! String) {
                (requestObject) in
                let request = requestObject as! NSDictionary
                let requestIdentifier = request["Identifier"] as! String
                
                let parametersObject = request["Parameters"] as! NSDictionary
                
                if requestIdentifier == "End Activity"{
                    let target = parametersObject["Target"] as! String
                    cell.descriptionLabel?.text = "\(requestIdentifier) - \(target)"
                }else{
                    let activityTitle = parametersObject["Title"] as! String
                    cell.descriptionLabel?.text = "\(requestIdentifier) - \(activityTitle)"
                }
            }
            
            FirebaseManager().getRequestStatus(requestID: requestID as! String) {
                (status) in
                print("here")
                var reviewedStatus = false
                print(status)
                FirebaseManager().getRequestReviewStatus(requestID: requestID as! String, completion: { (reviewed) in
                    if (reviewed != nil){
                        reviewedStatus = true
                    }
                    
                    
                    if status as! Bool == false && reviewedStatus == true{
                        cell.statusLabel.text = "Rejected"
                        cell.statusLabel.textColor = UIColor(red: 204/255, green: 20/255, blue: 0/255, alpha: 1)
                    }
                    else if status as! Bool == false{
                        cell.statusLabel.text = "Pending"
                        cell.statusLabel.textColor = UIColor(red: 204/255, green: 102/255, blue: 0/255, alpha: 1)
                    }else{
                        cell.statusLabel.text = "Authorised"
                        cell.statusLabel.textColor = UIColor(red: 0/255, green: 179/255, blue: 60/255, alpha: 1)
                    }
                    
                })
                
                
                
            }
            
        }else{
            cell.descriptionLabel.text = "No requests to show..."
            cell.statusLabel.isHidden = true
            cell.status.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)")
        
        if requests.count > 0{
            let selectedCell = tableView.cellForRow(at: indexPath) as! PatientSideRequestCell
            self.selectedRequestID = requests[indexPath.row] as! String
            let status = selectedCell.statusLabel?.text
            
            if status == "Pending"{
                disableSubmitButton()
                disableDeleteButton()
            }
            else if status == "Authorised"{
                enableSubmitButton()
                disableDeleteButton()
            }
            else if status == "Rejected"{
                disableSubmitButton()
                enableDeleteButton()
            }
        }
        
    }
    
    
    
    @IBAction func deleteRequestClicked(_ sender: Any) {
        print("Delete request")
        FirebaseManager().removeRequest(requestID: self.selectedRequestID)
        //Return to main menu
        //TODO - useful to pass back some message of success
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func finaliseChangesClicked(_ sender: Any) {
        print("Finalise Changes Clicked")
        print("For request : \(self.selectedRequestID)")
        
        FirebaseManager().getRequestFields(requestID: self.selectedRequestID) {
            (requestFields) in
            
            let requestObject = requestFields as! NSDictionary
            
            let requestIdentifier = requestObject["Identifier"] as! String
            let parametersObject = requestObject["Parameters"] as! NSDictionary
            
            //Here we see the identifier of the request and do different things depending on it
            if requestIdentifier == "Add Activity"{
                
                //Distribute parameters for Add Activity Altering Action
                let activityTitle = parametersObject["Title"] as! String
                let activitySummary = parametersObject["Summary"] as! String
                let activityInstructions = parametersObject["Instructions"] as! String
                let activityGroupIdentifier = parametersObject["Group-Identifier"] as! String
                
                let scheduleObject = parametersObject["Schedule"] as! NSArray
                print("SCHEDULEEE \(scheduleObject)")
                
                let activitySchedule = scheduleObject as! [Int]
                
                //                let activitySchedule = [su,mo,tu,we,th,fr,sa]
                let optionalityChosen = parametersObject["Optionality"] as! Bool
                
                //Perform the Action
                ActionPlanAlteringManager().addActivity(inputTitle: activityTitle, inputSummary: activitySummary, inputInstructions: activityInstructions, inputGroupdIdentifier: activityGroupIdentifier, schedule: activitySchedule, optionalChosen: optionalityChosen, completion: {
                    (success) in
                    
                    FirebaseManager().removeRequest(requestID: self.selectedRequestID)
                    //Return to main menu
                    //TODO - useful to pass back some message of success
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                })
                
            }
            else if requestIdentifier == "Add S. Assessment"{
                
                let activityTitle = parametersObject["Title"] as! String
                let activitySummary = parametersObject["Summary"] as! String
                let activityDescription = parametersObject["Description"] as! String
                let assessmentMaxValue = parametersObject["Max"] as! Int
                let assessmentMinValue = parametersObject["Min"] as! Int
                let optionalityChosen = parametersObject["Optionality"] as! Bool
                
                ActionPlanAlteringManager().addScaleAssessment(inputTitle: activityTitle, inputSummary: activitySummary, scaleAssessmentDescription: activityDescription,
                    selectedMaxValue: assessmentMaxValue, selectedMinValue: assessmentMinValue, optionalityChosen: optionalityChosen, completion: {
                    (success) in
                                                                
                    FirebaseManager().removeRequest(requestID: self.selectedRequestID)
                                                                
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                
                
            }
            else if requestIdentifier == "Add Q. Assessment"{
                
                let activityTitle = parametersObject["Title"] as! String
                let activitySummary = parametersObject["Summary"] as! String
                let activityDescription = parametersObject["Description"] as! String
                let rawAssessmentTypeCategoryValue = parametersObject["Type-Category"] as! String
                let rawAssessmentUnit = parametersObject["Unit"] as! String
                let optionalityChosen = parametersObject["Optionality"] as! Bool
                
                let assessmentTypeCategory = self.determineQuantityTypeIdentifier(selection: rawAssessmentTypeCategoryValue)
                
                ActionPlanAlteringManager().addQuantityAssessment(inputTitle: activityTitle, inputSummary: activitySummary, quantityAssessmentDesciption: activityDescription, quantityAssessmentTypeIdentifier: assessmentTypeCategory, unitChosen: rawAssessmentUnit, optionalityChosen: optionalityChosen, completion: {
                    (success) in
                    
                    FirebaseManager().removeRequest(requestID: self.selectedRequestID)
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                })
                
            }
            else if requestIdentifier == "End Activity"{
                //Distribute parameters for End Activity Altering Action
                let targetActivityIdentifier = parametersObject["Target"] as! String
                let endDay = parametersObject["End-Day"] as! Int
                let endMonth = parametersObject["End-Month"] as! Int
                let endYear = parametersObject["End-Year"] as! Int
                
                //Perform the actions
                ActionPlanAlteringManager().endActivity(withIdentifier: targetActivityIdentifier, endDay: endDay, endMonth: endMonth, endYear: endYear, completion: { (success) in
                    print("Action Plan Altering - \(success) (End Activity)")
                    
                    FirebaseManager().removeRequest(requestID: self.selectedRequestID)
                    //Return to main menu
                    //TODO - useful to pass back some message of success
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }else{
                //TODO add the other activities options functionality here - Add Activity / Add Assessment
            }
            
        }
        
    }
    
}


extension ViewPatientRequestsTableViewController {
    
    func determineQuantityTypeIdentifier(selection: String) -> HKQuantityTypeIdentifier{
        
        var identifier = HKQuantityTypeIdentifier.respiratoryRate;     //default value
        
        if selection == "Exercise"{
            identifier = HKQuantityTypeIdentifier.appleExerciseTime
        }
        else if selection == "Vital Capacity"{
            identifier = HKQuantityTypeIdentifier.forcedVitalCapacity
        }
        else if selection == "Inhaler Tracking"{
            identifier = HKQuantityTypeIdentifier.inhalerUsage
        }
        
        return identifier
    }
    
}
