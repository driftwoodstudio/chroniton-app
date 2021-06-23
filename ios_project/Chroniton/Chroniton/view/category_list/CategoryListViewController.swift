//
//  CategoryViewController.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


// Full Category-set editor
// Can add, delete, rename and reorder the defined categories.
//
class CategoryListViewController: UIViewController {

    // State
    private(set) var viewModel: CategoryListViewModel!

    
    // Storyboard connection
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionsMenu: EventListActionsMenu!
    @IBOutlet weak var menuButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var debugActionsPanel: UIStackView!
    
    
    // Convenience accessor for underlying data store we draw from
    private var model: Model {
        return AppState.instance.model
    }
    

    // MARK: Init
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewModel = CategoryListViewModel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.connectDataSource(for: tableView)
        tableView.delegate = self
        actionsMenu.configure(delegate: self,
                              menuButtonImage: UIImage(named: "icon_menu")!,
                              widthConstraint: menuButtonWidthConstraint,
                              heightConstraint: menuButtonHeightConstraint)
        viewModel.connectLoadedView(view: self)
        
        // Hide actions menu if not running in debug mode
        debugActionsPanel.isHidden = !(DebugSettings.showAdminOptionsInUI)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.isOffscreen = false
        viewModel.showTableDataFirstTime()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.isOffscreen = true
        actionsMenu.hideMenu()
    }
    

    // MARK: Action Responders
    
    // Edit mode toggle on/off for TableView
    @IBAction func actionEditToggle(_ sender: UIBarButtonItem) {
        actionsMenu.hideMenu()
        if tableView.isEditing {
            sender.title = NSLocalizedString("Edit", comment: "Edit")
            tableView.setEditing(false, animated: true)
        } else {
            sender.title = NSLocalizedString("Done", comment: "Done")
            tableView.setEditing(true, animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        actionsMenu.hideMenu()
        if
            segue.identifier == "ShowEvents",
            let category = sender as? Category,
            let destinationVC = segue.destination as? EventListViewController
        {
            destinationVC.setCategory( category )
        }
        else if
            segue.identifier == "EditCategory",
            let category = sender as? Category,
            let destinationVC = segue.destination as? EditCategoryViewController
        {
            destinationVC.setCategory( category )
        }

    }
}



// MARK: - UITableViewDelegate

extension CategoryListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = model.allCategories()[indexPath.row]
        self.performSegue(withIdentifier: "ShowEvents", sender: category)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return ViewFactory.makeListHeaderView(text: self.title ?? "")
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ViewFactory.listHeaderHeight()
    }
}


// MARK: - Email generation tasks

extension CategoryListViewController {
    
    // Show action sheet that will then use callbacks vi ActionSheetMenuListener protocol.
    func _showEmailActionSheetMenu() {
        
        if AppController.canSendEmail() {
            
            let CSV_CHOICE_STRING = NSLocalizedString("menu-item-csv", comment: "Action Sheet menu item")
            let TEXT_CHOICE_STRING = NSLocalizedString("menu-item-plainText", comment: "Action Sheet menu item")
            
            let option1 = AlertViewButtonPackage(title: CSV_CHOICE_STRING, action: { self._doEmailDataAsCSV() })
            let option2 = AlertViewButtonPackage(title: TEXT_CHOICE_STRING, action: { self._doEmailDataAsText() })
            
            AlertViewHelper.showMultipleButtons(
                title: NSLocalizedString("EmailEventsPopupTitle", comment: "Popup action menu title"),
                message: nil,
                buttons: [option1, option2],
                cancelAction: {}, // non-nil cancel, so appears but does nothing when chosen
                sourceVc: self)
        }
        else {
            AppController.notifyNoEmail(from: self)
        }
    }
    
    
   func _doEmailDataAsCSV() {
        var dataLines = model.toCsvString()
        dataLines = Model.csvHeaderLine() + dataLines
        AppController.instance.sendCsvData(asEmail: dataLines, from: self)
    }
    
    
    func _doEmailDataAsText() {
        var emailText = model.toEmailAsText()
        AppLogger().logDebug("Generated email text is:\n\(emailText)")
        
        // Put a couple blank lines into top of email to let user have room to type an introduction:
        emailText = "\n\n\(emailText)"
        
        AppController.instance.sendEmailSubject(NSLocalizedString("email-subject-text", comment: "Email subject line"), body: emailText, from: self)
    }
    
}


// MARK: - <EventListActionsMenuDelegate>

extension CategoryListViewController: CategoryListActionsMenuDelegate {
    
    func listActionsMenuChoseNew(_ sender: EventListActionsMenu?) {
        actionsMenu.hideMenu()
        
        AlertViewHelper.showTextInput(
            withMessage: nil,
            title: NSLocalizedString("Category Name", comment: "Category name prompt"),
            placeholderText: NSLocalizedString("Category Name", comment: "Category name prompt"),
            defaultText: "",
            doOnOk: { enteredText in
                if enteredText != nil && (enteredText?.count ?? 0) > 0 {
                    AppController.instance.doCategoryListAction( .addCategory(enteredText!) )
                }
            },
            doOnCancel: {
                AppLogger().logDebug("Category add canceled")
            },
            sourceVc: self
        )
    }
    
    func listActionsMenuChoseSend(_ sender: EventListActionsMenu?) {
        actionsMenu.hideMenu()
        _showEmailActionSheetMenu()
    }
    
    func listActionsMenuChoseInfo(_ sender: EventListActionsMenu?) {
        actionsMenu.hideMenu()
        performSegue(withIdentifier: "showAbout", sender: nil)
    }
    
}


// MARK: - Test/Debug handlers

extension CategoryListViewController {
    
    // Button respnders for buttons visible when running app in test/debug mode.
    // Not normally visible in app. Testing only.
    
    @IBAction func _test_deleteAllData(_ sender: Any) {
        AppLogger().logDebug("TEST: deleting all data")
        AppState.instance.model._test_deleteAllData()
        AppSettings.sharedInstance.hasRunBeforOnThisDevice = false
        AppState.instance.model._log()
    }
    
    @IBAction func _test_logData(_ sender: Any) {
        AppState.instance.model._log()
    }
    
    @IBAction func _test_resetModel(_ sender: Any) {
        AppLogger().logDebug("TEST: deleting all data and recreating just Test Data")
        
        AppState.instance.model._test_deleteAllData()
        
        // Do same data generation as AppController.optionallyCreateDefaultData()
        //DataGenerator.createHelpCategory(into: AppState.instance.model)
        DataGenerator.createTestCategories(into: AppState.instance.model)
        
        AppLogger().logDebug("TEST: deleted all data then DataGenerator.createExampleData()")
        AppState.instance.model._log()
    }
    
}
