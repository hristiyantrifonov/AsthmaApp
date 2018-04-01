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
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        
        
        
        

        let mainTabViewController = createMainTabViewController()
        careContentsViewController = createCareContentsViewController()
        insightsViewController = createInsightsViewController()
        let connectViewController = createConnectViewController()


        self.viewControllers = [
            mainTabViewController,
            UINavigationController(rootViewController: careContentsViewController),
            UINavigationController(rootViewController: insightsViewController),
            connectViewController]
        
        storeManager.delegate = self
        
    }

    //MARK: Creating Controllers Methods

    fileprivate func createMainTabViewController() -> UINavigationController{
        var viewController = UIViewController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "main")

//        viewController.tabBarItem = UITabBarItem(title: "Main")
        viewController.title = "Main"

        return UINavigationController(rootViewController: viewController)
    }

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

    fileprivate func createInsightsViewController() -> OCKInsightsViewController {

        let activityType1: ActivityType = .bloodGlucose
        let activityType2: ActivityType = .backPain

        let widget1 = OCKPatientWidget.defaultWidget(withActivityIdentifier: activityType1.rawValue, tintColor: UIColor.blue)
        let widget2 = OCKPatientWidget.defaultWidget(withActivityIdentifier: activityType2.rawValue, tintColor: UIColor.blue)

        let viewController = OCKInsightsViewController(insightItems: storeManager.insights, patientWidgets: [widget1, widget2], thresholds: nil, store: storeManager.myCarePlanStore)

        viewController.tabBarItem = UITabBarItem(title: "Insights", image: UIImage(named: "insights"), selectedImage: UIImage.init(named: "insights-filled"))
        viewController.title = "Insights"
        
        return viewController
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

    /*
     Triggers when the user selects an assessment activity on the view
     */
    func careContentsViewController(_ viewController: OCKCareContentsViewController, didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
        print("Assessment activity clicked")

        //the enum identifier (i.e. bloodGlucose)
        guard let activityType = ActivityType(rawValue: assessmentEvent.activity.identifier) else { return }

        //The assessment object (i.e. BloodGlucose(activityType: MyAsthmaApp.ActivityType.bloodGlucose)
        guard let sampleAssessment = carePlanData.activityWithType(activityType) as? Assessment else { return }

        //Check the state - if not completed we will let the user edit itß
        guard assessmentEvent.state == .initial || assessmentEvent.state == .notCompleted ||
            (assessmentEvent.state == .completed && assessmentEvent.activity.resultResettable) else { return }

        //ORTaskViewController is the primary entry point for presentation Research kit views
        //We pass the task part of the Assessment object in order to display it on screen
        let taskViewController = ORKTaskViewController(task: sampleAssessment.task(), taskRun: nil)
        taskViewController.delegate = self

        present(taskViewController, animated: true, completion: nil)
    }
}

extension RootViewController: ORKTaskViewControllerDelegate {

    //Triggered when a task is finished
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        defer {
            dismiss(animated: true, completion: nil)
        }

        //Ensures task controller's reason for finishing is completion
        guard reason == .completed else { return }

        //Determine the event that was comleted
        guard let event = careContentsViewController.lastSelectedEvent,
            let activityType = ActivityType(rawValue: event.activity.identifier),
            let assessment = carePlanData.activityWithType(activityType) as? Assessment else { return }

        print("THE COMPLETED EVENT: \(event)")

        //Create 'OCKCarePlanEvenResult' object to be saved into the Care Plan Store
        let carePlanResultObject = assessment.buildResultForCarePlanEvent(event, taskResult: taskViewController.result)

        //If assessment compatible with HealthKit then create a sample to save in the HealthKit store
        if let healthBuilder = assessment as? HealthSampleBuilder {

            let sample = healthBuilder.buildSampleWithTaskResult(taskViewController.result)
            let sampleTypes: Set<HKSampleType> = [sample.sampleType]

            //HealthKit authorisation
            let healthStore = HKHealthStore()
            healthStore.requestAuthorization(toShare: sampleTypes, read: sampleTypes) {
                (success,error) in

                if !success {
                    print("Permission form HealthKit failed to be granted")
                    self.completeEvent(event, inStore: self.storeManager.myCarePlanStore, withResult: carePlanResultObject)
                    return
                }

                //Save the sample to the HealthKit Store
                healthStore.save(sample) {
                    (success, error) in

                    if success {
                        print("Sample successfully saved to HealthKit store")

                        //Use the sample to create an "EventResult" and save it to the CarePlanStore
                        let resultViaHealthKitSample = OCKCarePlanEventResult(quantitySample: sample, quantityStringFormatter: nil,
                                                                              display: healthBuilder.unit, displayUnitStringKey: healthBuilder.localizedUnitForSample(sample), userInfo: nil)

                        self.completeEvent(event, inStore: self.storeManager.myCarePlanStore, withResult: resultViaHealthKitSample)

                    }else{
                        //Go back to saving the simple Event Result to the CarePlanStore
                        self.completeEvent(event, inStore: self.storeManager.myCarePlanStore, withResult: carePlanResultObject)
                    }
                }
            }
        } else { //In the case it is not compatible with HealthKit
            completeEvent(event, inStore: storeManager.myCarePlanStore, withResult: carePlanResultObject)
        }

        dismiss(animated: true, completion: nil)
    }

    //Complete an event by changing it's state
    fileprivate func completeEvent(_ event: OCKCarePlanEvent, inStore store: OCKCarePlanStore, withResult result: OCKCarePlanEventResult) {
        store.update(event, with: result, state: .completed) {
            (success, _, error) in
            if !success {
                print(error!.localizedDescription)
            }
        }
    }
}

//MARK: ConnectViewController Delegate

extension RootViewController: OCKConnectViewControllerDelegate {

}

// MARK: CarePlanStoreManagerDelegate

extension RootViewController: CarePlanStoreManagerDelegate {

    /// Called when the `CarePlanStoreManager`'s insights are updated.
    func carePlanStoreManager(_ manager: CarePlanStoreManager, didUpdateInsights insights: [OCKInsightItem]) {
        // Update the insights view controller with the new insights.
        insightsViewController.items = insights
    }
}

