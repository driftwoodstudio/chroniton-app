//
//  AppState.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


class AppState: NSObject {
    
    // Singleton instance
    static let instance = AppState(model: nil, selectedEvent: nil)
    
    
    // Currently selected event
    private(set) var currentSelectedEvent: Event? = nil
    
    // Data model (category list, with Events in each Category)
    private (set) var model: Model

    
    
    private init(model: Model?, selectedEvent: Event?) {
        if model == nil {
            self.model = Model()
        }
        else {
            self.model = model!
        }
        self.currentSelectedEvent = selectedEvent
        super.init()
    }
    
    // Mutate state by setting a new model
    // Old/existing model is dropped (without saving)
    // This just alters state; you must push state out to UI/etc by other means
    func setNewModel(_ model: Model) {
        self.model = model
    }
    
    
    // Public mutator to change event that 'is selected'
    func setSelectedEvent(_ event: Event?) {
        currentSelectedEvent = event
    }
    
    func badgeCount(_ numberOfDays: Int) -> Int {
        return model.countDueEvents(inDays: numberOfDays)
    }
    
}
