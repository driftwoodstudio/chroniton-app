//
//  EventListViewModel.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit

class EventListViewModel {

    // The category whose events are being shown
    // Required, so assume it has been set by whoever is showing this view controller
    private var category: Category!
        // FIXME: make this an init() parameter
    
    private(set) weak var view: EventListViewController? = nil  // nil until view is actually ready
    private var diffableDataSource: EventListTableDataSource!
    var isOffscreen = true
    
    
    init() {
    }
    
    func setCategory(_ category: Category) {
        self.category = category
    }
    
    // Called by view once fully loaded and ready
    // On ipad, it's possible for ViewController to exist without ever having loaded it's View,
    // since in Portrait orientation the app starts up showing just the Detail pane of SplitView
    func connectLoadedView(_ view: EventListViewController) {
        self.view = view
    }
    
    func conectDataSource(for tableView: UITableView) {
        // Create data source and have it populate itself with data, attaching to TableView
        diffableDataSource = EventListTableDataSource(for: category, tableView: tableView, ownedBy: self)
    }
    
    func refreshTableDisplay() {
        diffableDataSource.start()
    }

    func addEvent() {
        AppController.instance.doEventListAction(
            .createNewEvent(in: self.category)
        )
    }
    
    func activateEventAtIndex(_ index: Int) {
        let event = category.orderedEvents()[ index ]
        AppController.instance.doEventListAction( .setSelectedEvent(event) )
    }
    
    // Make this event the selected one in the list, without triggering any
    // follow-on "event changed" notifications (as this command is coming from the
    // AppController, which will handle any side effects needed)
    func showAsSelectedVisual(_ event: Event?) {
        view?.showAsSelectedVisual( event )
    }
    
    
    // Didscard and reload list, not selecting anything
    func handleModelUpdated(thenReselect event: Event?) {
        DispatchQueue.main.async {
            AppLogger().logTrace("EventListViewController: about to reload table view because model was updated")
            self.diffableDataSource.createAndApplySnapshot() {
                self.showAsSelectedVisual(event)
            }
        }
    }
    
    // A new event in data model needs to be added to list
    // and then selected as the new Selected Event in state
    func handleAdded(event: Event) {
        diffableDataSource.createAndApplySnapshot() {
            AppController.instance.doEventListAction( .setSelectedEvent(event) )
            self.view?.showAsSelectedVisual( event )
        }
    }
    
    
    
    // Called by table data source object when Delete option is chosen by user
    func _handleDeleteRequest(event: Event) {
        AppController.instance.doEventListAction( .deleteEvent(event) )
    }
    
    func _handleMoveEvent(_ event: Event, newIndex: Int) {
        if event.orderIndex != newIndex {
            AppController.instance.doEventListAction(
                .reorderEvent(event, toIndex: newIndex)
            )
        }
    }

}
