//
//  EditCategoryViewController.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


class EditCategoryViewController: UIViewController {

    private var category: Category? = nil
    private var isDeleting = false
    
    @IBOutlet weak var nameText: UITextField!
    
    func setCategory(_ category: Category) {
        self.category = category
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameText.text = category?.name
    }

    
    // Save:
    // Apply new edited field values on the way out
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isDeleting {
            if let newName = nameText.text, newName != "" {
                AppController.instance.doCategoryListAction(
                    .renameCategory(category!, newName)
                )
            }
        }
    }
    
    
    @IBAction func doDelete(_ sender: Any) {
        
        if let c = self.category {
            let eventsCount = c.events?.count ?? 0
            
            if eventsCount == 0 {
                self._finalizeDeleteCategory( c )
            }
            else {
                // Confirm before removing category with events
                let messageStr = String(format: NSLocalizedString("delete-category-event-count", comment: "Category contains %i events that will be removed."), eventsCount)
                let messageTitle = NSLocalizedString("delete-nonempty-category-title", comment: "Delete category with events?")
                
                AlertViewHelper.showOkCancelDialog(
                    messageTitle, message: messageStr,
                    doOnOk: {
                        // Go ahead and delete
                        self._finalizeDeleteCategory(c)
                    },
                    doOnCancel: { },
                    sourceVc: self
                )
            }
        }
    }
    
    private func _finalizeDeleteCategory(_ category: Category) {
        self.isDeleting = true // should block any attempts to save edited fields during exit
        AppController.instance.doCategoryListAction( .deleteCategory(category) )
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
