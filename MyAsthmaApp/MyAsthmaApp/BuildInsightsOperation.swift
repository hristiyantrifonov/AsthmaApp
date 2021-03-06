//
//  BuildInsightsOperation.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/16/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit

class BuildInsightsOperation: Operation {
    
    //MARK: - Properties
    var mainSettingsIdentifiers : [String]?
    var firstSettingMedicationsIdentifiers : [String]?
    var secondSettingMedicationsIdentifiers : [String]?
    var thirdSettingMedicationsIdentifiers : [String]?
    
    var settingOneEvents: DailyEvents?
    var settingOneFirstSubsettingEvents : DailyEvents?
    var settingOneSecondSubsettingEvents : DailyEvents?
    
    var settingTwoEvents: DailyEvents?
    var settingTwoFirstSubsettingEvents : DailyEvents?
    var settingTwoSecondSubsettingEvents : DailyEvents?
    
    var settingThreeEvents: DailyEvents?
    var settingThreeFirstSubsettingEvents : DailyEvents?
    var settingThreeSecondSubsettingEvents : DailyEvents?
    
    fileprivate(set) var insights = [OCKInsightItem.noInsightsToShowMessage()]   //we start off with array of empty insights
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    //MARK: - The Operation
    
    override func main() {
        
        //If operation cancelled we exit
        guard !isCancelled else { return }
        
        //Create an array of insights
        var newInsights = [OCKInsightItem]()
        
        if let insight = createCarePlanAdherenceInsight() {
            newInsights.append(insight)
        }
        
        if let insight = createFirstSettingInsight() {
            newInsights.append(insight)
        }
        
        if let insight2 = createSecondSettingInsight(){
            newInsights.append(insight2)
        }
        
        if let insight3 = createThirdSettingInsight(){
            newInsights.append(insight3)
        }
        
        for i in newInsights{
            print(i)
        }
        
        //Store any new insights that were created
        if !newInsights.isEmpty {
            insights = newInsights
        }
        
    }
    
    //TODO - The CarePlan Adherence part of the Insights window
    
    func createCarePlanAdherenceInsight() -> OCKInsightItem? {
        // Make sure there are events to parse.
        guard let settingOneEvents = settingOneEvents,
            let settingOneFirstSubsettingEvents = settingOneFirstSubsettingEvents,
            let settingOneSecondSubsettingEvents = settingOneSecondSubsettingEvents,
            let settingTwoEvents = settingTwoEvents,
            let settingTwoFirstSubsettingEvents = settingTwoFirstSubsettingEvents,
            let settingTwoSecondSubsettingEvents = settingTwoSecondSubsettingEvents,
            let settingThreeEvents = settingThreeEvents,
            let settingThreeFirstSubsettingEvents = settingThreeFirstSubsettingEvents,
            let settingThreeSecondSubsettingEvents = settingThreeSecondSubsettingEvents
            else { return nil }
        
        // Determine the start date for the previous week.
        let calendar = Calendar.current
        let now = Date()
        
        var components = DateComponents()
        components.day = -7
        let startDate = calendar.weekDatesForDate(calendar.date(byAdding: components as DateComponents, to: now)!).start
        
        var totalEventCount = 0
        var completedEventCount = 0
        
        for offset in 0..<7 {
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            
            for events in [settingOneEvents, settingOneFirstSubsettingEvents, settingOneSecondSubsettingEvents, settingTwoEvents, settingTwoFirstSubsettingEvents, settingTwoSecondSubsettingEvents, settingThreeEvents, settingThreeFirstSubsettingEvents, settingThreeSecondSubsettingEvents] {
                let eventsForDay = events[dayComponents]
                
                totalEventCount += eventsForDay.count
                
                for event in eventsForDay {
                    if event.state == .completed {
                        completedEventCount += 1
                    }
                }
            }
        }
        
        guard totalEventCount > 0 else { return nil }
        
        // Calculate the percentage of completed events.
        let carePlanAdherence = Float(completedEventCount) / Float(totalEventCount)
        
        // Create an `OCKMessageItem` describing medical adherence.
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        let formattedAdherence = percentageFormatter.string(from: NSNumber(value: carePlanAdherence))!
        
        let insight = OCKMessageItem(title: "Care Plan Adherence", text: "Your care plan adherence was \(formattedAdherence) last week.",
            tintColor: UIColor.init(red: 95/255, green: 140/255, blue: 123/255, alpha: 0.9), messageType: .tip)
        
        return insight
    }
    
    
    
