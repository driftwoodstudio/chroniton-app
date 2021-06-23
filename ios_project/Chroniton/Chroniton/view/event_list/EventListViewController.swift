//
//  EventListViewController.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


class EventListViewController: UIViewController
{

    // State
    private(set) var viewModel: EventListViewModel!
    var tableDelegate: EventListTableDelegate? = nil

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var outletEditButton: UIBarButtonItem!  // To toggle Edit mode on/off for TableView


    // MARK: - View Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewModel = EventListViewModel()
    }

    func setCategory(_ category: Category) {
        viewModel.setCategory( category )
        tableDelegate = EventListTableDelegate(forCategory: category)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        viewModel.conectDataSource(for: tableView)  // needs category, as data is "Events in category X"

        tableDelegate?.owner = self
        tableView.delegate = tableDelegate
        
        viewModel.connectLoadedView( self )
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.isOffscreen = false
        viewModel.refreshTableDisplay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.isOffscreen = true
        // Cancel table edit if it was left in progress
        if tableView.isEditing {
            actionEditToggle(outletEditButton)
        }
    }
    
        
    // Show a row in the TableView as selected, but without triggering the workflow
    // for "user selected an event"
    func showAsSelectedVisual(_ event: Event?) {
        if let e = event {
            let path = IndexPath(row: Int(e.orderIndex), section: 0)
            tableView.selectRow(at: path, animated: true, scrollPosition: .none)
            if let cell = tableView.cellForRow(at: path) as? EventListCell {
                cell.setSelected(true, animated: true)
            }
        }
        else {
            tableView.selectRow(at: nil, animated: false, scrollPosition: .top)
        }
    }
    
        
    
    // MARK: - User Action Responders
    
    
    @IBAction func actionEditToggle(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            sender.title = NSLocalizedString("Edit", comment: "Edit")
            tableView.setEditing(false, animated: true)
            tableView.reloadData()
        } else {
            sender.title = NSLocalizedString("Done", comment: "Done")
            tableView.setEditing(true, animated: true)
        }
    }


    func activateEventAtRow(_ row: Int) {
        viewModel.activateEventAtIndex( row )
    }
    
        
    @IBAction func actionAddButton(_ sender: Any) {
        viewModel.addEvent()
    }

}

