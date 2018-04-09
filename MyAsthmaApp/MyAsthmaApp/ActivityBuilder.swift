//
//  ActivityClass.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/21/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit

class ActivityBuilder {
    
    //MARK: - Properties
    
    var startDate : DateComponents
    var title : String?
    var summary : String?
    var instructions : String?
    var groupIdentifier: String?
    
    var identifier : String?
    
    var activity : OCKCarePlanActivity?
    
    //MARK: - Initialisations
    //Set-up date during initialisation
    init() {
        let date = Date()
        let calendar = Calendar.current
        
        let currentYear = calendar.component(.year, from: date)
        let currentMonth = calendar.component(.month, from: date)
        let currentDay = calendar.component(.day, from: date)
        
        startDate = DateComponents(year: currentYear, month: currentMonth, day: currentDay)
        print("Creating activity with startDate = \(startDate)")
        
    }
    
    //MARK: - Constructor Methods
    
    //groupIdentifier, title, summary, instuctions all-in-one object
    func setActivityDefinitions(title: String, summary: String, instructions: String, groupIdentifier: String){
        self.title = NSLocalizedString(title, comment: "")
        self.summary = NSLocalizedString(summary, comment: "")
        self.instructions = NSLocalizedString(instructions, comment: "")
        self.groupIdentifier = groupIdentifier
    }
    
    //Method to prepare the chosen occurences for input for creating activities
    func constructSchedule(occurencesArray: [Int]) -> OCKCareSchedule {
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: occurencesArray as [NSNumber])
        
        return schedule
    }
    
    
    func generateTypeIdentifier(){
        
        //remove all the whitespace and newlines from the title string
        if let processed = self.title?.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression) {
            self.identifier = processed.lowercased() //lowercase the whole word
            print("Identifier - \(self.identifier ?? "error")")
        }
        else{
            print("Error while generating type activity identifier...")
        }
        
        
    }
    
    //MARK: - Activities Creation Methods
    
    func createInterventionActivity(schedule: OCKCareSchedule, optionality: Bool) -> OCKCarePlanActivity {
        
        //for creating random colors...
        let randomRedValue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let randomGreenValue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let randomBlueValue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        generateTypeIdentifier()
        
        self.activity = OCKCarePlanActivity.intervention(
            withIdentifier: self.identifier!,
            groupIdentifier: self.groupIdentifier,
            title: self.title!,
            text: self.summary,
            tintColor: UIColor.init(red: randomRedValue, green: randomGreenValue, blue: randomBlueValue, alpha: 0.8),
            instructions: self.instructions,
            imageURL: nil,
            schedule: schedule,
            userInfo: nil,
            optional: optionality
        )
        
        return self.activity!
    }
    
    func createAssessmentActivity(assessmentType: AssessmentType, assessmentDescription: String,
                                  maxValue: Int? = 0 , minValue: Int? = 0,
                                  quantityTypeIdentifier: HKQuantityTypeIdentifier? = HKQuantityTypeIdentifier.respiratoryRate, unit: String? = "", optionality: Bool) -> OCKCarePlanActivity {
        
        generateTypeIdentifier()
        
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        self.activity = OCKCarePlanActivity.assessment(
            withIdentifier: self.identifier!,
            groupIdentifier: "Assessment",
            title: self.title!,
            text: self.summary!,
            tintColor: UIColor.blue,
            resultResettable: false,
            schedule: schedule,
            userInfo: [AnyHashable("assessmentType") : "\(assessmentType)", AnyHashable("descriptions") : assessmentDescription, AnyHashable("maxValue") : maxValue,
                       AnyHashable("minValue") : minValue, AnyHashable("quantityTypeIdentifier") : quantityTypeIdentifier, AnyHashable("unit") : unit,
                       AnyHashable("optionality") : optionality],
            optional: false
        )
        
        return self.activity!
    }
    
    func createNoteActivity() -> OCKCarePlanActivity {
        
        generateTypeIdentifier()
        
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        self.activity = OCKCarePlanActivity.readOnly(
            withIdentifier: self.identifier!,
            groupIdentifier: nil,
            title: self.title!,
            text: self.summary,
            instructions: self.instructions,
            imageURL: nil,
            schedule: schedule,
            userInfo: nil)
        
        return self.activity!
    }
    
    
}
