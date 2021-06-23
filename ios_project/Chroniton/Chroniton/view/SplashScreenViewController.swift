//
//  SplashScreenViewController.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    @IBOutlet weak var optionsStack: UIStackView!
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startupApp()
    }

    // Step 1
    func startupApp() {
        StartupController.doAppStartupActions {
            DispatchQueue.main.async {
                // Enable buttons now that controller has initialized app state
                for b in self.buttons { b.isEnabled = true }
                self.checkFirstTimeRun()
            }
        }
    }
    
    // Step 2
    func checkFirstTimeRun() {
        DispatchQueue.main.async {
            if StartupController.isFirstRun {
                AppLogger().logDebug("Never run before on this device, will present user with init options")
                self.optionsStack.isHidden = false
                // wait for user action
            }
            else {
                AppLogger().logDebug("Run before on this device, skipping user actions prompt")
                self.navigateNext()
            }
        }
    }
    
    
    // Step 3a
    // User action responder: Create help data
    @IBAction func doCreateDataPath(_ sender: Any) {
        AppLogger().logTrace("SplashScreen: Doing local data create")
        StartupController.doFirstRunOperations {
            self.navigateNext()
        }
    }
    
    // Step 3b
    // User action responder: skip data creation
    @IBAction func doSyncPath(_ sender: Any) {
        AppLogger().logTrace("SplashScreen: Skipping data creation -- but will still sync from iCloud")
        self.navigateNext()
    }
    

    // Step 4
    // Exit point: go to main screen of app
    func navigateNext() {
        DispatchQueue.main.async {
            
            // Either run before, or not-before but user has chosen an option. Never show options again.
            AppSettings.sharedInstance.hasRunBeforOnThisDevice = true
            
            AppLogger().logDebug("SplashScreen.navigateNext() is ready to move to main screen")
            self.performSegue(withIdentifier: "GotoMain", sender: nil)
        }
    }
}
