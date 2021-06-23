//
//  AppController.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


class AppController: NSObject {

    // Commands/Actions taken by Category List view
    enum EventListCommand {
        case setSelectedEvent( Event? )
        case createNewEvent(in: Category, atIndex:Int? = nil)
        case deleteEvent( Event )
        case reorderEvent( Event, toIndex: Int)
    }
    
    func doEventListAction(_ command: EventListCommand) {
        switch command {
            
            case .setSelectedEvent(let event):
                AppState.instance.setSelectedEvent( event )
                detailViewModel?.showEvent()  /// FIXME: unclear this is necessary... for iPad in landscape mode maybe?
            
            case .createNewEvent(let category, let index):
                addNewEvent(in: category, atIndex: index)
            
            case .deleteEvent(let event ):
                self.deleteEventViaEventListView( event )
            
            case .reorderEvent(let event, let index):
                AppState.instance.model.moveEvent(event, toNewIndex: index)
        }
    }
    

    // Commands/Actions taken by Event Edit view
    enum DetailViewCommand {
        case moveEvent( Event, toNewCateogory: Category )
        case deleteEvent( Event )
        case publishUpdatedEvent( Event )
    }
    
    func doDetailViewAction(_ command: DetailViewCommand) {
        switch command {
            
            case .moveEvent(let event, let category):
                changeCategoryForEvent(event, to: category)
            
            case .deleteEvent(let event):
                deleteEventViaEventDetailView( event )
            
            case .publishUpdatedEvent(let event):
                publishEditedEvent( event )
        }
    }
    
    
    // Commands/Actions taken by Category List view
    enum CategoryListCommand {
        case renameCategory( Category, String )
        case deleteCategory( Category )
        case reorderCategory( Category, toIndex: Int )
        case addCategory( String ) // name
    }
    
    func doCategoryListAction(_ command: CategoryListCommand) {
        switch command {
            case .renameCategory(let category, let newNameStr):
                renameCategory(category, to: newNameStr)
            
            case .deleteCategory(let category):
                self.deleteCategory( category )
            
            case .reorderCategory(let category, let toIndex):
                AppState.instance.model.moveCategory(category, toIndex: toIndex)

            case .addCategory(let startingNameStr):
                let _ = AppState.instance.model.createNewCategory(name: startingNameStr)
        }
    }
    
    

    // MARK: - State
    
    static let instance = AppController()

    // Convenience wrapper for easy access to global singleton
    private var state: AppState {
        return AppState.instance
    }
    
    
    // Expected to be set externally by manual call after init()
    private var splitViewController: UISplitViewController? = nil
    private var eventListViewModel: EventListViewModel? = nil
    private weak var detailViewModel: DetailViewModel? = nil
    private weak var categoryListViewModel: CategoryListViewModel? = nil
    
    
    // MARK: - Init

    
    class func startup(then completionCallback: @escaping ()->Void) {
        CoreDataManager.startup() {

            // Establish Model() that represents the CoreData data store to app
            let model = Model()
            
            // Init the implicitly created singleton with this Model
            AppState.instance.setNewModel( model )
            
            completionCallback()
        }
    }
    
    
    private override init() {
        super.init()
    }
    
    
    func connectSplitViewController(_ svc: RootSplitViewController?) {
        splitViewController = svc
    }
    
    func connectDetailView(_ detail: DetailViewModel?) {
        detailViewModel = detail
    }
    
    func connectListView(_ list: EventListViewModel?) {
        eventListViewModel = list
    }
    
    func connectCategoryListView(_ list: CategoryListViewModel?) {
        categoryListViewModel = list
    }
    
    
    
    // MARK: - Event Selection

    
    // Convenience way to "show some event", defaulting to the first event in first category
    func selectFirstEvent() {
        let model = AppState.instance.model
        if let event = model.firstEvent() {
            selectEvent( event )
        }
        else {
            AppLogger().logTrace("AppController: selectFirstEvent() found no event so .currentSelectedEvent is now nil")
            selectEvent( nil )
        }
    }
    
    // Discard all UI state and force app to have a newly selected event
    private func selectEvent(_ event: Event?) {
        AppState.instance.setSelectedEvent( event )
        eventListViewModel?.showAsSelectedVisual( event )
        detailViewModel?.showEvent()
    }
    
}



