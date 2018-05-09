//
//  AsthmaAttacksInfoViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 5/8/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class AsthmaAttacksInfoViewController: UIViewController {

    @IBOutlet weak var resource1: UIButton!
    @IBOutlet weak var resource2: UIButton!
    @IBOutlet weak var resource3: UIButton!
    @IBOutlet weak var resource4: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleButton(button: resource1)
        styleButton(button: resource2)
        styleButton(button: resource3)
        styleButton(button: resource4)
        
        self.title = "Asthma Attacks"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //https://www.youtube.com/watch?time_continue=4&v=CJFQSC5KoDM - What to do During an Attack (video)
    
    //https://www.asthma.org.uk/advice/manage-your-asthma/risk/ - Asthma Attack Risk Checker
    
    //https://www.asthma.org.uk/advice/manage-your-asthma/when-to-go-to-hospital/ - When to go to hospital
    
    
    //https://www.asthma.org.uk/advice/inhalers-medicines-treatments/inhalers-and-spacers/mart/ - Maintenance and Reliever Therapy (MART)
    
    
    @IBAction func doneClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func whatToDoDuringAttackClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.youtube.com/watch?time_continue=4&v=CJFQSC5KoDM")
    }
    
    @IBAction func riskCheckerClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.asthma.org.uk/advice/manage-your-asthma/risk/")
    }
    
    @IBAction func whenToGoToHospitalClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.asthma.org.uk/advice/manage-your-asthma/when-to-go-to-hospital/")
    }
    
    @IBAction func MARTClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.asthma.org.uk/advice/inhalers-medicines-treatments/inhalers-and-spacers/mart/")
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
