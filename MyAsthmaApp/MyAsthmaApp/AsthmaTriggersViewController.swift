//
//  AsthmaTriggersViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 5/7/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class AsthmaTriggersViewController: UIViewController {
    
    var strings : [String] = []
    @IBOutlet weak var bulletTextLabel: UILabel!
    
    @IBOutlet weak var resource1: UIButton!
    @IBOutlet weak var resource2: UIButton!
    @IBOutlet weak var resource3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Asthma Triggers"
        
        let bulletPoint1 = "Colds and flu";
        let bulletPoint2 = "Dust";
        let bulletPoint3 = "Contacts with pets";
        let bulletPoint4 = "Haze";
        let bulletPoint5 = "Cigarette smoke";
        let bulletPoint6 = "Exercise";
        let bulletPoint7 = "Pollen";
        let bulletPoint8 = "Weather"
        
        strings = [bulletPoint1, bulletPoint2, bulletPoint3, bulletPoint4, bulletPoint5, bulletPoint6, bulletPoint7, bulletPoint8]
        
        var fullString = ""
        
        for string: String in strings
        {
            let bulletPoint: String = "\u{2022}"
            let formattedString: String = "\(bulletPoint) \(string)\n"
            
            fullString = fullString + formattedString
        }
        
        bulletTextLabel.text = fullString
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //https://www.asthma.org.uk/advice/triggers/understanding/ - Understanding asthma triggers
    
    //https://www.asthma.org.uk/advice/triggers/ - More infor
    
    //https://www.asthma.org.uk/advice/understanding-asthma/types/occupational-asthma/ - Asthma at work
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
