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
    
    var myCarePlanStore: OCKCarePlanStore
    
    weak var delegate: CarePlanStoreManagerDelegate?
    
    
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
        
        super.init()
        
        //Register this class to be notified of changes in the store
        myCarePlanStore.delegate = self
        
    }
}

extension CarePlanStoreManager: OCKCarePlanStoreDelegate{
    
}

protocol CarePlanStoreManagerDelegate: class {
    
    func carePlanStoreManager(_ manager: CarePlanStoreManager, didUpdateInsights insights: [OCKInsightItem])
    
}

