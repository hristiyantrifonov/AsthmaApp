//
//  PopUpDoctorCredentialsViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/2/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class PopUpDoctorCredentialsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAnimate()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logOnClicked(_ sender: Any) {
        performSegue(withIdentifier: "goToConfiguration", sender: self)
        self.view.removeFromSuperview()
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        removeAnimate()
    }
    
    
    // MARK: - Animation Functions
    
    //For better user interface we animate the pop-up showing and closing
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
}
