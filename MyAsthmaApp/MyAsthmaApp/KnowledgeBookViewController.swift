//
//  KnowledgeBookViewController.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/25/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

class KnowledgeBookViewController: UIViewController {

    @IBOutlet weak var tipsContainer: UIView!
    @IBOutlet weak var tipDescriptionLabel: UILabel!
    
    @IBOutlet weak var informationTableView: UITableView!
    
    let informationCells = ["Understanding My Asthma", "Asthma Triggers" ,"My Inhalers", "Asthma Assessments", "Asthma Attacks"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        informationTableView.delegate = self
        informationTableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension KnowledgeBookViewController: UITableViewDelegate{
    
}

extension KnowledgeBookViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informationCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath)
        
        cell.textLabel?.text = informationCells[indexPath.row]
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexOfSelectedRow = indexPath.row
        
        if indexOfSelectedRow == 0{
            performSegue(withIdentifier: "goToUnderstandAsthma", sender: self)
        }
        else if indexOfSelectedRow == 1{
            performSegue(withIdentifier: "goToAsthmaTriggers", sender: self)
        }
        else if indexOfSelectedRow == 2{
            performSegue(withIdentifier: "goToMyInhalers", sender: self)
        }
        else if indexOfSelectedRow == 3{
            performSegue(withIdentifier: "goToAsthmaAssessments", sender: self)
        }
        else if indexOfSelectedRow == 4{
            performSegue(withIdentifier: "goToAsthmaAttacks", sender: self)
        }
    }
    

    
    
}
