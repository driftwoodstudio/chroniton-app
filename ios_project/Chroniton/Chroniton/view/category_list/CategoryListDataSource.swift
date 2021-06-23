//
//  CategoryListDataSource.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import CoreData


// Item to give to DiffableDataSource to hold as "current data for TableView"
// Not using Category coredata object directly because then if you change the object
// (reference type) it changes the SAME object as being heldy by DiffableDataSource,
// making data source unable to detect the change when you give it newly-fetched
// list of Category object references to compare against: Same object!
struct CategoryListDataItem: Hashable {
    let cdObjectId: String
    let name: String
    let orderIndex: Int
    
    init(from c: Category) {
        self.cdObjectId = String(describing: c.objectID)
        self.name = c.name!
        self.orderIndex = Int(c.orderIndex)
    }
}


class CategoryListTableDataSource: UITableViewDiffableDataSource<Int, CategoryListDataItem> {
    
    private weak var owner: CategoryListViewModel?
    private var fetchedResultsController: NSFetchedResultsController<Category>!

    // Local state made necessary by Edit-mode allowing user to move rows, which TableView handles by updating table state.
    // But data must be updated to match, which triggers FetchedResultController to be notified of change, and then
    // it tries to *also* update the TableView -- which causes table view state to go wonky (double TableView update)
    private var skipTableUpdateForPendingDataUpdate = false
    
    
    // MARK: - UITableViewDiffableDataSource

    init(tableView: UITableView, ownedBy: CategoryListViewModel) {
        self.owner = ownedBy

        super.init(
            tableView: tableView,
            cellProvider: { (tableView, indexPath, category) -> UITableViewCell? in
                return CategoryListTableDataSource._generateTableCell(
                    for: category,
                    atIndexPath: indexPath,
                    inTable: tableView,
                    onEdit: {
                        ownedBy.userActionEditCategory(atIndex: indexPath.row )
                    }
                )
            }
        )

        self.setupFetchedResultsControllerForCategories()
    }
    
    
    private func setupFetchedResultsControllerForCategories() {
        let  request = Category.orderedFetchRequest()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: CoreDataManager.context(),
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            createAndApplySnapshot()
        } catch {
            AppLogger().logError("CategoryListTableDataSource: Failed to execute fech on Category FetchedResultsController")
            fatalError()
        }
    }

    
    func start() {
        createAndApplySnapshot(animatingDifferences: false)
    }
    
    
    private func createAndApplySnapshot(animatingDifferences: Bool = true, then: (()->Void)? = nil) {
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
                //self._log(tag: "\nCategoryListDataSource.createAndApplySnapshot(), BEFORE data is", snapshot: before)
                
                // Build new snapshot using .fetchedResultsController current content
                var newSnapshot = NSDiffableDataSourceSnapshot<Int, CategoryListDataItem>()
                newSnapshot.appendSections( [0] )  // only one section, but have to define at least one Section object
                let categories = self.fetchedResultsController!.fetchedObjects ?? []
                let items = categories.map({ CategoryListDataItem(from: $0) })
                newSnapshot.appendItems( items )
                
                //self._log(tag: "\nCategoryListDataSource.createAndApplySnapshot(), applying:", snapshot: newSnapshot)
                self.apply(newSnapshot, animatingDifferences: animatingDifferences)
                
                //let after = self.snapshot()
                //self._log(tag: "\nCategoryListDataSource.createAndApplySnapshot(), AFTER data is", snapshot: after)
            }
            then?()
        }
    }
    
    

    // MARK: - Table Edit Events
    
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
            let categories = self.fetchedResultsController.fetchedObjects ?? []
            guard indexPath.row < categories.count else {
                AppLogger().logError("Delete TableView action for row \(indexPath.row) but there are only \(categories.count) categories in .fetchedResultsController data")
                return
            }
            owner?.userActionDeleteCategory( categories[indexPath.row] )
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath)
    {
        skipTableUpdateForPendingDataUpdate = true  // see comment at var declaration
        let categories = self.fetchedResultsController.fetchedObjects ?? []
        guard sourceIndexPath.row < categories.count else {
            AppLogger().logError("Move TableView action for row \(sourceIndexPath.row) but there are only \(categories.count) categories in .fetchedResultsController data")
            return
        }
        owner?.userActionMoveCategory(categories[sourceIndexPath.row],
                                      newIndex: destinationIndexPath.row)
    }
}



// MARK: - NSFetchedResultsControllerDelegate

extension CategoryListTableDataSource: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            AppLogger().logTrace("CategoryListTableDataSource: a fetched results controller received controllerDidChangeContent() event -- applying snapshot")
            self.createAndApplySnapshot()
        }
    }

    // Force-trigger re-application of current fetched results controller
    func _test_triggerChangeResponse() {
        self.createAndApplySnapshot()
    }
}




// MARK: - Private/Internal

extension CategoryListTableDataSource {

    // Note: this (annoyingly) has to be a class func because it's called by closure
    //  that has to exist before init() is complete (required param for super.init() call)
    //  meaning the closure can't refer to self.anything, so can't call as an instance method.
    private class func _generateTableCell(for category: CategoryListDataItem,
                                          atIndexPath: IndexPath,
                                          inTable tableView: UITableView,
                                          onEdit: @escaping ()->Void )
        -> UITableViewCell
    {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: atIndexPath)
                as! CategoryListCell
        cell.configure(for: category, onEdit: onEdit)
        return cell
    }
    
    
    private func _log(tag: String, snapshot: NSDiffableDataSourceSnapshot<Int, CategoryListDataItem>) {
        var str = tag
        for s in snapshot.sectionIdentifiers {
            str += "\n  Section: \(s)"
            for c in snapshot.itemIdentifiers(inSection: s) {
                str += "\n    item: [\(c.orderIndex)]  \(c.name)"
            }
        }
        AppLogger().logDebug(str)
    }
    
    private func _log(tag: String, frc: NSFetchedResultsController<Category>) {
        let items = frc.fetchedObjects ?? []
        var str = tag
        for i in items {
            str += "\n  [\(i.orderIndex)]  \(i.name!)"
        }
        AppLogger().logDebug(str)
    }
}

