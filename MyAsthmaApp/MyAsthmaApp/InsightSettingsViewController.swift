//
//  InsightSettingsViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/24/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class InsightSettingsViewController: UIViewController {
    
    
    @IBOutlet weak var mainInsightPickerView: UIPickerView!
    @IBOutlet weak var firstMedicationPickerView: UIPickerView!
    @IBOutlet weak var secondMedicationPickerView: UIPickerView!
    
    //Picker View Delegate Classes
    let mainInsightPickerDelegate = MainInsightPickerDelegate()
    let firstMedicationPickerDelegate = FirstMedicationInsightPickerDelegate()
    let secondMedicationPickerDelegate = SecondMedicationInsightPickerDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainInsightPickerView.delegate = mainInsightPickerDelegate
        mainInsightPickerView.dataSource = mainInsightPickerDelegate
        firstMedicationPickerView.delegate = firstMedicationPickerDelegate
        firstMedicationPickerView.dataSource = firstMedicationPickerDelegate
        secondMedicationPickerView.delegate = secondMedicationPickerDelegate
        secondMedicationPickerView.dataSource = secondMedicationPickerDelegate
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateSettings(_ sender: Any) {
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
