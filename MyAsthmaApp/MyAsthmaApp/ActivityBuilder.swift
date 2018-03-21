//
//  ActivityClass.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/21/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit

class ActivityBuilder {
    
    //Properties
    
    var startDate : DateComponents
    var title : String?
    var summary : String?
    var instructions : String?
    var groupIdentifier: String?
    
    var identifier : String?
    
    var activity : OCKCarePlanActivity?
    
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
    
    func createActivity(schedule: OCKCareSchedule, optionality: Bool) -> OCKCarePlanActivity {
        
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
    
}

//
//let activityType: ActivityType = .takeNurofen
//
//func carePlanActivity() -> OCKCarePlanActivity {
//    // Create a weekly schedule.
//    let startDate = DateComponents(year: 2018, month: 01, day: 01)
//    let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [2, 3, 3, 1, 3, 1, 2])
//    
//    // Get the localized strings to use for the activity.
//    let title = NSLocalizedString("TakeNurofen", comment: "")
//    let summary = NSLocalizedString("15 mins", comment: "")
//    let instructions = NSLocalizedString("Take a leisurely walk.", comment: "")
//    
//    // Create the intervention activity.
//    let activity = OCKCarePlanActivity.intervention(
//        withIdentifier: activityType.rawValue,
//        groupIdentifier: "Medications",
//        title: title,
//        text: summary,
//        tintColor: UIColor.purple,
//        instructions: instructions,
//        imageURL: nil,
//        schedule: schedule,
//        userInfo: nil,
//        optional: false
//    )
//    
//    return activity
//}

