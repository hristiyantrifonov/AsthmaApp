//
//  MainTabViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/7/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import CareKit

class MainTabViewController: UIViewController {
    
    //pointer to the shared store
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    
    var ref: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    
    //The current user object
    var user : User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        print(userID!)
        
        //Finds the current user in the RealTime Database in Firebase and
        //obtains the users' values for displaying in the app
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let userObject = snapshot.value as? NSDictionary
            
            let forename = userObject?["Forename"] as? String ?? ""
            let surname = userObject?["Surname"] as? String ?? ""
            let email = userObject?["Email"] as? String ?? ""
            
            self.user = User(withForename: forename,withSurname: surname, withEmail: email)
            
            self.greetingLabel.text = "Hello " + (self.user?.forename!)! + " " + (self.user?.surname!)!
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addActivityPressed(_ sender: Any) {
        print("Add activity pressed")
        
        let myCarePlanStore = storeManager.myCarePlanStore
        
        let activityBuilder = ActivityBuilder()
        
        activityBuilder.setActivityDefinitions(title: "This is a test", summary: "Testing Summary", instructions: "Testing Instuctions", groupIdentifier: "Medications")
        
        let chosenSchedule = activityBuilder.constructSchedule(occurencesArray: [3, 3, 3, 3, 3, 1, 1])
        let optionalityChosen = false
        
        let activity = activityBuilder.createActivity(schedule: chosenSchedule, optionality: optionalityChosen)
        myCarePlanStore.add(activity) {
            (success, error) in
            if error != nil  {
                print("Error adding an activity \(error!)")
            }
            else{
                print("Activity successfully added")
            }
        }
    }
    
    //Ending an activity by setting an End Date to it - this is to preserve the previous date obtained from the activity
    //instead of just deleting it
    @IBAction func endActivityRequest(_ sender: Any) {
        print("End Activity Request")
        let myCarePlanStore = storeManager.myCarePlanStore
        
        storeManager.myCarePlanStore.activities {
            (success, activitiesArray, error) in
            if success {
                var identifier = activitiesArray[activitiesArray.count-1].identifier
                print(identifier)
                
                myCarePlanStore.activity(forIdentifier: identifier) { (success, chosenActivity, error ) in
                    if success {
                        print("founds activity - \(identifier)")
                        var endDate = DateComponents(year: 2018, month: 03, day: 23)
                        chosenActivity?.schedule.setValue(endDate, forKey: "endDate")
                        print("successfuly changed")
                    }else{
                        print(error!)
                    }
                }
                
                print(activitiesArray[activitiesArray.count-1].schedule.startDate)
                print(activitiesArray[activitiesArray.count-1].schedule.endDate)
            }else{
                print(error!)
            }
        }
    }
    //Logout button to clear session
    @IBAction func logOutPressed(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            
            print("Logged out")
            
        }catch{
            print("Could not logout user")
        }
        
    }
    
    //TODO - Display user's name (try using sideway window
    
    
}