    func createFirstSettingInsight() -> OCKInsightItem? {
        
        //Make sure there are events to begin with (usually it is sensible to do couples - pain & medication)
        //As it is in the sample app - (the back pain insight keeps track of the pain and the amount of Ibuprofen patient is taking)
        guard let settingOneEvents = settingOneEvents else { return nil }
        
        /* Medications/Subsettings declaration */
        let subsettingOneEvents = settingOneFirstSubsettingEvents
    
        let subsettingTwoEvents = settingOneSecondSubsettingEvents
        
        let mainSettingIdentifier = mainSettingsIdentifiers?[0]
        let myGroup = DispatchGroup()
        
        myGroup.enter()
        var mainSettingUnit = ""
        
        storeManager.findActivityUnit(identifier: mainSettingIdentifier!, completion: { unit in
            
            mainSettingUnit = unit as! String
            myGroup.leave()
        })
        
        //The date to start pain/medication comparison from
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = -7
        
        let startDate = calendar.date(byAdding: components as DateComponents, to: Date())! //set start 7 days back from today
        
        //Formatters for the data
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "E"
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: shortDateFormatter.locale)
        
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        
        
        /*
         Value Array and Chart Labels Declaration
         */
        var firstMedicationValues = [Float]()
        var firstMedicationLabels = [String]()
        var firstMedicationBarSeries : OCKBarSeries?
        
        var secondMedicationValues = [Float]()
        var secondMedicationLabels = [String]()
        var secondMedicationBarSeries : OCKBarSeries?
        
        var assessmentValues = [Int]()
        var assessmentLabels = [String]()
        var axisTitles = [String]()
        var axisSubtitles = [String]()
        
