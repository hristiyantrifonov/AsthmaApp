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
import Firebase

class RootViewController: UITabBarController {

    // MARK: General Properties

    //pointer to the store from CarePlanStoreManager
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager

    fileprivate var careContentsViewController: OCKCareContentsViewController!

    fileprivate var insightsViewController: OCKInsightsViewController!

    fileprivate var connectViewController: OCKConnectViewController!
    
    //The array that is going to hold the contacts of the user
    var contacts: [OCKContact] = []
    
    let patientID = Auth.auth().currentUser?.uid
    
    fileprivate let carePlanData: CarePlanData
    

    //MARK: - Patient Object and Connect Message Items
    var patient : OCKPatient!
    let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
    let replyDateString = DateFormatter.localizedString(from: Date().addingTimeInterval(1000), dateStyle: .short, timeStyle: .short)
    var connectMessageItems = [OCKConnectMessageItem]()
    var contactsWithMessageItems = [OCKContact]()
    
    

    //MARK: Initialisation

    required init?(coder aDecoder: NSCoder){

        carePlanData = CarePlanData(carePlanStore: storeManager.myCarePlanStore)

        super.init(coder: aDecoder)
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        
        storeManager.delegate = self
        
        let mainTabViewController = createMainTabViewController()
        careContentsViewController = createCareContentsViewController()
        insightsViewController = createInsightsViewController()
        connectViewController = createConnectViewController()
        
        //Fetching all the contacts a patient has
        fetchPatientContacts()
        
        self.viewControllers = [
            mainTabViewController,
            UINavigationController(rootViewController: careContentsViewController),
            UINavigationController(rootViewController: insightsViewController),
            UINavigationController(rootViewController: connectViewController)]
        
    }

    //MARK: Creating Controllers Methods

    fileprivate func createMainTabViewController() -> UINavigationController{
        var viewController = UIViewController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "main")

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

    fileprivate func createConnectViewController() -> OCKConnectViewController {
        
        let viewController = OCKConnectViewController.init(contacts: nil, patient: patient)
        viewController.delegate = self
        viewController.dataSource = self
        
        viewController.tabBarItem = UITabBarItem(title: "Connect", image: UIImage(named: "connect"), selectedImage: UIImage.init(named: "connect-filled"))
        viewController.title = "Connect"
        return viewController
    }
    
    @IBAction func unwindToRoot(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? AddContactViewController{
            print("YEEES BABY")
            contacts.append(sourceVC.contact)
            print(contacts)
            self.connectViewController.contacts = self.contacts
        }
    }

}


//MARK: CareContentsViewController Delegate

extension RootViewController: OCKCareContentsViewControllerDelegate {

    /*
     Triggers when the user selects an assessment activity on the view
     */
    func careContentsViewController(_ viewController: OCKCareContentsViewController, didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
        print("Assessment activity clicked")
        print(assessmentEvent)
        print(assessmentEvent.activity)
        print(assessmentEvent.activity.identifier)
        print(assessmentEvent.activity.userInfo)
        print(assessmentEvent.activity.userInfo?["descriptions"])
        
        //Uses the options (i.e description, assessmentType, max and min values) we have save to the activity userInfor hash dictionary
        let taskOptions = assessmentEvent.activity.userInfo
        
        let taskBuilder = TaskBuilder()
        taskBuilder.assessmentActivityIdentifier = assessmentEvent.activity.identifier
        let task : ORKTask
        let taskViewController : ORKTaskViewController
        
        let assessmentTypeChosen = taskOptions!["assessmentType"]!
        print("Creating \(assessmentTypeChosen)")
        
        if assessmentTypeChosen as! String == "scaleAssessment"{
        
            taskViewController = ORKTaskViewController(task: taskBuilder.createScaleAssessmentTask(descriptionQuestion: taskOptions!["descriptions"]! as! String, maxValue: taskOptions!["maxValue"]! as! Int, minValue: taskOptions!["minValue"] as! Int, optionality: taskOptions!["optionality"]! as! Bool), taskRun: nil)
            taskViewController.delegate = self
            present(taskViewController, animated: true, completion: nil)
            
        }else if assessmentTypeChosen as! String == "quantityAssessment"{
            print("quantity")
            
           taskViewController = ORKTaskViewController(task: taskBuilder.createQuantityAssessmentTask(descriptionTitle: taskOptions!["descriptions"]! as! String, quantityTypeIdentifier: taskOptions!["quantityTypeIdentifier"]! as! HKQuantityTypeIdentifier, unitString: taskOptions!["unit"]! as! String, optionality: taskOptions!["optionality"]! as! Bool), taskRun: nil)
            taskViewController.delegate = self
            present(taskViewController, animated: true, completion: nil)
        }
        
        //Check the state - if not completed we will let the user edit itß
        guard assessmentEvent.state == .initial || assessmentEvent.state == .notCompleted ||
            (assessmentEvent.state == .completed && assessmentEvent.activity.resultResettable) else { return }
        
    }
}

extension RootViewController {
    
