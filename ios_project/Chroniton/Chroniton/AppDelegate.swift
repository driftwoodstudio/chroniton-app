//
//  AppDelegate.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


// Global convenience wrapper for app-wide logging
func AppLogger() -> DWLogger {
    return (UIApplication.shared.delegate as! AppDelegate).appLogger
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var appLogger = DWLogManager.defaultLogger()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DWLogManager.enableAll()
        // DWLogManager.disableAll()
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.

        // Set badge if turned on
        if AppSettings.sharedInstance.badgeOn {
            let days: Int = AppSettings.sharedInstance.badgeDays
            let count: Int = AppState.instance.badgeCount( days )
            if count > 0 {
                UIApplication.shared.applicationIconBadgeNumber = count
            } else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    

    func applicationDidEnterBackground(_ application: UIApplication) {
        AppController.instance.saveModel()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        AppController.instance.saveModel()
    }

    
    // MARK: UISceneSession Lifecycle
    
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    

}

