//
//  AsthmaAssessmentsInfoViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 5/7/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class AsthmaAssessmentsInfoViewController: UIViewController {

    @IBOutlet weak var resource1: UIButton!
    @IBOutlet weak var resource2: UIButton!
    @IBOutlet weak var resource3: UIButton!
    @IBOutlet weak var resource4: UIButton!
    @IBOutlet weak var resource5: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleButton(button: resource1)
        styleButton(button: resource2)
        styleButton(button: resource3)
        styleButton(button: resource4)
        styleButton(button: resource5)
        
        self.title = "Asthma Assessment"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //https://www.asthma.org.uk/advice/manage-your-asthma - Manage your asthma
    
    //https://www.asthma.org.uk/advice/manage-your-asthma/action-plan/ - Your Asthma Action Plan
    
    //https://www.asthma.org.uk/advice/manage-your-asthma/action-plan/ - Get the best out of Asthma Review
    
    
    //https://www.asthma.org.uk/advice/manage-your-asthma/peak-flow/ - More on Peak Flow Test
    
    //https://www.youtube.com/watch?v=8tYutVUswH4 - taking peak flow reading (video)
    
    
    
    @IBAction func doneClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func manageAsthmaClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.asthma.org.uk/advice/manage-your-asthma")
    }
    
    @IBAction func yourAsthmaActionPlanClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.asthma.org.uk/advice/manage-your-asthma/action-plan/")
    }
    
    @IBAction func bestOutOfAsthmaReviewClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.asthma.org.uk/advice/manage-your-asthma/action-plan/")
    }
    
    @IBAction func moreOnPeakFlowTestClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.asthma.org.uk/advice/manage-your-asthma/peak-flow/")
    }
    
    @IBAction func takingReadingClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.youtube.com/watch?v=8tYutVUswH4")
    }
    
    
    //MARK: - Helper Functions
    func openUrl(urlStr:String!) {
        
        if let url = NSURL(string:urlStr) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    func styleButton(button: UIButton){
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }

}
