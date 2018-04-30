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
    @IBOutlet weak var beginConfigurationButton: UIButton!
    
    @IBOutlet weak var changeActionPlanButton: UIButton!
    @IBOutlet weak var insightsSettingsButton: UIButton!
    @IBOutlet weak var viewRequestsButton: UIButton!
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var knowledgeBookButton: UIButton!
    
    @IBOutlet weak var nameContainer: UIView!
    @IBOutlet weak var alteringOptionsContainer: UIView!
    @IBOutlet weak var generalOptionsContainer: UIView!
    @IBOutlet weak var logOutContainer: UIView!
    
    var ref: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    
    //The current user object
    var user : User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Styles of the Main Tab
        self.view.backgroundColor = UIColor.init(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        nameContainer.layer.borderWidth = 1
        nameContainer.layer.borderColor = Colors.borderGrey.color.cgColor
        alteringOptionsContainer.layer.borderWidth = 1
        alteringOptionsContainer.layer.borderColor = Colors.borderGrey.color.cgColor
        generalOptionsContainer.layer.borderWidth = 1
        generalOptionsContainer.layer.borderColor = Colors.borderGrey.color.cgColor
        logOutContainer.layer.borderWidth = 1
        logOutContainer.layer.borderColor = Colors.borderGrey.color.cgColor
        
        storeManager.updateInsights()
        
        ref = Database.database().reference()
        print(userID!)
        self.beginConfigurationButton.isHidden = true
        self.changeActionPlanButton.isHidden = true
        
        //Finds the current user in the RealTime Database in Firebase and
        //obtains the users' values for displaying in the app
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            print(snapshot.value)
            
            let userObject = snapshot.value as? NSDictionary
            
            let forename = userObject?["Forename"] as? String ?? ""
            let surname = userObject?["Surname"] as? String ?? ""
            let email = userObject?["Email"] as? String ?? ""
            let profileConfigured = userObject?["Profile_Configured"] as? Bool
            
            print("Profile Configured: \(profileConfigured)")
            
            self.user = User(withForename: forename,withSurname: surname, withEmail: email)
            
            self.greetingLabel.text = " " + (self.user?.forename!)! + " " + (self.user?.surname!)!
            
            //Only show the Begin Configuration Button if the profile is not configured
            //This is checked by a boolean field in the Firebase database record for the user
            self.beginConfigurationButton.isHidden = profileConfigured!
            self.changeActionPlanButton.isHidden = !(profileConfigured!)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        storeManager.updateInsights()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    @IBAction func beginCofigurationClicked(_ sender: Any) {
        let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpDoctorCredentialsRequest") as! PopUpDoctorCredentialsViewController
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    @IBAction func changeActionPlanClicked(_ sender: Any) {
        
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


