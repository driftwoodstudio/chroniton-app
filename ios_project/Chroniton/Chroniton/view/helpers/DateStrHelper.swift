//
//  DateStrHelper.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import Foundation
import DWLib


class DateStrHelper {
    
    // Generate app-standard string from date (short format for current locale)
    public class func toString(_ date: Date?) -> String {
        if let d = date {
            return d.asShortFormatString()
        }
        return ""
    }
    
    // Generate from app-standard string (assuming str is short format for current locale)
    public class func toDate(_ string: String?) -> Date? {
        if let s = string {
            return s.asDateFromLocalShortFormatString()
        }
        return nil
    }

    // Given a string, try to interpret it as a date and return it in app-standard format
    // If string can't be understood as a date (or is blank/nil), return ""
    class func normalizeDateStr(_ dateStr: String?) -> String {
        // TODO: allow other date formats as input (i.e. try long format, etc)
        if let s = dateStr, let date = s.asDateFromLocalShortFormatString() {
            return date.asShortFormatString()
        }
        else {
            return ""
        }
    }

    
    // Given an app-standard string, return true if it's a date representation.
    // If allowBlank, will return true if input string is either nil or blank.
    class func isValidDate(_ dateStr: String?, allowBlank: Bool) -> Bool {
        if let str = dateStr {
            // non-nil dateStr
            if allowBlank && str == "" { return true }
            if let _ = str.asDateFromLocalShortFormatString() {
                return true
            }
            else {
                return false
            }
        }
        else {
            // datestr is nil
            if allowBlank { return true }
            return false
        }
    }
    
    
    /*!
     Construct localized string representation of where a date falls relative to today.
     The string is in words, such as "5 days ago" or "10 days from now".
     Both the integer format and the text used are localized using .strings file and
     current device default locale.
     */
    class func relativeIntervalString(from dateFrom: Date?, to dateTo: Date?) -> String? {
        if dateFrom == nil || dateTo == nil {
            return ""
        }
        
        var days = dateFrom!.dayInterval(fromDate: dateTo!)
                
        if days == 0 {
            return NSLocalizedString("today", comment: "Today")
        }
        else if days > 0 {
            // From-date is in the past
            
            let daysStr = LocalizationHelper.localizedIntString(days)
            if days == 1 {
                return NSLocalizedString("yesterday", comment: "1 day ago")
            }
            else {
                let formatStr = NSLocalizedString("%@ days ago", comment: "%@ days ago")
                return String(format: formatStr, daysStr)
            }
        }
        else {
            // From-date is in the future
            
            // Fix "negative days ago" to "positive days from now"
            days = -days
            
            let daysStr = LocalizationHelper.localizedIntString(days)
            if days == 1 {
                return NSLocalizedString("tomorrow", comment: "1 day from now")
            } else {
                let formatStr = NSLocalizedString("in %@ days", comment: "x days from now")
                return String(format: formatStr, daysStr)
            }
        }
    }
    
    
    // String -> date -> math -> String macros for strings representing date values
    
    
    class func weekPlus(_ existingVal: String?) -> String {
        let d = _toDateOrTodayIfInvalid( existingVal )
        return d.addWeeks(1).asShortFormatString()
    }
    
    class func monthPlus(_ existingVal: String?) -> String {
        let d = _toDateOrTodayIfInvalid( existingVal )
        return d.addMonths(1).asShortFormatString()
    }
    
    class func monthPlus(_ existingVal: String?, times num: Int) -> String {
        let d = _toDateOrTodayIfInvalid( existingVal )
        return d.addMonths(num).asShortFormatString()
    }
    
    class func yearPlus(_ existingVal: String?) -> String {
        let d = _toDateOrTodayIfInvalid( existingVal )
        return d.addYears(1).asShortFormatString()
    }
    
    class func _toDateOrTodayIfInvalid(_ dateString: String?) -> Date {
        guard let inStr = dateString else { return Date() }
        guard let d = DateStrHelper.toDate(inStr) else { return Date() }
        return d
    }
    
    
    // Default date value strings
    
    class func today() -> String {
        return Date().asShortFormatString()
    }
    
    class func none() -> String {
        return ""
    }
    
}