// MARK: - Event List Actions

private extension AppController {
    
    private func addNewEvent(in category: Category, atIndex index: Int?) {
        let _ = AppState.instance.model.createNewEvent(title: "New Event",
                                                           in: category,
                                                           insertingAtIndex: index)
    }

    private func deleteEventViaEventListView(_ event: Event) {
        AppState.instance.model.deleteEvent(event)
        if AppState.instance.currentSelectedEvent == event {
            AppState.instance.setSelectedEvent( nil )
            detailViewModel?.showEvent()
        }
    }

}



// MARK: - Detail Edit Actions

private extension AppController {
    
    private func changeCategoryForEvent(_ event: Event, to category: Category) {
        AppState.instance.model.moveEvent(event, toNewCategory: category)
    }
    
    private func deleteEventViaEventDetailView(_ event: Event) {
        AppState.instance.model.deleteEvent(event)
        // note: for detail view to have initiated this action, event MUST have been the selected event
        eventListViewModel?.handleModelUpdated(thenReselect: nil)
        selectFirstEvent()
    }
    
    private func publishEditedEvent(_ updatedEventStruct: Event) {
        CoreDataManager.saveContext()
    }
    
}



// MARK: - Category List Actions

private extension AppController {
        
    private func deleteCategory(_ category: Category) {
        let model = AppState.instance.model
        
        // Is the current event in this category?
        var needNewEventSelection = false
        if let event = AppState.instance.currentSelectedEvent {
            let events = category.orderedEvents()
            if events.contains( event ) {
                // Yes, current event is in category being deleted, so must select a different event when done
                needNewEventSelection = true
            }
        }
        
        // Remove from Model
        model.deleteCategory( category )
        
        // If EventListView showing, tell it to update itself based on Model state
        eventListViewModel?.handleModelUpdated(thenReselect: nil)
        
        // If needed, establish an event selection to force update of Detail view
        if needNewEventSelection {
            selectFirstEvent()
        }
    }
    
    
    
    
    private func renameCategory(_ category: Category, to newName: String) {
        
        // Model update
        category.name = newName
        CoreDataManager.saveContext()
        
        // Propagation to Detail UI (if showing an event in this category)
        if
            let event = AppState.instance.currentSelectedEvent,
            let eventCategory = event.category,
            eventCategory == category
        {
            detailViewModel?.handleRefreshCategoryInfo()
        }
    }

}


// MARK: - Model Load/Save

extension AppController {

    func saveModel() {
        // FIXME: search and remove uses of this function, reworking logic to be through CoreDataManager
        CoreDataManager.saveContext()
    }
}


// MARK: - Data Export

extension AppController {
    
    private static let externalGateway = ExternalAppGateway()
    
    // Convenience wrapper 
    static func canSendEmail() -> Bool {
        return ExternalAppGateway.deviceIsMailEnabled()
    }
    
    func sendEmailSubject(_ title: String, body: String, from currentController: UIViewController) {
        AppController.externalGateway.sendEmail(to: nil, withSubject: title, text: body, from: currentController)
    }
    
    
    func sendCsvData(asEmail csvDataString: String, from currentController: UIViewController) {
        var attachment: EmailAttachment? = nil
        let filename = "chroniton_data.csv"
        if let data = csvDataString.data(using: .utf16) {
            attachment = EmailAttachment(data: data, mimeType: "text/csv", filename: filename )
        }
        let title = NSLocalizedString("email-subject", comment: "Email subject line")
        let body = NSLocalizedString("email-body", comment: "Email body text")
        
        AppController.externalGateway.sendEmail(to: nil, withSubject: title, text: body, attachment: attachment, from: currentController)
    }
    
    
    
    // Use view to show alert about email capability not being available
    static func notifyNoEmail(from view: UIViewController) {
        let title = NSLocalizedString("EmailNotAvailableAlertTitle", comment: "Email not available") // "Not Available"
        let body = NSLocalizedString("EmailNotAvailableAlertBody", comment: "Email not available explanation") // "No email client is configured on this device"
        DWLib.AlertViewHelper.showPopupMessage(body, withTitle: title, buttonCaption: nil, sourceVc: view)
    }

}

