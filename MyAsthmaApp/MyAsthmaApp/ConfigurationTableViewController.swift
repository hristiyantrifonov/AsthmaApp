//
//  ConfigurationTableViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/2/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class ConfigurationTableViewController: UITableViewController {
    
    let options = ["Add Activity", "Add Assessment", "Add Note"]
    let descriptions = ["Action for keeping up with the action plan",
                        "Assessment for evaluation of patient's condition state",
                        "Read-only note that will serve as reminder for the patient"]
    
    
    @IBOutlet var myTableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var success : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.separatorStyle = .none
        messageLabel.isHidden = success
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return options.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Cell configuration
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = options[indexPath.row]
        cell.detailTextLabel?.text = descriptions[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ROW IS CLICKED")
        let optionSelected = options[indexPath.row]
        
        if optionSelected == "Add Activity"{
            performSegue(withIdentifier: "goToAddActivities", sender: self)
        }else if optionSelected == "Add Assessment"{
            performSegue(withIdentifier: "goToAddAssessment", sender: self)
        }else if optionSelected == "Add Note" {
            performSegue(withIdentifier: "goToAddNote", sender: self)
        }
        
        
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Buttons Functionality Handling
    
    @IBAction func cancelConfigurationClicked(_ sender: Any) {
        let cancellationAlert = UIAlertController(title: "Exit Configuration", message: "Are you sure you want to exit configuration?", preferredStyle: UIAlertControllerStyle.alert)
        
        cancellationAlert.addAction(UIAlertAction(title: "Yes, exit!", style: .default, handler: {
            (action: UIAlertAction!) in
            
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        cancellationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action: UIAlertAction!) in
            
            cancellationAlert.dismiss(animated: true, completion: nil)
            
        }))
        
        present(cancellationAlert, animated: true, completion: nil)
    }
    
    @IBAction func finishConfigurationButtonClicked(_ sender: Any) {
        print("Finish Configuration requested")
    }
    
    
}
