//
//  EventActionMenuResponder.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


// MARK: - <DetailActionsMenuDelegate> methods


// Collaborator for DetailViewController, handling event-action menu callbacks
//
class EventActionMenuResponder: DetailActionsMenuDelegate {
        
    weak var view: DetailViewController?
    
    init(view: DetailViewController) {
        self.view = view
    }

    
    func detailActionsMenuChoseEmail(_ sender: DetailActionsMenu) {
        view?.cancelAllPopupMenus()
        // There's only one of these on this page, so we know which object sender is
        sender.hideMenu()
        sendEventToEmail()
    }
    
    
    func detailActionsMenuChoseDelete(_ sender: DetailActionsMenu) {
        view?.cancelAllPopupMenus()
        // TODO: confirmation before delete
        view?.viewModel.deleteEvent()
    }
    
    
    func detailActionsMenuChoseInfo(_ sender: DetailActionsMenu) {
        sender.hideMenu()
        view?.performSegue(withIdentifier: "showAbout", sender: nil)
    }
    
    
    private func sendEventToEmail() {
        if let view = view {
            if AppController.canSendEmail() {
                if let event = view.viewModel.eventCurrentlyInUI {
                    var emailText = event.toEmailAsText(indent: "")
                    AppLogger().logDebug("Generated email text: \n\(emailText)")
                    
                    // Put a couple blank lines into top of email to let user have room to type an introduction:
                    emailText = "\n\n\(emailText)"
                    
                    AppController.instance.sendEmailSubject(event.title ?? "", body: emailText, from: view)
                }
            }
            else {
                AppController.notifyNoEmail(from: view)
            }
        }
        else {
            AppLogger().logWarning("Email event activated, but view = nil in EventActionMenuResponder")
        }
    }
    
}

