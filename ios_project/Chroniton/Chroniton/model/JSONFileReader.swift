//
//  JSONData.swift
//  Chroniton
//
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import Foundation


class JSONFileReader {
    
    static let filename_help = "data_help"
    static let filename_automotive = "data_automotive"
    static let filename_test = "data_test"

    
    static func readJSONFromFile(fileName: String) -> Any?
    {
        var json: Any?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                json = try? JSONSerialization.jsonObject(with: data)
            } catch {
                // Handle error here
                AppLogger().logError("Caught error trying to read JSON data", error: error)
                return nil
            }
        }
        else {
            AppLogger().logError("Did not find path for json data file: \(fileName)")
            return nil
        }
        
        return json
    }
    
}
