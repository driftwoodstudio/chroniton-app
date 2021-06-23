//
//  DetailViewController.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


class DetailViewController: UIViewController {

    private(set) var viewModel: DetailViewModel!
    

    // -----  UI  -----

    @IBOutlet weak var outletTitle: UITextField!
    @IBOutlet weak var outletCategoryName: DecoratedUILabel!
    @IBOutlet weak var outletLastDate: UITextField!
    @IBOutlet weak var outletNextDate: UITextField!
    @IBOutlet weak var outletNotes: DecoratedUITextView!
    @IBOutlet weak var outletCoverLabel: UILabel!
    @IBOutlet weak var outletDaysAgoLabel: UILabel!
    @IBOutlet weak var outletDaysFromNowLabel: UILabel!
    
    @IBOutlet weak var dateImageStack: UIStackView!
    @IBOutlet weak var outletImageView: UIImageView!

    private var dateMenuResponder: DateMenuResponder!
    private var eventActionMenuResponder: EventActionMenuResponder!
    
    // iPadPopup storage so we can dismiss it programmatically
    weak var activePopover: UIViewController?
    
    @IBOutlet weak var detailActionsMenu: DetailActionsMenu!
    @IBOutlet weak var detailMenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailMenuHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lastDateAnimator: DateActionsMenu!
    @IBOutlet weak var lastDateActionWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastDateActionHightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextDateAnimator: DateActionsMenu!
    @IBOutlet weak var nextDateActionWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextDateActionHightConstraint: NSLayoutConstraint!

    // Keyboard show/hide helper
    private var keyboardHelper: DWKeyboardHelper?
    
    
    