    func buildResultForCarePlanEvent(_ event: OCKCarePlanEvent, taskResult: ORKTaskResult, upperBound: Int = 10) -> OCKCarePlanEventResult {
        // Get the first result for the first step of the task result.
        guard let firstResult = taskResult.firstResult as? ORKStepResult, let stepResult = firstResult.results?.first else { fatalError("Unexepected task results") }
        
        // Determine what type of result should be saved.
        if let scaleResult = stepResult as? ORKScaleQuestionResult, let answer = scaleResult.scaleAnswer {
            return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: "of \(upperBound)", userInfo: nil, values: [answer])
        }
        else if let numericResult = stepResult as? ORKNumericQuestionResult, let answer = numericResult.numericAnswer {
            return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: numericResult.unit!, userInfo: nil, values: [answer])
        }
        
        fatalError("Unexpected task result type")
    }
    
    //Finds the contact list of the patient from the database and sets the Connect module
    func fetchPatientContacts(){
        
        FirebaseManager().findPatientContacts(patientID: self.patientID!) {
            (patientObject) in
            
            if patientObject != nil {
                
                let patientDict = patientObject as! NSDictionary
                
                let chosenName = patientDict["Name"] as! String
                let relation = patientDict["Relation"] as! String
                let phoneNumber = patientDict["Phone"] as! String
                let emailAddress = patientDict["Email"] as! String
                let type = patientDict["Contact-Type"] as! String
                var chosenContactType : OCKContactType = OCKContactType.careTeam
                if type == "Personal"{
                    chosenContactType = OCKContactType.personal
                }
                
                let contactObject = OCKContact(contactType: chosenContactType,
                                               name: chosenName,
                                               relation: relation,
                                               contactInfoItems: [OCKContactInfo.phone(phoneNumber), OCKContactInfo.sms(phoneNumber), OCKContactInfo.email(emailAddress)],
                                               tintColor: UIColor.blue,
                                               monogram: nil,
                                               image: nil)
                
                self.contacts.append(contactObject)
                
                self.patient = OCKPatient(identifier: "patient", carePlanStore: self.storeManager.myCarePlanStore, name: "John Doe", detailInfo: nil, careTeamContacts: self.contacts, tintColor: nil, monogram: "JD", image: nil, categories: nil, userInfo: ["Age": "21", "Gender": "M", "Phone":"888-555-5512"])
                
                self.connectViewController.contacts = self.contacts
                
                
            }else{
                print("Contact of another user")
            }
        }
        
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
        guard let event = careContentsViewController.lastSelectedEvent else { return }
        let activityType = event.activity.identifier
        var theActivity : OCKCarePlanActivity?
    
        storeManager.myCarePlanStore.activity(forIdentifier: activityType) {
            (success, activity, error) in
            
            if error != nil {
                return
            }else{
                print(activity)
                theActivity = activity
                print(theActivity)
                
            }
            
        }
        
        print("THE COMPLETED EVENT: \(event)")

        //Create 'OCKCarePlanEvenResult' object to be saved into the Care Plan Store
       let carePlanResultObject = buildResultForCarePlanEvent(event, taskResult: taskViewController.result, upperBound: event.activity.userInfo!["maxValue"] as! Int)

        //If assessment compatible with HealthKit then create a sample to save in the HealthKit store
        if let healthBuilder = theActivity as? HealthSampleBuilder {

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

// MARK: OCKConnectViewControllerDataSource

extension RootViewController: OCKConnectViewControllerDataSource {

    func connectViewControllerNumber(ofConnectMessageItems viewController: OCKConnectViewController, careTeamContact contact: OCKContact) -> Int {
        return connectMessageItems.count
    }

    func connectViewControllerCareTeamConnections(_ viewController: OCKConnectViewController) -> [OCKContact] {
        return contactsWithMessageItems
    }

    func connectViewController(_ viewController: OCKConnectViewController, connectMessageItemAt index: Int, careTeamContact contact: OCKContact) -> OCKConnectMessageItem {
        return connectMessageItems[index]
    }
}

// MARK: OCKConnectViewControllerDelegate

extension RootViewController: OCKConnectViewControllerDelegate {
    
    /// Called when the user taps a contact in the `OCKConnectViewController`.
    func connectViewController(_ connectViewController: OCKConnectViewController, didSelectShareButtonFor contact: OCKContact, presentationSourceView sourceView: UIView?) {
//        let document = sampleData.generateSampleDocument()
//        document.createPDFData {(data, error) in
//            let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
//            DispatchQueue.main.async {
//                self.present(activityViewController, animated: true, completion: nil)
//            }
        print("didSelectShareButtonFor \(contact.name)")
        
    }
    
    func connectViewController(_ connectViewController: OCKConnectViewController, titleForSharingCellFor contact: OCKContact) -> String? {
        
        let fullName = contact.name
        let indexOfWhiteSpace = contact.name.index(of: " ")
        var displayName = contact.name
        if indexOfWhiteSpace != nil {
            displayName = contact.name.substring(to: indexOfWhiteSpace!)
        }
        
        return "Share Care Data with \(displayName)"
    }
//
//        func connectViewController(_ viewController: OCKConnectViewController, didSendConnectMessage message: String, careTeamContact contact: OCKContact) {
//            let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
//            let connectMessage = OCKConnectMessageItem(messageType: .sent, name: sampleData.patient.name, message: message, dateString: dateString)
//            sampleData.connectMessageItems.append(connectMessage)
//        }
//    }
//
//    func connectViewController(_ viewController: OCKConnectViewController, didSendConnectMessage message: String, careTeamContact contact: OCKContact) {
//        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
//        let connectMessage = OCKConnectMessageItem(messageType: .sent, name: sampleData.patient.name, message: message, dateString: dateString)
//        sampleData.connectMessageItems.append(connectMessage)
//    }
}

// MARK: CarePlanStoreManagerDelegate

extension RootViewController: CarePlanStoreManagerDelegate {

    /// Called when the `CarePlanStoreManager`'s insights are updated.
    func carePlanStoreManager(_ manager: CarePlanStoreManager, didUpdateInsights insights: [OCKInsightItem]) {
        // Update the insights view controller with the new insights.
        insightsViewController.items = insights
    }
}

