//
//  EventListDataSource.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import CoreData


// Item to give to DiffableDataSource to hold as "current data for TableView"
// Not using Event coredata object directly because then if you change the object
// (reference type) it changes the SAME object as being heldy by DiffableDataSource,
// making data source unable to detect the change when you give it newly-fetched
// list of Category object references to compare against: Same object!
struct EventListDataItem: Hashable {
    let cdObjectId: String
    let title: String
    let orderIndex: Int
    let lastDate: Date?
    let nextDate: Date?
    let notes: String?
    let imageData: Data?
    
    init(from e: Event) {
        self.cdObjectId = String(describing: e.objectID)
        self.title = e.title!
        self.orderIndex = Int(e.orderIndex)
        self.lastDate = e.lastDate
        self.nextDate = e.nextDate
        self.notes = e.notes
        self.imageData = e.imageData
    }
}


class EventListTableDataSource: UITableViewDiffableDataSource<Int, EventListDataItem> {
    
    private weak var owner: EventListViewModel?
    private var fetchedResultsController: NSFetchedResultsController<Event>!
    private var category: Category!
    
    // Local state made necessary by Edit-mode allowing user to move rows, which TableView handles by updating table state.
    // But data must be updated to match, which triggers FetchedResultController to be notified of change, and then
    // it tries to *also* update the TableView -- which causes table view state to go wonky (double TableView update)
    private var skipTableUpdateForPendingDataUpdate = false


    // MARK: UITableViewDiffableDataSource
    
    init(for category: Category, tableView: UITableView, ownedBy: EventListViewModel) {

        super.init(
            tableView: tableView,
            cellProvider: { (tableView, indexPath, event) -> UITableViewCell? in
                return EventListTableDataSource._generateTableCell(for: event, atIndexPath: indexPath, inTable: tableView)
            }
        )

        self.category = category
        self.owner = ownedBy
        self.setupFetchedResultsControllerForEvents()
    }


    private func setupFetchedResultsControllerForEvents() {
        let  request = Event.orderedFetchRequest(forCategory: self.category)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: CoreDataManager.context(),
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            createAndApplySnapshot()
        } catch {
            AppLogger().logError("EventListTableDataSource: Failed to execute fech on Category FetchedResultsController")
            fatalError()
        }
    }

    
    func start() {
        createAndApplySnapshot(animatingDifferences: false)
    }

    
    func createAndApplySnapshot(animatingDifferences: Bool = true, then: (()->Void)? = nil) {
        let offscreen = owner?.isOffscreen ?? true
        guard !offscreen else { return }

        DispatchQueue.main.async {
            
            if self.skipTableUpdateForPendingDataUpdate {
                // user-interactive table row update that TableView has already applied; don't let this
                // data-change-driven update cycle try to update the TableView.
                // But do reset to allow future updates to be handled normally:
                AppLogger().logDebug("Skipping createAndApplySnapshot() action because skipTableUpdateForPendingDataUpdate = true")
                self.skipTableUpdateForPendingDataUpdate = false
            }
            else {
                //let before = self.snapshot()
                //self._log(tag: "\nEventListTableDataSource.createAndApplySnapshot(), BEFORE data is", snapshot: before)

                var newSnapshot = NSDiffableDataSourceSnapshot<Int, EventListDataItem>()
                newSnapshot.appendSections( [0] )  // only one section, but have to define at least one Section object
                let events = self.fetchedResultsController!.fetchedObjects ?? []
                let items = events.map({ EventListDataItem(from: $0) })
                newSnapshot.appendItems( items )
            
                //self._log(tag: "\nCategoryListDataSource.createAndApplySnapshot(), applying:", snapshot: newSnapshot)
                self.apply(newSnapshot, animatingDifferences: animatingDifferences)
                
                //let after = self.snapshot()
                //self._log(tag: "\nCategoryListDataSource.createAndApplySnapshot(), AFTER data is", snapshot: after)
            }
            then?()
        }
    }

    
    // MARK: - Table Events
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            let events = self.fetchedResultsController.fetchedObjects ?? []
            guard indexPath.row < events.count else {
                AppLogger().logError("Delete TableView action for row \(indexPath.row) but there are only \(events.count) events in .fetchedResultsController data")
                return
            }
            owner?._handleDeleteRequest(event: events[indexPath.row])
        }
    }
    
    
    // User-controlled "drag table row to new row ordering" event from TableView
    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath)
    {
        skipTableUpdateForPendingDataUpdate = true  // see comment at var declaration
        AppLogger().logDebug("tableView(moveRowAt: \(sourceIndexPath.row) to: \(destinationIndexPath.row))")
        let events = self.fetchedResultsController.fetchedObjects ?? []
        guard sourceIndexPath.row < events.count else {
            AppLogger().logError("Delete TableView action for row \(sourceIndexPath.row) but there are only \(events.count) events in .fetchedResultsController data")
            return
        }
        let event = events[sourceIndexPath.row]
        owner?._handleMoveEvent(event, newIndex: destinationIndexPath.row)
    }
    
}


// FetchedResultsController update notifications
extension EventListTableDataSource: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            AppLogger().logTrace("EventListTableDataSource: a fetched results controller received controllerDidChangeContent() event -- applying snapshot")
            self.createAndApplySnapshot()
        }
    }
    
    // Force-trigger re-application of current fetched results controller
    func _test_triggerChangeResponse() {
        self.createAndApplySnapshot()
    }
}




// MARK: - Private/Internal

extension EventListTableDataSource {
    
    // Note: this (annoyingly) has to be a class func because it's called by closure
    //  that has to exist before init() is complete (required param for super.init() call)
    //  meaning the closure can't refer to self.anything, so can't call as an instance method.
    private class func _generateTableCell(for event: EventListDataItem,
                                    atIndexPath: IndexPath,
                                    inTable tableView: UITableView)
        -> UITableViewCell
    {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "EventListCell", for: atIndexPath)
                as! EventListCell
        //AppLogger().logDebug("Have event table cell, configuring for event: \(event)")
        cell.configureCell(toShow: event)
        return cell
    }
    
    
    private func _log(tag: String, snapshot: NSDiffableDataSourceSnapshot<Int, EventListDataItem>) {
        var str = tag
        for s in snapshot.sectionIdentifiers {
            str += "\n  Section: \(s)"
            for c in snapshot.itemIdentifiers(inSection: s) {
                str += "\n    item: [\(c.orderIndex)]  \(c.title)"
            }
        }
        AppLogger().logDebug(str)
    }
    
    private func _log(tag: String, frc: NSFetchedResultsController<Event>) {
        let items = frc.fetchedObjects ?? []
        var str = tag
        for i in items {
            str += "\n  [\(i.orderIndex)]  \(i.title!)"
        }
        AppLogger().logDebug(str)
    }

}
