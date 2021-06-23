//
//  LocalizationHelper.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import Foundation


public class LocalizationHelper {
    
    private static var _cachedNumberFormatter: NumberFormatter? = nil
    
    private class func _getNumberFormatter() -> NumberFormatter {
        if _cachedNumberFormatter == nil {
            _cachedNumberFormatter = NumberFormatter()
            _cachedNumberFormatter!.locale = NSLocale.current
        }
        return _cachedNumberFormatter!
    }
    
    public class func localizedIntString(_ intVal: Int) -> String {
        let n = intVal
        let s = self._getNumberFormatter().string(for: n)
        return s ?? ""
    }
    
}

