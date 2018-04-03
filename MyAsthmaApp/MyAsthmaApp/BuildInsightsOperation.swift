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
    
    var outdoorWalkEvents: DailyEvents?
    var takeNurofenEvents: DailyEvents?
    var bloodGlucoseEvents: DailyEvents?
    
    fileprivate(set) var insights = [OCKInsightItem.noInsightsToShowMessage()]   //we start off with array of empty insights
    
    //MARK: - The Operation
    
    override func main() {
        
        //If operation cancelled we exit
        guard !isCancelled else { return }
        
        //Create an array of insights
        var newInsights = [OCKInsightItem]()
        
        if let insight = createBloodGlucoseInsight() {
            newInsights.append(insight)
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
    
    func createBloodGlucoseInsight() -> OCKInsightItem? {
        
        //Make sure there are events to begin with (usually it is sensible to do couples - pain & medication)
        //As it is in the sample app - (the back pain insight keeps track of the pain and the amount of Ibuprofen patient is taking)
        guard let bloodGlucoseEvents = bloodGlucoseEvents else { return nil }
        
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
        Loop through the seven days and obtain pain score for each day
         */
        
        var assessmentValues = [Int]()
        var assessmentLabels = [String]()
        var axisTitles = [String]()
        var axisSubtitles = [String]()
        
        for offset in 0..<7 {
            
            //Determining the day
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)! //2018-03-10, 2018-03-11 and so on...
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate) //turns it into - era: 1 year: 2018 month: 3 day: 10 isLeapMonth: false
            
            if let result = bloodGlucoseEvents[dayComponents].first?.result, let score = Int(result.valueString), score > 0 {
                assessmentValues.append(score)
                assessmentLabels.append(result.valueString)
            }else{
                assessmentValues.append(0)
                assessmentLabels.append(NSLocalizedString("N/A", comment: ""))
            }
            
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate)) //i.e Sat, Sun, Mon...
            axisSubtitles.append(shortDateFormatter.string(from: dayDate)) //i.e. 3-10, 3-11, 3-12
        }
        
        /*
         Displaying - Create the bar chart
         */
        
        //bars for each set of data
        let painBarSeries = OCKBarSeries(title: "mg/dL", values: assessmentValues as [NSNumber], valueLabels: assessmentLabels, tintColor: UIColor.blue)
        
        let chart = OCKBarChart(title: "Blood Glucose",
                                text: nil,
                                tintColor: UIColor.blue,
                                axisTitles: axisTitles,
                                axisSubtitles: axisSubtitles,
                                dataSeries: [painBarSeries],
                                minimumScaleRangeValue: 0,
                                maximumScaleRangeValue: 200)
        
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