    // MARK: - Initalization

    
    // ----  Managed collaborators  ----
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Note: at this point, app is likely still launching (if running in iPad, as this
        // is the "main" screen in ipad launch).
        // As such, you can't assume any data is available/loaded, etc.
        // Later will come a call to display a specific event.
        
        viewModel = DetailViewModel()
        
        // Helpers that will handle callbacks from date-manipulation popup controls
        self.dateMenuResponder = DateMenuResponder(view: self)
        self.eventActionMenuResponder = EventActionMenuResponder(view: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _configurePopupMenuControls()
        _tweakInputControlAppearances()
        keyboardHelper = DWKeyboardHelper(baseView: self.view)
        keyboardHelper!.registerForKeyboardNotifications()
        // Note that self.view doesn't have a valid frame yet, so will need to update
        // the keyboard helper's state to know about new frame when it becomes available.
        // Could avoid this if there were a good init point *after* self.view.frame is valid.
    
        if let nav = self.navigationController {
            nav.topViewController?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            nav.topViewController?.navigationItem.leftItemsSupplementBackButton = true
        }
        
        viewModel.connectLoadedView(view: self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.showEvent()
        
        if view.frame.width > 500 {
            dateImageStack.axis = .horizontal
            dateImageStack.distribution = .fillProportionally// .fillEqually
            dateImageStack.alignment = .top
        }
        else {
            dateImageStack.axis = .vertical
            dateImageStack.distribution = .fill
            dateImageStack.alignment = .center
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        cancelAllPopupMenus()
        save()
    }
    
    
    // Copy current UI values into backing Event object
    // (anything not automatically pushed into Model by user interaction to enter value)
    private func save() {
        // Skip if no event being edited
        if viewModel.eventCurrentlyInUI == nil { return }
        // Copy values:
        viewModel.title = self.outletTitle.text ?? ""
        viewModel.notes = self.outletNotes.text
        // All other fields update model live when changed, so no copying needed here
    }
    
    func _tweakInputControlAppearances() {
        outletCategoryName?.setEdgeInsets( UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 5) )
        outletCategoryName?.setCornerRadius(5.0, borderColor: UIColor.lightGray, borderWidth: 1.0)
        outletNotes.setCornerRadius(5.0, borderColor: UIColor.lightGray, borderWidth: 1.0)
    }
    
    
    func _configurePopupMenuControls() {
        
        // Actions Menu
        // (we'll fix accurate frame origin in viewDidLayoutSubviews:)
    
        let buttonImg = UIImage(named: "icon_menu")!
        
        detailActionsMenu.configure(delegate: self.eventActionMenuResponder,
                                    menuButtonImage: buttonImg,
                                    widthConstraint: detailMenuWidthConstraint,
                                    heightConstraint: detailMenuHeightConstraint )
        
 
        let calendarImg = UIImage(named: "icon_calendar")!
        
        // Last Date menu
        lastDateAnimator.configure(delegate: dateMenuResponder,
                                   menuButtonImage: calendarImg,
                                   widthConstraint: lastDateActionWidthConstraint,
                                   heightConstraint: lastDateActionHightConstraint,
                                   userData: DateType.lastDate)

        // Next Date menu
        nextDateAnimator.configure(delegate: dateMenuResponder,
                                   menuButtonImage: calendarImg,
                                   widthConstraint: nextDateActionWidthConstraint,
                                   heightConstraint: nextDateActionHightConstraint,
                                   userData: DateType.nextDate)
    }

    
    
    // MARK: - GUI Actions
    
    
    // Responder for TouchGestureRecognizer on base View
    @IBAction func touchAction(_ sender: Any) {
        // User tapped something that didn't trap event, so most likely keyboard dismiss tap
        view.endEditing(true)
        cancelAllPopupMenus()
    }
    

    // Show menu when user touches last-date field
    @IBAction func actionChooseLastDate(_ sender: Any) {
        dateMenuResponder.dateActionsMenuChoseCalendar( lastDateAnimator )
    }
    
    // Show menu when user touches next-date field
    @IBAction func actionChooseNextDate(_ sender: Any) {
        dateMenuResponder.dateActionsMenuChoseCalendar( nextDateAnimator )
    }
    
    @IBAction func actionChooseCategory(_ sender: Any) {
        view.endEditing(true)
        self.performSegue(withIdentifier: "chooseCategory", sender: nil)
    }
}


// MARK: - Text entry change listeners

extension DetailViewController: UITextFieldDelegate, UITextViewDelegate {

    // Protocol-specified notificaton method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        _textEditStarted(on: textField)
    }
    
    // Protocol-specified notificaton method
    func textFieldDidEndEditing(_ textField: UITextField) {
        save()
        _textEditEnded(on: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    // Protocol-specified notificaton method
    func textViewDidBeginEditing(_ textView: UITextView) {
        _textEditStarted(on: textView)
    }
    
    // Protocol-specified notificaton method
    func textViewDidEndEditing(_ textView: UITextView) {
        save()
        _textEditEnded(on: textView)
    }
    

    private func _textEditStarted(on textEditControl: UIView) {
        AppLogger().logTrace("Start edit for: \(textEditControl)")
        keyboardHelper?.textInputViewDidBeginEditing(textEditControl)
    }
    
    private func _textEditEnded(on textEditControl: UIView) {
        AppLogger().logTrace("End edit for: \(textEditControl)")
        keyboardHelper?.textInputViewDidEndEditing(textEditControl)
    }
}


// MARK: - Incoming External Notifications

// Come from auxillary/helper screens

extension DetailViewController {
    
    // FIXME: verify: is this used? (check after fixing List view Edit mode for moving events)
    // Notification that move has already happened, need to update state/display accordingly
    // (not the same as user picking a new category! this is an after-the-fact notification of did-happen-already)
    func notifyEventWasMoved(toNewCategory newCategory: Category) {
        outletCategoryName.text = newCategory.name
    }
    
    // Notification from the Category Picker view that new category chosen for current event
    func notifyCategoryPickerMadeSelection(_ newCategory: Category) {
        viewModel?.setNewEventCategory( newCategory )
    }
    
    //  Notification from choose-image screen that image was set or cleared
    func notifyImageChanged(_ newImage: UIImage?) {
        viewModel?.image = newImage
    }
}


// MARK: - Segue to Subviews

extension DetailViewController {
    
    // Handle transition to notes editing page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "chooseCategory") {
            if let receiver = segue.destination as? PickCategoryViewController {
                if viewModel.eventCurrentlyInUI == nil { return }
                receiver.initialCategory = viewModel.eventCurrentlyInUI!.category!
                receiver.receiverForChanges = self
                if GuiUtils.deviceIsPad() {
                    activePopover?.dismiss(animated: true) // Dismiss if not nil
                    activePopover = segue.destination
                }
            }
        }
        else if (segue.identifier == "imageChooseView") {
            if let receiver = segue.destination as? ImageViewController {
                receiver.setWorkingImage( viewModel?.image )
                receiver.receiverForChanges = self
            }
        }
        else if segue.identifier == "chooseDate" {
            if
                let destination = segue.destination as? DWDatePickerViewController,
                let inputs = sender as? DateSelectionInputs
            {
                if let sourceView = inputs.sourceView {
                    destination.popoverPresentationController?.sourceView = sourceView
                    destination.popoverPresentationController?.sourceRect = sourceView.bounds
                }
                destination.setInitialDate( inputs.initialDate )
                destination.userData = inputs  // So it can access it during callback
                destination.delegate = self
            }
        }
    }
    
}



// MARK: - Common delegate methods

extension DetailViewController {
    
