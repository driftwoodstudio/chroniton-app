//
//  RootSplitViewController.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit

class RootSplitViewController: UISplitViewController {

    override func viewWillAppear(_ animated: Bool) {
        //print("RootSplitViewController.viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AppState.instance.currentSelectedEvent == nil {
            AppController.instance.selectFirstEvent()
        }
    }
    
    override func viewDidLoad() {
        print("Splitview load")
        AppController.instance.connectSplitViewController( self )

        if UIDevice.current.userInterfaceIdiom == .pad {
            self.preferredDisplayMode =  UISplitViewController.DisplayMode.automatic  // .primaryHidden
        }
        else {
            self.preferredDisplayMode = UISplitViewController.DisplayMode.oneBesideSecondary
        }
        self.delegate = self
    }

}


// MARK: - Split view

extension RootSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController:UIViewController,
                             onto primaryViewController:UIViewController)
        -> Bool
    {
        if AppState.instance.currentSelectedEvent == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        else {
            return false
        }
    }

}

