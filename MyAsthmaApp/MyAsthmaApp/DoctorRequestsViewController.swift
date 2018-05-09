//
//  DoctorRequestsViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/19/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class DoctorRequestsViewController: UIViewController {
    
    let doctorID = Auth.auth().currentUser?.uid
    let firebaseManager = FirebaseManager()
    
    @IBOutlet weak var requestsTableView: UITableView!
    var requestsArray : Array<Any> = []
    var requestID : String!
    var requestFields : NSDictionary!
    var patientFields : NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarItem = UITabBarItem(title: "Requests", image: UIImage(named: "requests"), selectedImage: UIImage.init(named: "requests-filled"))
        
        firebaseManager.fetchDoctorRequests(doctorID: doctorID!) {
            (requests) in
    
            if requests != nil{
                self.requestsArray = requests as! Array<Any>
                self.requestsTableView.delegate = self
                self.requestsTableView.dataSource = self
                self.requestsTableView.reloadData()
                
            }else{
                print("No requests found")
                SVProgressHUD.dismiss()
                
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.requestsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension DoctorRequestsViewController: UITableViewDelegate {
    
}

extension DoctorRequestsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requestsArray.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
        
        // Configure the cell...
        FirebaseManager().getRequestFields(requestID: requestsArray[indexPath.row] as! String) {
            (returnedRequestDictionary) in

            let requestObject = returnedRequestDictionary as! NSDictionary
            cell.textLabel?.text = "\(requestObject["Identifier"] as! String) Request"
            
            if requestObject["Reviewed"] != nil {
                cell.detailTextLabel?.text = "Reviewed"
                cell.detailTextLabel?.textColor = UIColor(red: 0/255, green: 179/255, blue: 60/255, alpha: 1)
                tableView.reloadData()
            }else{
                cell.detailTextLabel?.text = ""
                tableView.reloadData()
            }

        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        requestID = requestsArray[indexPath.row] as! String
        FirebaseManager().getRequestFields(requestID: self.requestID) {
            (returnedRequestFieldsDictionary) in
            self.requestFields = returnedRequestFieldsDictionary as! NSDictionary
            
            let patientID = self.requestFields["Patient"] as? String ?? ""
            
            //Find the patient profile from database
            FirebaseManager().getPatientFields(patientID: patientID, completion: {
                (patientProfile) in
                
                self.patientFields = patientProfile as! NSDictionary
                
                self.performSegue(withIdentifier: "goToRequestReview", sender: self)
            })
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToRequestReview"{
            let destinationVC = segue.destination as! RequestReviewViewController
            destinationVC.requestID = self.requestID
            destinationVC.requestFields = self.requestFields
            destinationVC.patientFields = self.patientFields
        }
    }
    
}
