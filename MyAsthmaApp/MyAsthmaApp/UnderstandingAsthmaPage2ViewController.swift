//
//  UnderstandingAsthmaPage2ViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/30/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class UnderstandingAsthmaPage2ViewController: UIViewController {

    @IBOutlet weak var firstResource: UIButton!
    @IBOutlet weak var secondResource: UIButton!
    @IBOutlet weak var thirdResource: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Styles for the view
        styleButton(button: firstResource)
        styleButton(button: secondResource)
        styleButton(button: thirdResource)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //https://www.nhs.uk/conditions/asthma/
    //https://www.asthma.org.uk/advice/nhs-care/
    //https://www.asthma.org.uk/advice/resources/helpline/
    
    @IBAction func asthmaOverviewClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.nhs.uk/conditions/asthma/")
    }
    
    
    @IBAction func asthmaNHSCareClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.asthma.org.uk/advice/nhs-care/")
    }
    
    
    @IBAction func asthmaHelplineClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.asthma.org.uk/advice/resources/helpline/")
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
