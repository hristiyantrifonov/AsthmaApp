//
//  CarePlanStoreManager.swift
//  MyAsthmaApp
//
//  Created by CCM2308 CCM2308 on 25/02/2018.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import Foundation
import CareKit

class CarePlanStoreManager: NSObject {
    
    // MARK: Properties
    
    //allows access from anywhere in the AsthmaApp
    static var sharedCarePlanStoreManager = CarePlanStoreManager()
    
    weak var delegate: CarePlanStoreManagerDelegate?
    
    let myCarePlanStore: OCKCarePlanStore
    
    var insights: [OCKInsightItem] {
        return insightsBuilder.insights
    }
    
    fileprivate let insightsBuilder: InsightsBuilder
    
    //MARK: Initialisation
    
    fileprivate override init(){
        //Determine the file URL for the store
        let searchPaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let applicationSupportPath = searchPaths[0]
        let myDirectoryURL = URL(fileURLWithPath: applicationSupportPath)
        
        if !FileManager.default.fileExists(atPath: myDirectoryURL.absoluteString, isDirectory: nil) {
            try! FileManager.default.createDirectory(at: myDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        //Create the actual Store
        myCarePlanStore = OCKCarePlanStore(persistenceDirectoryURL: myDirectoryURL)
        
        //Create the InsightBuilder to build insights based on store's data
        insightsBuilder = InsightsBuilder(carePlanStore: myCarePlanStore)
        
        super.init()
        
        //Register this class to be notified of changes in the store
        myCarePlanStore.delegate = self
        
        //Start to build the initial array of Insights
        updateInsights()
        
    }
    
    func updateInsights() {
        print("LO PASE BIEN")
        insightsBuilder.updateInsights { [weak self] completed, newInsights in
            // If new insights have been created, notifiy the delegate.
            guard let storeManager = self, let newInsights = newInsights , completed else { return }
            storeManager.delegate?.carePlanStoreManager(storeManager, didUpdateInsights: newInsights)
        }
    }
    
}

extension CarePlanStoreManager: OCKCarePlanStoreDelegate{
    
    //Called everytime the activities change
    func carePlanStoreActivityListDidChange(_ store: OCKCarePlanStore) {
        updateInsights()
    }
    
    //Called everytime a single event changes
    func carePlanStore(_ store: OCKCarePlanStore, didReceiveUpdateOf event: OCKCarePlanEvent) {
        updateInsights()
        
        let triggeredThresholds = event.evaluateNumericThresholds()
        if triggeredThresholds.count != 0 {
            for thresholdArray in triggeredThresholds {
                for threshold in thresholdArray {
                    NSLog("Threshold triggered on event \(event.occurrenceIndexOfDay) of \(event.date) for activity \(event.activity.identifier) with title:\n\(threshold.title!)")
                }
            }
        }
    }
}

protocol CarePlanStoreManagerDelegate: class {
    
    func carePlanStoreManager(_ manager: CarePlanStoreManager, didUpdateInsights insights: [OCKInsightItem])
    
}

extension CarePlanStoreManager {
    
    typealias Value = (Any?) -> Void
    
    func findActivityUnit(identifier: String, completion: @escaping Value ) {
        
        var unitToBeReturned = "a"
        
        myCarePlanStore.activity(forIdentifier: identifier) { (success, activity, error) in
            guard success else {
                fatalError(error!.localizedDescription)
            }
            
            if let unit = activity?.userInfo!["unit"]{
                print("molq")
                if unit as! String == ""{
                    unitToBeReturned = activity?.identifier as! String
                    completion(unitToBeReturned)
                }else{
                    unitToBeReturned = unit as! String
                    completion(unitToBeReturned)
                }
            }
    
        }
        
    }
    
}
