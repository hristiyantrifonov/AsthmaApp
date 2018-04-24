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
    
    //MARK: - The Operation
    
    override func main() {
        
        //If operation cancelled we exit
        guard !isCancelled else { return }
        
        //Create an array of insights
        var newInsights = [OCKInsightItem]()
        
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
    
    func createFirstSettingInsight() -> OCKInsightItem? {
        
        //Make sure there are events to begin with (usually it is sensible to do couples - pain & medication)
        //As it is in the sample app - (the back pain insight keeps track of the pain and the amount of Ibuprofen patient is taking)
        guard let settingOneEvents = settingOneEvents else { return nil }
        
        /* Medications/Subsettings declaration */
        let subsettingOneEvents = settingOneFirstSubsettingEvents
    
        let subsettingTwoEvents = settingOneSecondSubsettingEvents
        
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
                    let scaledMedication = medicationPercentage * 10.0

                    firstMedicationValues.append(scaledMedication)
                    firstMedicationLabels.append(String(firstMedicationEventsForDay.filter({$0.state == .completed}).count))
                }
                else {
                    firstMedicationValues.append(0.0)
                    firstMedicationLabels.append(NSLocalizedString("0", comment: ""))
                }

                firstMedicationBarSeries = OCKBarSeries(title: "Medication 1", values: firstMedicationValues as [NSNumber], valueLabels: firstMedicationLabels, tintColor: UIColor.darkGray)
            }
            
            if subsettingTwoEvents != nil {
                let secondMedicationEventsForDay = subsettingTwoEvents![dayComponents]
                if let medicationPercentage = percentageEventsCompleted(secondMedicationEventsForDay) , medicationPercentage > 0.0 {
                    // Scale the adherance to the same 0-10 scale as pain values.
                    let scaledMedication = medicationPercentage * 10.0
                    
                    secondMedicationValues.append(scaledMedication)
                    secondMedicationLabels.append(String(secondMedicationEventsForDay.filter({$0.state == .completed}).count))
                }
                else {
                    secondMedicationValues.append(0.0)
                    secondMedicationLabels.append(NSLocalizedString("0", comment: ""))
                }
                
                secondMedicationBarSeries = OCKBarSeries(title: "Medication 2", values: secondMedicationValues as [NSNumber], valueLabels: secondMedicationLabels, tintColor: UIColor.brown)
            }
            
            
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate)) //i.e Sat, Sun, Mon...
            axisSubtitles.append(shortDateFormatter.string(from: dayDate)) //i.e. 3-10, 3-11, 3-12
        }
        
        /*
         Displaying - Create the bar chart
         */
        
        //bars for each set of data
        let painBarSeries = OCKBarSeries(title: "mg/dL", values: assessmentValues as [NSNumber], valueLabels: assessmentLabels, tintColor: UIColor.blue)
        
        
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
        
        let chart = OCKBarChart(title: "Blood Glucose",
                                text: nil,
                                tintColor: UIColor.blue,
                                axisTitles: axisTitles,
                                axisSubtitles: axisSubtitles,
                                dataSeries: insightDataSeries,
                                minimumScaleRangeValue: 0,
                                maximumScaleRangeValue: 80)
        
        return chart
    }
    
    
    func createSecondSettingInsight() -> OCKInsightItem? {
        
        //Make sure there are events to begin with (usually it is sensible to do couples - pain & medication)
        //As it is in the sample app - (the back pain insight keeps track of the pain and the amount of Ibuprofen patient is taking)
        guard let settingTwoEvents = settingTwoEvents else { return nil }
        
        /* Medications/Subsettings declaration */
        let subsettingOneEvents = settingTwoFirstSubsettingEvents
        
        let subsettingTwoEvents = settingTwoSecondSubsettingEvents
        
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
                    let scaledMedication = medicationPercentage * 10.0
                    
                    firstMedicationValues.append(scaledMedication)
                    firstMedicationLabels.append(String(firstMedicationEventsForDay.filter({$0.state == .completed}).count))
                }
                else {
                    firstMedicationValues.append(0.0)
                    firstMedicationLabels.append(NSLocalizedString("0", comment: ""))
                }
                
                firstMedicationBarSeries = OCKBarSeries(title: "Medication 1", values: firstMedicationValues as [NSNumber], valueLabels: firstMedicationLabels, tintColor: UIColor.darkGray)
            }
            
            if subsettingTwoEvents != nil {
                let secondMedicationEventsForDay = subsettingTwoEvents![dayComponents]
                if let medicationPercentage = percentageEventsCompleted(secondMedicationEventsForDay) , medicationPercentage > 0.0 {
                    // Scale the adherance to the same 0-10 scale as pain values.
                    let scaledMedication = medicationPercentage * 10.0
                    
                    secondMedicationValues.append(scaledMedication)
                    secondMedicationLabels.append(String(secondMedicationEventsForDay.filter({$0.state == .completed}).count))
                }
                else {
                    secondMedicationValues.append(0.0)
                    secondMedicationLabels.append(NSLocalizedString("0", comment: ""))
                }
                
                secondMedicationBarSeries = OCKBarSeries(title: "Medication 2", values: secondMedicationValues as [NSNumber], valueLabels: secondMedicationLabels, tintColor: UIColor.brown)
            }
            
            
            
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate)) //i.e Sat, Sun, Mon...
            axisSubtitles.append(shortDateFormatter.string(from: dayDate)) //i.e. 3-10, 3-11, 3-12
        }
        
        /*
         Displaying - Create the bar chart
         */
        
        //bars for each set of data
        let painBarSeries = OCKBarSeries(title: "sec", values: assessmentValues as [NSNumber], valueLabels: assessmentLabels, tintColor: UIColor.blue)
        
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
        
        let chart = OCKBarChart(title: "Something else",
                                text: nil,
                                tintColor: UIColor.blue,
                                axisTitles: axisTitles,
                                axisSubtitles: axisSubtitles,
                                dataSeries: insightDataSeries,
                                minimumScaleRangeValue: 0,
                                maximumScaleRangeValue: 80)
        
        return chart
    }
    
    func createThirdSettingInsight() -> OCKInsightItem? {
        
        //Make sure there are events to begin with (usually it is sensible to do couples - pain & medication)
        //As it is in the sample app - (the back pain insight keeps track of the pain and the amount of Ibuprofen patient is taking)
        guard let settingThreeEvents = settingThreeEvents else { return nil }
        
        /* Medications/Subsettings declaration */
        let subsettingOneEvents = settingThreeFirstSubsettingEvents
        
        let subsettingTwoEvents = settingThreeSecondSubsettingEvents
        
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
                    let scaledMedication = medicationPercentage * 10.0
                    
                    firstMedicationValues.append(scaledMedication)
                    firstMedicationLabels.append(String(firstMedicationEventsForDay.filter({$0.state == .completed}).count))
                }
                else {
                    firstMedicationValues.append(0.0)
                    firstMedicationLabels.append(NSLocalizedString("0", comment: ""))
                }
                
                firstMedicationBarSeries = OCKBarSeries(title: "Medication 1", values: firstMedicationValues as [NSNumber], valueLabels: firstMedicationLabels, tintColor: UIColor.darkGray)
            }
            
            if subsettingTwoEvents != nil {
                let secondMedicationEventsForDay = subsettingTwoEvents![dayComponents]
                if let medicationPercentage = percentageEventsCompleted(secondMedicationEventsForDay) , medicationPercentage > 0.0 {
                    // Scale the adherance to the same 0-10 scale as pain values.
                    let scaledMedication = medicationPercentage * 10.0
                    
                    secondMedicationValues.append(scaledMedication)
                    secondMedicationLabels.append(String(secondMedicationEventsForDay.filter({$0.state == .completed}).count))
                }
                else {
                    secondMedicationValues.append(0.0)
                    secondMedicationLabels.append(NSLocalizedString("0", comment: ""))
                }
                
                secondMedicationBarSeries = OCKBarSeries(title: "Medication 2", values: secondMedicationValues as [NSNumber], valueLabels: secondMedicationLabels, tintColor: UIColor.brown)
            }
            
            
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate)) //i.e Sat, Sun, Mon...
            axisSubtitles.append(shortDateFormatter.string(from: dayDate)) //i.e. 3-10, 3-11, 3-12
        }
        
        /*
         Displaying - Create the bar chart
         */
        
        //bars for each set of data
        let painBarSeries = OCKBarSeries(title: "l/min", values: assessmentValues as [NSNumber], valueLabels: assessmentLabels, tintColor: UIColor.blue)
        
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
        
        let chart = OCKBarChart(title: "Something",
                                text: nil,
                                tintColor: UIColor.blue,
                                axisTitles: axisTitles,
                                axisSubtitles: axisSubtitles,
                                dataSeries: insightDataSeries,
                                minimumScaleRangeValue: 0,
                                maximumScaleRangeValue: 80)
        
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