    // Delegate methods common to all subclasses of AnimatedMenu
    
    func menuOpening(_ sender: AnimatedMenu) {
        // User opening new menu, cancel anything else already in progress
        
        view.endEditing(true) // Will trigger response code to save value
        _cancelAllPopupMenusExcept(sender)
    }
    
    // Optional, we don't care about this:
    // - (void) menuClosing:(id)sender { }
}





// MARK: - Show data values in UI

extension DetailViewController {
    
    func showEvent(_ event: Event?) {
        if let e = event {
            let title = e.title ?? "(no title)"
            AppLogger().logTrace("DetailView.ShowEvent() is being invoked, with event '\(title)'",
                                 addCallStack: false)
        }
        else {
            AppLogger().logTrace("DetailView.ShowEvent() is being invoked, with NIL event",
                                 addCallStack: false)
        }

        DispatchQueue.main.async {
            /*
            AppLogger().logDebug(
                "showEvent() with:"
                + "\n.eventCurrentlyInUI = \n\(self.viewModel.eventCurrentlyInUI)"
                + "\nstate.currentEvent = \n\(AppState.instance.currentSelectedEvent)"
            )
            */
            if let e = event {
                self.showNewTitle( e.title )
                self.showNewCategory( e.category! )
                self.showNewLastDate( e.lastDate )
                self.showNewNextDate( e.nextDate )
                self.showNewImage( ImageManager.inflate(data: e.imageData) )
                self.showNewNotes( e.notes )
                self._configureGuiToDisplayEvent()
            }
            else {
                self.showNewTitle( nil )
                self.showNewCategory( nil )
                self.showNewLastDate( nil )
                self.showNewNextDate( nil )
                self.showNewImage( nil )
                self.showNewNotes( nil )
                self._configureGuiToDisplayNothing()
            }
        }
    }
        
    // Copy values to UI
    // Nil values mean "show blank value"
    
    func showNewTitle(_ value: String?) {
        outletTitle.text = value
    }
    
    func showNewCategory(_ category: Category?) {
        outletCategoryName.text = category?.name ?? ""
    }
    
    func showNewLastDate(_ date: Date?) {
        outletLastDate.text = DateStrHelper.toString( date )

        let intervalStr = DateStrHelper.relativeIntervalString(from: Date(), to: date)
        if let str = intervalStr, str != "" {
            outletDaysAgoLabel.text = "(\(str))"
        } else {
            outletDaysAgoLabel.text = ""
        }
    }
    
