//
//  CategoryListViewModel.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


class CategoryListViewModel {

    class State {
        /*
        enum Status {
            case loading
            case ready
        }
        var status = Status.loading
        private func assessStatus() {
            if let _ = view, let _ = diffableDataSource {
                self.status = .ready
            }
        }
         */

        private(set) weak var view: CategoryListViewController? = nil  // nil until view is actually ready
        private(set) var diffableDataSource: CategoryListTableDataSource!
        var isOffscreen = true
        
        func attachView(_ view: CategoryListViewController) {
            self.view = view
            //assessStatus()
        }
        
        func attachDataSource(_ source: CategoryListTableDataSource) {
            self.diffableDataSource = source
            //assessStatus()
        }
        
    }
    

    let state = CategoryListViewModel.State()
    
    // wrap .state property for convenience of access by ViewController, DataSource
    var isOffscreen: Bool {
        set {
            self.state.isOffscreen = newValue
        }
        get {
            return self.state.isOffscreen
        }
    }
    
    
    init() {
        AppController.instance.connectCategoryListView( self )
    }

    func connectDataSource(for tableView: UITableView) {
        // Create data source and have it populate itself with data, attaching to TableView
        state.attachDataSource( CategoryListTableDataSource(tableView: tableView, ownedBy: self) )
    }

    // Called by view once fully loaded and ready
    func connectLoadedView(view: CategoryListViewController) {
        state.attachView(view)
    }
    
    func showTableDataFirstTime() {
        state.diffableDataSource.start()
    }
    
    
    func userActionEditCategory(atIndex: Int) {
        let category = AppState.instance.model.allCategories()[atIndex]
        state.view?.performSegue(withIdentifier: "EditCategory", sender: category)
    }
    
    
    // Called by table data source object when Delete option is chosen by user
    func userActionDeleteCategory(_ category: Category) {
        
        let eventsCount = category.events?.count ?? 0
        if eventsCount == 0 {
            AppController.instance.doCategoryListAction( .deleteCategory(category) )
        }
        else {
            // Confirm before removing category with events
            let messageStr = String(format: NSLocalizedString("delete-category-event-count", comment: "Category contains %i events that will be removed."), eventsCount)
            let messageTitle = NSLocalizedString("delete-nonempty-category-title", comment: "Delete category with events?")
            
            AlertViewHelper.showOkCancelDialog(
                messageTitle, message: messageStr,
                doOnOk: {
                    // Go ahead and delete
                    AppController.instance.doCategoryListAction( .deleteCategory(category) )
            },
                doOnCancel: { },
                sourceVc: self.state.view!
            )
        }
    }
    
    
    func userActionMoveCategory(_ category: Category, newIndex: Int) {
        if category.orderIndex != newIndex {
            AppController.instance.doCategoryListAction(
                .reorderCategory(category, toIndex: newIndex)
            )
        }
    }

}
