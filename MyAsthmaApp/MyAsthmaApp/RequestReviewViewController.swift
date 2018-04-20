//
//  RequestReviewViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/20/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class RequestReviewViewController: UIViewController {
    
    var requestID : String = ""
    var requestFields : NSDictionary!
    var patientFields : NSDictionary!

    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var requestDescriptionLabel: UILabel!
    
    
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var alreadyReviewedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Page for review of request \(requestID)")
        
        alreadyReviewedLabel.backgroundColor = .clear
        alreadyReviewedLabel.layer.cornerRadius = 5
        alreadyReviewedLabel.layer.borderWidth = 1
        alreadyReviewedLabel.layer.borderColor = UIColor.black.cgColor
        alreadyReviewedLabel.isHidden = true
        
        // Do any additional setup after loading the view.
        let patientForename = patientFields["Forename"] as! String
        let patientSurname = patientFields["Surname"] as! String
        let requestIdentifier = requestFields["Identifier"] as! String
        let requestParameterFields = requestFields["Parameters"] as! NSDictionary
        let authorisationStatus = requestFields["Authorised"] as! Bool
        let reviewStatus = requestFields["Reviewed"] as? Bool
        
        if reviewStatus != nil{
            if reviewStatus == true{
                approveButton.isHidden = true
                rejectButton.isHidden = true
                if authorisationStatus == true{
                    alreadyReviewedLabel.text = "This request has been APPROVED."
                }else{
                    alreadyReviewedLabel.text = "This request has been REJECTED."
                }
                alreadyReviewedLabel.isHidden = false
            }
        }
        
        identifierLabel.text = requestFields["Identifier"]! as? String ?? "uknown"
        patientNameLabel.text = (patientForename + " " + patientSurname)
//        requestDescriptionLabel.adjustsFontSizeToFitWidth = true
        requestDescriptionLabel.lineBreakMode = .byWordWrapping
        requestDescriptionLabel.numberOfLines = 0;
        
        if requestIdentifier == "End Activity"{
            let targetActivity = requestParameterFields["Target"] as! String
            let endDay = requestParameterFields["End-Day"] ?? 0
            let endMonth = requestParameterFields["End-Month"] ?? 0
            let endYear = requestParameterFields["End-Year"] ?? 0
            requestDescriptionLabel.text = "Patients requests to stop doing \(targetActivity.uppercased()) from \(endDay)/\(endMonth)/\(endYear) "

        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func decisionMade(_ sender: Any) {
        if ((sender as AnyObject).tag == 1){
            FirebaseManager().changeRequestAuthorisationStatus(requestID: requestID, authorisation: false)
            print("Rejected")
            
        }else {
            FirebaseManager().changeRequestAuthorisationStatus(requestID: requestID, authorisation: true)
            print("Approved")
        }
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
