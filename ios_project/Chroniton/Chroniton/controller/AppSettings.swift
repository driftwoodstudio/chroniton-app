//
//  AppSettings.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import DWLib


// App settings storage in iOS UserDefaults via convencience superclass methods in DWUserDefaults wrapper
class AppSettings: DWUserDefaults {

    static let sharedInstance = AppSettings()

    override init() {
        super.init()
    }

    private static let KEY_SHOW_BADGE = "enableBadge_preference"
    private static let KEY_BADGE_DAY_COUNT = "badgeDays_preference"
    private static let KEY_HAS_RUN_BEFORE = "hasRunBeforeOnThisDevice"

    
    var hasRunBeforOnThisDevice: Bool {
        get {
            // false if no UserDefaults item exists for this key
            return getBool(AppSettings.KEY_HAS_RUN_BEFORE)
        }
        set {
            setBool(AppSettings.KEY_HAS_RUN_BEFORE, value: newValue)
        }
    }
    
    var badgeOn: Bool {
        get {
            return getBool(AppSettings.KEY_SHOW_BADGE)
        }
        set {
            setBool(AppSettings.KEY_SHOW_BADGE, value: newValue)
        }
    }
    
    var badgeDays: Int {
        get {
            return getInt(AppSettings.KEY_BADGE_DAY_COUNT)
        }
        set {
            setInt(AppSettings.KEY_BADGE_DAY_COUNT, value: newValue)
        }
    }
    
}


// Debug settings that should be turned off for release
struct DebugSettings {
    static let showAdminOptionsInUI = false
    static let shouldCreateTestData = false
    static let shouldCreateAutomotiveCategoryData = true
}
