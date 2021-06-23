//
//  StartupController.swift
//  Chroniton
//
//  Created by Bill on 6/15/21.
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import Foundation

struct StartupController {
    
    static func doAppStartupActions(then callback: @escaping ()->Void) {
        AppController.startup {
            callback()
        }
    }
    
    
    static var isFirstRun: Bool {
        return !AppSettings.sharedInstance.hasRunBeforOnThisDevice
    }
    
    
    static func doFirstRunOperations(then callback: @escaping ()->Void ) {
        
        AppLogger().logDebug("Using DataGenerator to create help data records")
        DataGenerator.createHelpCategory(into: AppState.instance.model)
        
        if DebugSettings.shouldCreateTestData {
            AppLogger().logDebug("Using DataGenerator to create test data")
            DataGenerator.createTestCategories(into: AppState.instance.model)
        }

        if DebugSettings.shouldCreateAutomotiveCategoryData {
            AppLogger().logDebug("Using DataGenerator to create screenshot data")
            DataGenerator.createScreenshotCategories(into: AppState.instance.model)
        }

        AppSettings.sharedInstance.hasRunBeforOnThisDevice = true
        AppLogger().logDebug("did set: AppSettings.sharedInstance.hasRunBeforOnThisDevice = true")
        
        // Invoke supplied callback to let caller know we're complete
        callback()
    }
        
}
