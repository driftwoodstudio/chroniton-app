//
//  DataGenerator.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import DWLib


class DataGenerator {

    
    class func createHelpCategory(into m: Model) {
        // Read JSON file that contains event definitions, add to model
        if let jsonData = JSONFileReader.readJSONFromFile(fileName: JSONFileReader.filename_help) {
            DataGenerator.createRecordsFromJsonData(data: jsonData, into: m)
        }
        else {
            AppLogger().logWarning("Could not read JSON data file \(JSONFileReader.filename_test).json, so could not create help records")
        }
    }
    
    
    class func createTestCategories(into m: Model) {
        // Read JSON file that contains event definitions, add to model
        if let jsonData = JSONFileReader.readJSONFromFile(fileName: JSONFileReader.filename_test) {
            DataGenerator.createRecordsFromJsonData(data: jsonData, into: m)
        }
        else {
            AppLogger().logWarning("Could not read JSON data file \(JSONFileReader.filename_test).json, so could not create help records")
        }
    }
    
    
    class func createScreenshotCategories(into m: Model) {
        // Read JSON file that contains event definitions, add to model
        if let jsonData = JSONFileReader.readJSONFromFile(fileName: JSONFileReader.filename_automotive) {
            DataGenerator.createRecordsFromJsonData(data: jsonData, into: m)
        }
        else {
            AppLogger().logWarning("Could not read JSON data file \(JSONFileReader.filename_automotive).json, so could not create help records")
        }
    }
    
    
    // Internal work function: convert JSON data into records in datastore (Categories and Events).
    private class func createRecordsFromJsonData(data: Any, into m: Model) {
        
        // Data file should be an array of blocks
        if let list = data as? [[String:Any]] {
            
            // Each group should be: { category: {}, events: [] }
            for group in list {
                var categoryName: String? = nil
                if let categoryBlock = group["category"] as? [String: String] {
                    categoryName = categoryBlock["name"]
                }
                // Only continue if category.name existed as was non-blank
                if categoryName != nil && categoryName!.count > 0 {
                    
                    // Add category to Model
                    let c = m.createNewCategory(name: categoryName!)
                    
                    // Events block should be an array of dictionaries
                    if let eventList = group["events"] as? [Any] {
                        
                        // Each event
                        for eventBlock in eventList {
                            
                            // Event should be a dictionary
                            if let event = eventBlock as? [String: Any] {
                                
                                // Extract event field values
                                let titleStr = event["title"] as? String ?? ""
                                let notesStr = event["notes"] as? String  ?? ""
                                let lastDateDaysOffset = event["lastDateOffset"] as? Int
                                let nextDateDaysOffset = event["nextDateOffset"] as? Int
                                
                                // Create event in database only if event title is not blank (safety; block events with no title)
                                if titleStr != "" {
                                    let lastDate = nowOffsetByDays(days: lastDateDaysOffset )
                                    let nextDate = nowOffsetByDays(days: nextDateDaysOffset )

                                    // Debugging:
                                    //print("Event: [title = \(titleStr), last = \(lastDate), next = \(nextDate), notes = \(notesStr)]")
                                    
                                    // Create event in model for current category
                                    _ = m.createNewEvent(title: titleStr,
                                                         notes: notesStr,
                                                         lastDate: lastDate,
                                                         nextDate: nextDate,
                                                         in: c)
                                }
                                else {
                                    // No title for this event, so skip it entirely.
                                    // Do nothing.
                                }
                            }
                            else {
                                AppLogger().logError("Event block does not have expected structure: [String: String], is: \(eventBlock)")
                            }
                        }// Next event in this group
                    }
                    else {
                        // No event list in json data.
                        // Just leave category record as-is in model, without adding events to it.
                    }
                }
                else {
                    // JSON data did not contain the "category" block for this group.
                    // Ignore the group; do not add a category, do not add any events.
                }
                
            } // Next group
        }
    }
    
    
    // Utility: convert optional days offset to a date (or nil if no offset provided).
    // Return date shifted by given number of days; if shift is nil, return no date.
    // Shift days can be negative to get dates in the past.
    private class func nowOffsetByDays(days: Int?) -> Date? {
        guard let interval = days else { return nil }
        let d = Date().addDays( interval )
        return d
    }
    
}
