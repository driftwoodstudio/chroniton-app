//
//  PickCategoryViewController.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit


// Simple version of category list, used when editing an event
// to select a new category for the event
// 
class PickCategoryViewController: UIViewController,
    UIAlertViewDelegate,
    UITableViewDelegate, UITableViewDataSource
{
    
    // Can be set by presenters to cause an initial selection. Ignored after load complete.
    var initialCategory: Category?
    // Who to notify if new value chosen
    var receiverForChanges: DetailViewController?
    
    // UI outlet
    @IBOutlet weak var tableView: UITableView!
    
    
    private var model: Model {
        get {
            return AppState.instance.model
        }
    }
    
    
    // Select current category choice in list
    func visualSyncCategoryChoice() {

        let name = initialCategory?.name
        AppLogger().logDebug("visualSyncCategoryChoice: category = \(String(describing: initialCategory)) (\(String(describing: name)))")
        
        if let category = initialCategory {
            let index = Int(category.orderIndex)
            let path = IndexPath(row: index, section: 0)
            AppLogger().logDebug("visualSyncCategoryChoice: path = \(path)")
            tableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        }
    }
    
    
    // MARK: - GUI Event Handlers
    
 
    @IBAction func actionCancel(_ sender: Any) {
        // Exit with NO sending of selection to receiver
        self._exit()
    }
    
    
    private func _exit() {
        self.dismiss(animated: true, completion: nil)
    }

    
    // Record user's new choice
    // Effect: send new choice to Receiver and exit this screen immediately
    func actionNewCategoryChosen(_ newCategory: Category) {
        DispatchQueue.main.async {
            AppLogger().logDebug("Item selected: name = \(newCategory.name!)")
            if newCategory != self.initialCategory {
                self.receiverForChanges?.notifyCategoryPickerMadeSelection( newCategory )
            }
            self._exit()
        }
    }
    
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.allCategories().count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CategoryPickerCell")!
        
        let c = model.allCategories()[indexPath.row]
        
        let label = cell.textLabel!
        
        label.text = c.name
        if let font = UIFont(name: "GillSans", size: 20.0) {
            label.font = font
        }
        label.highlightedTextColor = label.textColor
        label.backgroundColor = UIColor.clear
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppLogger().logDebug("Item selected: path = \(indexPath)")
        let c = model.allCategories()[indexPath.row]
        actionNewCategoryChosen(c)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        visualSyncCategoryChoice()
    }
    
}