    func showNewNextDate(_ date: Date?) {
        outletNextDate.text = DateStrHelper.toString( date )
        
        let intervalStr = DateStrHelper.relativeIntervalString(from: Date(), to: date)
        if let str = intervalStr, str != "" {
            outletDaysFromNowLabel.text = "(\(str))"
        } else {
            outletDaysFromNowLabel.text = ""
        }
    }

    func showNewImage(_ image: UIImage?) {
        if let image = image {
            AppLogger().logDebug("App is showing image: \(image)")
            outletImageView.image = image
        } else {
            AppLogger().logDebug("App is showing stock image")
            outletImageView.image = UIImage(named: "stock_image")
        }
    }
    
    func showNewNotes(_ value: String?) {
        self.outletNotes.text = value
    }
    
    
    // Adjust UI size/position to be the "no current event" version
    private func _configureGuiToDisplayEvent() {
        outletCoverLabel.text = ""
        outletCoverLabel.isHidden = true
    }
    
    // Adjust UI size/position to be the standard "showing event data" version
    private func _configureGuiToDisplayNothing() {
        outletCoverLabel.text = NSLocalizedString("no event caption", comment: "")
        outletCoverLabel.isHidden = false
    }
    
}



// MARK: - UI Behavior Helpers


extension DetailViewController {
    
    func showCalendarForLastDate() {
        view.endEditing(true) // Will trigger handler code to save value
        cancelAllPopupMenus()
        let inputs = DateSelectionInputs(
            initialDate: viewModel.lastDate,
            dateType:    .lastDate,
            sourceView:  outletLastDate
        )
        self.performSegue(withIdentifier: "chooseDate", sender: inputs)
    }
    
    func showCalendarForNextDate() {
        view.endEditing(true) // Will trigger handler code to save value
        cancelAllPopupMenus()
        let inputs = DateSelectionInputs(
            initialDate: viewModel.nextDate,
            dateType:    .nextDate,
            sourceView:  outletNextDate
        )
        self.performSegue(withIdentifier: "chooseDate", sender: inputs)
    }
    
    
    func cancelAllPopupMenus() {
        // These return very quickly if menu is not up, so no need to check state
        detailActionsMenu?.hideMenu()
        nextDateAnimator?.hideMenu()
        lastDateAnimator?.hideMenu()
    }
    
    private func _cancelAllPopupMenusExcept(_ menuToLeaveUntouched: AnimatedMenu) {
        if menuToLeaveUntouched !== detailActionsMenu {
            detailActionsMenu?.hideMenu()
        }
        if menuToLeaveUntouched !== nextDateAnimator {
            nextDateAnimator?.hideMenu()
        }
        if menuToLeaveUntouched !== lastDateAnimator {
            lastDateAnimator?.hideMenu()
        }
    }

}


// Delegate for Calendar picker, invoked when Calendar UI has finalized a date selection
extension DetailViewController: DWDatePickerDelegate {
        
    struct DateSelectionInputs {
        let initialDate: Date?
        let dateType: DateType   // used in result so receiver can determine what to do with result
        let sourceView: UIView?  // Anchor for popup
    }
        
    
    func dwDatePickerDidCancel(_ picker: DWDatePickerViewController ) {
        AppLogger().logTrace("Detail view: date picker cancelled")
    }
    
    
    func dwDatePicker(_ picker: DWDatePickerViewController, choseDate date: Date) {
        AppLogger().logTrace("Detail view: dwDatePicker(_, choseDate: )")
        if let inputs = picker.userData as? DateSelectionInputs  {
            switch inputs.dateType {
                case .lastDate:
                    showNewLastDate( date )
                    viewModel.lastDate = date
                case .nextDate:
                    showNewNextDate( date )
                    viewModel.nextDate = date
            }
        }
        else {
            AppLogger().logWarning("dwDatePicker(choseDate:) called with picker that has no reference inputs in .userData")
        }
    }
    
}
