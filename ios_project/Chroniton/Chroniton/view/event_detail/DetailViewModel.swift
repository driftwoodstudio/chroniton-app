//
//  DetailViewModel.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


// Controller that recieves updates for Event data fields and:
//  (a) validates/normalizes inputs to detect actual changes from existing values
//  (b) performs follow-on data manipulations either directly or via AppController
//  (c) triggers display of new values in DetailViewController
//
// Created by and attached to a DetailViewController instance.
//
class DetailViewModel {
        
    weak var view: DetailViewController? = nil  // nil until view is actually ready
    
    init() {
        AppController.instance.connectDetailView( self )
    }
    
    // Called by view once fully loaded and ready
    func connectLoadedView(view: DetailViewController) {
        self.view = view
    }
    
    
    // Event currently being shown, for cases where we need to save data to that
    // event after the global state's "selected event" has been updated to something new
    private(set) var eventCurrentlyInUI: Event? = nil
    
    
    // Controller notification that category display in UI is likely out of date and needs update
    func handleRefreshCategoryInfo() {
        view?.showNewCategory( eventCurrentlyInUI?.category )
    }

    
    // Reset to whatever global app state is the currently selected event
    // This may be a new selection, different than .eventCurrentlyInUI, which is discarded
    func showEvent() {
        eventCurrentlyInUI = AppState.instance.currentSelectedEvent
        view?.showEvent( eventCurrentlyInUI )  // Can be nil, if no event is selected
    }
    

    // Some field of the currently selected event has changed
    // Trigger broadcast notification so other screens that care can respond
    private func publishUpdatedEvent(_ event: Event) {
        AppLogger().logTrace("DetailViewModel: publishing update to event: '\(event.title ?? "(nil)")'")
        AppController.instance.doDetailViewAction( .publishUpdatedEvent(event) )
    }

    
    var title: String {
        get {
            if let e = self.eventCurrentlyInUI { return e.title! }
            return ""
        }
        set {
            if let e = self.eventCurrentlyInUI, newValue != e.title {
                e.title = newValue
                view?.showNewTitle( newValue )
                publishUpdatedEvent(e)
            }
        }
    }
    
    var lastDate: Date? {
        get {
            return self.eventCurrentlyInUI?.lastDate
        }
        set {
            if let e = self.eventCurrentlyInUI {
                if !DWDateUtils.areSameDate(d1: e.lastDate, d2: newValue) {
                    e.lastDate = newValue
                    view?.showNewLastDate( newValue )
                    publishUpdatedEvent(e)
               }
            }
        }
    }
    
    var nextDate: Date? {
        get {
            return self.eventCurrentlyInUI?.nextDate
        }
        set {
            if let e = self.eventCurrentlyInUI {
                if !DWDateUtils.areSameDate(d1: e.nextDate, d2: newValue) {
                    e.nextDate = newValue
                    view?.showNewNextDate( newValue )
                    publishUpdatedEvent(e)
                }
            }
        }
    }
    
    var image: UIImage? {
        get {
            if let e = self.eventCurrentlyInUI {
                return ImageManager.inflate(data: e.imageData)
            }
            return nil
        }
        set {
            if let e = self.eventCurrentlyInUI {
                // Store as image bytes
                e.imageData = ImageManager.pack( newValue )
                // Push to UI (nil allowed)
                view?.showNewImage( newValue )
                //
                publishUpdatedEvent(e)
            }
        }
    }
    
    var notes: String {
        get {
            if let e = self.eventCurrentlyInUI { return e.notes ?? "" }
            return ""
        }
        set {
            if let e = self.eventCurrentlyInUI, newValue != e.notes {
                e.notes = newValue
                view?.showNewNotes( newValue )
                publishUpdatedEvent(e)
            }
        }
    }

    
    // View telling us user wants to delete event being shown
    func deleteEvent() {
        guard let e = self.eventCurrentlyInUI else {
            AppLogger().logWarning("Delete-Event action initiated, but Detail screen does not have a current .event")
            return
        }
        // Delete event from model, which also causes controller to trigger follow-on effects
        AppController.instance.doDetailViewAction( .deleteEvent(e) )
    }
    
    
    // User wants to move event to a different Category
    // We don't hold event category locally, so accomplish this by
    // telling the AppController to do the move
    func setNewEventCategory(_ category: Category) {
        guard let e = self.eventCurrentlyInUI else { return }
        let oldCategory = e.category
        // move (if actully a different category)
        if category != oldCategory {
            AppController.instance.doDetailViewAction( .moveEvent(e, toNewCateogory: category) )
            view?.showNewCategory( category )
        }
    }
        
}
