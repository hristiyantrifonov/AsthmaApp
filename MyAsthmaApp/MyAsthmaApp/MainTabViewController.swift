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

class MainTabViewController: UIViewController {
    
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
