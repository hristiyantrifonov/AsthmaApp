//
//  InhalersInforView2ViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 5/7/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class InhalersInforView2ViewController: UIViewController {

    @IBOutlet weak var resource1: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleButton(button: resource1)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //https://www.asthma.org.uk/advice/inhalers-medicines-treatments/inhalers-and-spacers - Inhalers, Treatments, Medications
    
    @IBAction func resourceClicked(_ sender: Any) {
        openUrl(urlStr: "https://www.asthma.org.uk/advice/inhalers-medicines-treatments/inhalers-and-spacers")
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