        /*
         Loop through the seven days and obtain pain score for each day
         */
        for offset in 0..<7 {
            
            //Determining the day
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)! //2018-03-10, 2018-03-11 and so on...
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate) //turns it into - era: 1 year: 2018 month: 3 day: 10 isLeapMonth: false
            
            if let result = settingOneEvents[dayComponents].first?.result, let score = Int(result.valueString), score > 0 {
                assessmentValues.append(score)
                assessmentLabels.append(result.valueString)
            }else{
                assessmentValues.append(0)
                assessmentLabels.append(NSLocalizedString("N/A", comment: ""))
            }
            
            // Store the medication adherance value for the current day.
            if subsettingOneEvents != nil {
                let firstMedicationEventsForDay = subsettingOneEvents![dayComponents]
                if let medicationPercentage = percentageEventsCompleted(firstMedicationEventsForDay) , medicationPercentage > 0.0 {
                    // Scale the adherance to the same 0-10 scale as pain values.
                    let scaledMedication = medicationPercentage * (Float(assessmentValues.max()!))
                    
                    firstMedicationValues.append(scaledMedication)
                    firstMedicationLabels.append(percentageFormatter.string(from: medicationPercentage as! NSNumber)!)

                    
                }
                else {
                    firstMedicationValues.append(0.0)
                    firstMedicationLabels.append(percentageFormatter.string(from: 0)!)
                }

                firstMedicationBarSeries = OCKBarSeries(title: firstSettingMedicationsIdentifiers?[0] ?? "Unknown", values: firstMedicationValues as [NSNumber], valueLabels: firstMedicationLabels, tintColor: UIColor.darkGray)
            }
            
            if subsettingTwoEvents != nil {
                let secondMedicationEventsForDay = subsettingTwoEvents![dayComponents]
                if let medicationPercentage = percentageEventsCompleted(secondMedicationEventsForDay) , medicationPercentage > 0.0 {
                    // Scale the adherance to the same 0-10 scale as pain values.
                    let scaledMedication = medicationPercentage * (Float(assessmentValues.max()!))
                    
                    secondMedicationValues.append(scaledMedication)
                    secondMedicationLabels.append(percentageFormatter.string(from: medicationPercentage as! NSNumber)!)
                    
                }
                else {
                    secondMedicationValues.append(0.0)
                    secondMedicationLabels.append(percentageFormatter.string(from: 0)!)
                }
                
                secondMedicationBarSeries = OCKBarSeries(title: firstSettingMedicationsIdentifiers?[1] ?? "Unknown", values: secondMedicationValues as [NSNumber], valueLabels: secondMedicationLabels, tintColor: UIColor.brown)
            }
            
            
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate)) //i.e Sat, Sun, Mon...
            axisSubtitles.append(shortDateFormatter.string(from: dayDate)) //i.e. 3-10, 3-11, 3-12
        }
        
        /*
         Displaying - Create the bar chart
         */
        
        //bars for each set of data
        let painBarSeries = OCKBarSeries(title: mainSettingUnit, values: assessmentValues as [NSNumber], valueLabels: assessmentLabels,
                                         tintColor: UIColor.init(red: 95/255, green: 140/255, blue: 123/255, alpha: 0.9))
        
        
        var insightDataSeries : [OCKBarSeries]
        
        //switch deciding which bar series to print
        if (firstMedicationBarSeries == nil && secondMedicationBarSeries == nil) {
            insightDataSeries = [painBarSeries]
        }else if (secondMedicationBarSeries == nil){
            insightDataSeries = [painBarSeries,firstMedicationBarSeries!]
        }else if (firstMedicationBarSeries == nil){
            insightDataSeries = [painBarSeries,secondMedicationBarSeries!]
        }else{
            insightDataSeries = [painBarSeries, firstMedicationBarSeries!, secondMedicationBarSeries!]
        }
        
        let chart = OCKBarChart(title: mainSettingIdentifier,
                                text: nil,
                                tintColor: UIColor.blue,
                                axisTitles: axisTitles,
                                axisSubtitles: axisSubtitles,
                                dataSeries: insightDataSeries)
        
        return chart
    }
    
    
    func createSecondSettingInsight() -> OCKInsightItem? {
        
        //Make sure there are events to begin with (usually it is sensible to do couples - pain & medication)
        //As it is in the sample app - (the back pain insight keeps track of the pain and the amount of Ibuprofen patient is taking)
        guard let settingTwoEvents = settingTwoEvents else { return nil }
        
        /* Medications/Subsettings declaration */
        let subsettingOneEvents = settingTwoFirstSubsettingEvents
        
        let subsettingTwoEvents = settingTwoSecondSubsettingEvents
        
        let mainSettingIdentifier = mainSettingsIdentifiers?[1]
        let myGroup = DispatchGroup()
        
        myGroup.enter()
        var mainSettingUnit = ""
        
        storeManager.findActivityUnit(identifier: mainSettingIdentifier!, completion: { unit in
            
            mainSettingUnit = unit as! String
            myGroup.leave()
        })
        
        //The date to start pain/medication comparison from
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = 0
        
        let startDate = calendar.date(byAdding: components as DateComponents, to: Date())! //set start 7 days back from today
        
        //Formatters for the data
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "E"
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: shortDateFormatter.locale)
        
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        
        /*
         Value Array and Chart Labels Declaration
         */
        var firstMedicationValues = [Float]()
        var firstMedicationLabels = [String]()
        var firstMedicationBarSeries : OCKBarSeries?
        
        var secondMedicationValues = [Float]()
        var secondMedicationLabels = [String]()
        var secondMedicationBarSeries : OCKBarSeries?
        
        var assessmentValues = [Int]()
        var assessmentLabels = [String]()
        var axisTitles = [String]()
        var axisSubtitles = [String]()
        
        /*
         Loop through the seven days and obtain pain score for each day
         */
        
        for offset in 0..<7 {
            
            //Determining the day
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)! //2018-03-10, 2018-03-11 and so on...
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate) //turns it into - era: 1 year: 2018 month: 3 day: 10 isLeapMonth: false
            
            if let result = settingTwoEvents[dayComponents].first?.result, let score = Int(result.valueString), score > 0 {
                assessmentValues.append(score)
                assessmentLabels.append(result.valueString)
            }else{
                assessmentValues.append(0)
                assessmentLabels.append(NSLocalizedString("N/A", comment: ""))
            }
            
            // Store the medication adherance value for the current day.
            if subsettingOneEvents != nil {
                let firstMedicationEventsForDay = subsettingOneEvents![dayComponents]
                if let medicationPercentage = percentageEventsCompleted(firstMedicationEventsForDay) , medicationPercentage > 0.0 {
                    // Scale the adherance to the same 0-10 scale as pain values.
                    let scaledMedication = medicationPercentage * (Float(assessmentValues.max()!))
                    
                    firstMedicationValues.append(scaledMedication)
                    firstMedicationLabels.append(percentageFormatter.string(from: medicationPercentage as! NSNumber)!)
                }
                else {
                    firstMedicationValues.append(0.0)
                    firstMedicationLabels.append(percentageFormatter.string(from: 0)!)
                }
                
                firstMedicationBarSeries = OCKBarSeries(title: secondSettingMedicationsIdentifiers?[0] ?? "Unknown", values: firstMedicationValues as [NSNumber], valueLabels: firstMedicationLabels, tintColor: UIColor(red: 128/255, green: 108/255, blue: 67/255, alpha: 1.0))
            }
            
            if subsettingTwoEvents != nil {
                let secondMedicationEventsForDay = subsettingTwoEvents![dayComponents]
                if let medicationPercentage = percentageEventsCompleted(secondMedicationEventsForDay) , medicationPercentage > 0.0 {
                    // Scale the adherance to the same 0-10 scale as pain values.
                    let scaledMedication = medicationPercentage * (Float(assessmentValues.max()!))
                    
                    secondMedicationValues.append(scaledMedication)
//                    secondMedicationLabels.append(String(secondMedicationEventsForDay.filter({$0.state == .completed}).count))
                    secondMedicationLabels.append(percentageFormatter.string(from: medicationPercentage as! NSNumber)!)
                }
                else {
                    secondMedicationValues.append(0.0)
                    secondMedicationLabels.append(percentageFormatter.string(from: 0)!)
                }
                
                secondMedicationBarSeries = OCKBarSeries(title: secondSettingMedicationsIdentifiers?[1] ?? "Unknown", values: secondMedicationValues as [NSNumber], valueLabels: secondMedicationLabels, tintColor: UIColor(red: 150/255, green: 144/255, blue: 147/255, alpha: 1.0))
            }
            
            
            
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate)) //i.e Sat, Sun, Mon...
            axisSubtitles.append(shortDateFormatter.string(from: dayDate)) //i.e. 3-10, 3-11, 3-12
        }
        
        /*
         Displaying - Create the bar chart
         */
        
        //bars for each set of data
        let painBarSeries = OCKBarSeries(title: mainSettingUnit, values: assessmentValues as [NSNumber], valueLabels: assessmentLabels, tintColor: UIColor(red: 180/255, green: 145/255, blue: 146/255, alpha: 1.0))
        
        var insightDataSeries : [OCKBarSeries]
        
        //switch deciding which bar series to print
        if (firstMedicationBarSeries == nil && secondMedicationBarSeries == nil) {
            insightDataSeries = [painBarSeries]
        }else if (secondMedicationBarSeries == nil){
            insightDataSeries = [painBarSeries,firstMedicationBarSeries!]
        }else if (firstMedicationBarSeries == nil){
            insightDataSeries = [painBarSeries,secondMedicationBarSeries!]
        }else{
            insightDataSeries = [painBarSeries, firstMedicationBarSeries!, secondMedicationBarSeries!]
        }
        
        let chart = OCKBarChart(title: mainSettingIdentifier,
                                text: nil,
                                tintColor: UIColor.blue,
                                axisTitles: axisTitles,
                                axisSubtitles: axisSubtitles,
                                dataSeries: insightDataSeries)
        
        return chart
    }
    
    func createThirdSettingInsight() -> OCKInsightItem? {
        
        //Make sure there are events to begin with (usually it is sensible to do couples - pain & medication)
        //As it is in the sample app - (the back pain insight keeps track of the pain and the amount of Ibuprofen patient is taking)
        guard let settingThreeEvents = settingThreeEvents else { return nil }
        
        /* Medications/Subsettings declaration */
        let subsettingOneEvents = settingThreeFirstSubsettingEvents
        
        let subsettingTwoEvents = settingThreeSecondSubsettingEvents
        
        let mainSettingIdentifier = mainSettingsIdentifiers?[2]
        let myGroup = DispatchGroup()
        
        myGroup.enter()
        var mainSettingUnit = ""
        
        storeManager.findActivityUnit(identifier: mainSettingIdentifier!, completion: { unit in
            
            mainSettingUnit = unit as! String
            myGroup.leave()
        })
        
        //The date to start pain/medication comparison from
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = -7
        
        let startDate = calendar.date(byAdding: components as DateComponents, to: Date())! //set start 7 days back from today
        
        //Formatters for the data
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "E"
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: shortDateFormatter.locale)
        
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        
        /*
         Value Array and Chart Labels Declaration
         */
        var firstMedicationValues = [Float]()
        var firstMedicationLabels = [String]()
        var firstMedicationBarSeries : OCKBarSeries?
        
        var secondMedicationValues = [Float]()
        var secondMedicationLabels = [String]()
        var secondMedicationBarSeries : OCKBarSeries?
        
        var assessmentValues = [Int]()
        var assessmentLabels = [String]()
        var axisTitles = [String]()
        var axisSubtitles = [String]()
        
        /*
         Loop through the seven days and obtain pain score for each day
         */
        
        for offset in 0..<7 {
            
            //Determining the day
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)! //2018-03-10, 2018-03-11 and so on...
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate) //turns it into - era: 1 year: 2018 month: 3 day: 10 isLeapMonth: false
            
            if let result = settingThreeEvents[dayComponents].first?.result, let score = Int(result.valueString), score > 0 {
                assessmentValues.append(score)
                assessmentLabels.append(result.valueString)
            }else{
                assessmentValues.append(0)
                assessmentLabels.append(NSLocalizedString("N/A", comment: ""))
            }
            
            // Store the medication adherance value for the current day.
            if subsettingOneEvents != nil {
                let firstMedicationEventsForDay = subsettingOneEvents![dayComponents]
                if let medicationPercentage = percentageEventsCompleted(firstMedicationEventsForDay) , medicationPercentage > 0.0 {
                    // Scale the adherance to the same 0-10 scale as pain values.
                    let scaledMedication = medicationPercentage * (Float(assessmentValues.max()!))
                    
                    firstMedicationValues.append(scaledMedication)
                    firstMedicationLabels.append(percentageFormatter.string(from: medicationPercentage as! NSNumber)!)
                    
                }
                else {
                    firstMedicationValues.append(0.0)
                    firstMedicationLabels.append(percentageFormatter.string(from: 0)!)
                }
                
                firstMedicationBarSeries = OCKBarSeries(title: thirdSettingMedicationsIdentifiers?[0] ?? "Unknown", values: firstMedicationValues as [NSNumber], valueLabels: firstMedicationLabels, tintColor: UIColor(red: 179/255, green: 188/255, blue: 146/255, alpha: 1.0))
            }
            
            if subsettingTwoEvents != nil {
                let secondMedicationEventsForDay = subsettingTwoEvents![dayComponents]
                if let medicationPercentage = percentageEventsCompleted(secondMedicationEventsForDay) , medicationPercentage > 0.0 {
                    // Scale the adherance to the same 0-10 scale as pain values.
                    let scaledMedication = medicationPercentage * (Float(assessmentValues.max()!))
                    
                    secondMedicationValues.append(scaledMedication)
                    secondMedicationLabels.append(percentageFormatter.string(from: medicationPercentage as! NSNumber)!)
                }
                else {
                    secondMedicationValues.append(0.0)
                    secondMedicationLabels.append(percentageFormatter.string(from: 0)!)
                }
                
                secondMedicationBarSeries = OCKBarSeries(title: firstSettingMedicationsIdentifiers?[1] ?? "Unknown", values: secondMedicationValues as [NSNumber], valueLabels: secondMedicationLabels, tintColor: UIColor(red: 212/255, green: 202/255, blue: 160/255, alpha: 1.0))
            }
            
            
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate)) //i.e Sat, Sun, Mon...
            axisSubtitles.append(shortDateFormatter.string(from: dayDate)) //i.e. 3-10, 3-11, 3-12
        }
        
        /*
         Displaying - Create the bar chart
         */
        
        //bars for each set of data
        let painBarSeries = OCKBarSeries(title: mainSettingUnit, values: assessmentValues as [NSNumber], valueLabels: assessmentLabels, tintColor: UIColor(red: 40/255, green: 120/255, blue: 119/55, alpha: 1.0))
        
        var insightDataSeries : [OCKBarSeries]
        
        //switch deciding which bar series to print
        if (firstMedicationBarSeries == nil && secondMedicationBarSeries == nil) {
            insightDataSeries = [painBarSeries]
        }else if (secondMedicationBarSeries == nil){
            insightDataSeries = [painBarSeries,firstMedicationBarSeries!]
        }else if (firstMedicationBarSeries == nil){
            insightDataSeries = [painBarSeries,secondMedicationBarSeries!]
        }else{
            insightDataSeries = [painBarSeries, firstMedicationBarSeries!, secondMedicationBarSeries!]
        }
        
        let chart = OCKBarChart(title: mainSettingIdentifier,
                                text: nil,
                                tintColor: UIColor.blue,
                                axisTitles: axisTitles,
                                axisSubtitles: axisSubtitles,
                                dataSeries: insightDataSeries)
        
        return chart
    }
    
    
    fileprivate func percentageEventsCompleted(_ events: [OCKCarePlanEvent]) -> Float? {
        guard !events.isEmpty else { return nil }
        
        let completedCount = events.filter({ event in
            event.state == .completed
        }).count
        
        return Float(completedCount) / Float(events.count)
    }
    
}

extension OCKInsightItem {
    /// Returns an `OCKInsightItem` to show when no insights have been calculated.
    static func noInsightsToShowMessage() -> OCKInsightItem {
        return OCKMessageItem(title: "No Insights", text: "There are no insights to show.", tintColor: UIColor.green, messageType: .tip)
    }
}

