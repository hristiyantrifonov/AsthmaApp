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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        cell.textLabel?.text = requestsArray[indexPath.row] as! String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToRequestReview", sender: self)
        
    }
    
    
}
