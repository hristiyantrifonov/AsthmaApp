//
//  ViewController.swift
//  MyAsthmaApp
//
//  Created by CCM2308 CCM2308 on 24/02/2018.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit
import CareKit
import ResearchKit

class RootViewController: UITabBarController {
    
    // MARK: Properties
    
    //pointer to the store from CarePlanStoreManager
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    fileprivate var careContentsViewController: OCKCareContentsViewController!
    
    fileprivate var insightsViewController: OCKInsightsViewController!
    
    fileprivate var connectViewController: OCKConnectViewController!
    
    fileprivate let carePlanData: CarePlanData
    
    //MARK: Initialisation
    
    required init?(coder aDecoder: NSCoder){
        
        carePlanData = CarePlanData(carePlanStore: storeManager.myCarePlanStore)
        
        super.init(coder: aDecoder)
        careContentsViewController = createCareContentsViewController()
        let insightsViewController = createInsightsViewController()
        let connectViewController = createConnectViewController()
        
        
        self.viewControllers = [
            UINavigationController(rootViewController: careContentsViewController),
            insightsViewController,
            connectViewController]
        
    }
    
    //MARK: Creating Controllers Methods
    
    fileprivate func createCareContentsViewController() -> OCKCareContentsViewController {
        /*
         Care Card actions generally are taken to improve or 
         maintain a condition
         */
        
        let viewController = OCKCareContentsViewController(carePlanStore: storeManager.myCarePlanStore)
        
        viewController.glyphType = .respiratoryHealth
        viewController.title = NSLocalizedString("Care Contents", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"carecard"), selectedImage: UIImage(named: "carecard-filled"))
        viewController.delegate = self;
        return viewController
    }
    
//    fileprivate func createSymptomTrackerViewController() -> OCKSymptomTrackerViewController {
//        
//        /*
//         Symptom and Measurement Tracker monitors progress
//         */
//        
//        let viewController = OCKSymptomTrackerViewController(carePlanStore:storeManager.myCarePlanStore)
//        
//        viewController.tabBarItem = UITabBarItem(title: "Symptom Tracker", image: UIImage(named: "symptoms"), selectedImage: UIImage.init(named: "symptoms-filled"))
//        viewController.title = "Symptom Tracker"
//        
//        return viewController
//    }
    
    fileprivate func createInsightsViewController() -> UINavigationController {
        let viewController = UIViewController()
        
        viewController.tabBarItem = UITabBarItem(title: "Insights", image: UIImage(named: "insights"), selectedImage: UIImage.init(named: "insights-filled"))
        viewController.title = "Insights"
        return UINavigationController(rootViewController: viewController)
    }
    
    fileprivate func createConnectViewController() -> UINavigationController {
        let viewController = UIViewController()
        
        viewController.tabBarItem = UITabBarItem(title: "Connect", image: UIImage(named: "connect"), selectedImage: UIImage.init(named: "connect-filled"))
        viewController.title = "Connect"
        return UINavigationController(rootViewController: viewController)
    }
    
}


//MARK: CareContentsViewController Delegate

extension RootViewController: OCKCareContentsViewControllerDelegate {
    
    //Tells when the user selects an activity on the view
    func careContentsViewController(_ viewController: OCKCareContentsViewController, didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
        
    }
}

//extension RootViewController: ORKTaskViewControllerDelegate{
//    
//}

//MARK: ConnectViewController Delegate

extension RootViewController: OCKConnectViewControllerDelegate {
    
}
