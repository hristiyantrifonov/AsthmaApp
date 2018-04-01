//
//  AddActivityViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/30/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class AddActivityViewController: UIViewController {
    
    //The Interface Colors
    let greenDesignColor = UIColor(red:40/255, green:164/255, blue:40/255, alpha: 1)
    
    //Pointer to the shared database
//    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    var optionalChosen = false
//    @IBOutlet weak var newGroupButton: UIButton!
    
    //The form fields
    
//    @IBOutlet weak var optionalityButtonPanel: UIView!
//    @IBOutlet weak var optionalityButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        newGroupButton.backgroundColor = .clear
//        newGroupButton.layer.cornerRadius = 5
//        newGroupButton.layer.borderWidth = 1.5
//        newGroupButton.layer.borderColor = UIColor.black.cgColor
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func scheduleItemClicked(_ sender: UITextField!) {
//        print(sender.tag)
//    }
    
    
    //The Optionality button style changes to green when selected and vice-versa
//    @IBAction func optinalityChosen(_ sender: Any) {
//        print("Optionality Clicked")
//        optionalChosen = !optionalChosen //change the optionality bool
//        
//        if optionalChosen{
//            self.optionalityButtonPanel.layer.borderWidth = 3.5
//            self.optionalityButtonPanel.layer.borderColor = greenDesignColor.cgColor
//            
//            optionalityButton.setTitle("Optionality Chosen!", for: .normal)
//        }else{
//            self.optionalityButtonPanel.layer.borderColor = UIColor.clear.cgColor
//            optionalityButton.setTitle("Optional Activity?", for: .normal)
//        }
//        
//    }
    
//    @IBAction func doneButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)

        dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func addAnotherButtonClicked(_ sender: Any) {
    }
    
}
