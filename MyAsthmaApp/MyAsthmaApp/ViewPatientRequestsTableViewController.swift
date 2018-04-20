//
//  ViewPatientRequestsTableViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/20/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import Firebase

class PatientSideRequestCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
}

class ViewPatientRequestsTableViewController: UITableViewController {
    
    var userID = Auth.auth().currentUser?.uid
    var requests : Array<Any> = []
    
    @IBOutlet weak var finaliseChangesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disableSubmitButton()
        
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
    
    func disableSubmitButton(){
        finaliseChangesButton.isEnabled = false
        finaliseChangesButton.backgroundColor = UIColor.gray
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requests.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientSideRequestCell", for: indexPath) as! PatientSideRequestCell

        // Configure the cell...
        let requestID = requests[indexPath.row]
        cell.descriptionLabel?.text = requestID as! String
        
        FirebaseManager().getRequestStatus(requestID: requestID as! String) {
            (status) in
            print("here")
            print(status)
            if status as! Bool == false{
                cell.statusLabel.text = "Pending"
                cell.statusLabel.textColor = UIColor(red: 204/255, green: 102/255, blue: 0/255, alpha: 1)
            }else{
                cell.statusLabel.text = "Authorised"
                cell.statusLabel.textColor = UIColor(red: 0/255, green: 179/255, blue: 60/255, alpha: 1)
            }
            
        }
        
//        cell.submitButton.tag = indexPath.row

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)")
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! PatientSideRequestCell
        let requestID = requests[indexPath.row]
        let status = selectedCell.statusLabel?.text
        
        if status == "Pending"{
            disableSubmitButton()
        }
        else if status == "Authorised"{
            enableSubmitButton()
        }

    }
    
    @IBAction func finaliseChangesClicked(_ sender: Any) {
        print("Finalise Changes Clicked")
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
