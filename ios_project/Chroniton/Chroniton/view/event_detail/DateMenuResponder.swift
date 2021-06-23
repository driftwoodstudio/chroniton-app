//
//  DateMenuDelegate.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit


// MARK: - <DateActionsMenuDelegate> handlers for DetailViewController


// Collaborator for DetailViewController, handling date menu callbacks
// 
class DateMenuResponder: DateActionsMenuDelegate {
    
    weak var view: DetailViewController?
    weak var viewModel: DetailViewModel?
    
    init(view: DetailViewController) {
        self.view = view
        self.viewModel = view.viewModel
    }
    
    
    func dateActionsMenuChoseCalendar(_ sender: DateActionsMenu) {
        if let dateType = sender.userData as? DateType {
            switch dateType {
                case .lastDate:
                    view?.showCalendarForLastDate()
                case .nextDate:
                    view?.showCalendarForNextDate()
            }
        }
        else { AppLogger().logWarning("Unknown DateType value in DateActionsMenuDelegate handler") }
    }
    
    func dateActionsMenuChoseToday(_ sender: DateActionsMenu) {
        if let dateType = sender.userData as? DateType {
            switch dateType {
                case .lastDate:
                    viewModel?.lastDate = Date()
                case .nextDate:
                    viewModel?.nextDate = Date()
            }
        }
        else { AppLogger().logWarning("Unknown DateType value in DateActionsMenuDelegate handler") }
    }
    
    func dateActionsMenuChoseClear(_ sender: DateActionsMenu) {
        if let dateType = sender.userData as? DateType {
            switch dateType {
                case .lastDate:
                    viewModel?.lastDate = nil
                case .nextDate:
                    viewModel?.nextDate = nil
                }
        }
        else { AppLogger().logWarning("Unknown DateType value in DateActionsMenuDelegate handler") }
    }
    
    
    func dateActionsMenuChose1Week(_ sender: DateActionsMenu) {
        if let dateType = sender.userData as? DateType {
            switch dateType {
                case .lastDate:
                    if let date = viewModel?.lastDate {
                        viewModel?.lastDate = date.addWeeks(1)
                    }
                    else {
                        viewModel?.lastDate = Date().addWeeks(1)
                    }
                case .nextDate:
                    if let date = viewModel?.nextDate {
                        viewModel?.nextDate = date.addWeeks(1)
                    }
                    else {
                        viewModel?.nextDate = Date().addWeeks(1)
                    }
            }
        }
        else { AppLogger().logWarning("Unknown DateType value in DateActionsMenuDelegate handler") }
    }
    
    func dateActionsMenuChose1Month(_ sender: DateActionsMenu) {
        if let dateType = sender.userData as? DateType {
            switch dateType {
                case .lastDate:
                    if let date = viewModel?.lastDate {
                        viewModel?.lastDate = date.addMonths(1)
                    }
                    else {
                        viewModel?.lastDate = Date().addMonths(1)
                    }
                case .nextDate:
                    if let date = viewModel?.nextDate {
                        viewModel?.nextDate = date.addMonths(1)
                    }
                    else {
                        viewModel?.nextDate = Date().addMonths(1)
                    }
            }
        }
        else { AppLogger().logWarning("Unknown DateType value in DateActionsMenuDelegate handler") }
    }
    
    func dateActionsMenuChose3Months(_ sender: DateActionsMenu) {
        if let dateType = sender.userData as? DateType {
            switch dateType {
                case .lastDate:
                    if let date = viewModel?.lastDate {
                        viewModel?.lastDate = date.addMonths(3)
                    }
                    else {
                        viewModel?.lastDate = Date().addMonths(3)
                    }
                case .nextDate:
                    if let date = viewModel?.nextDate {
                        viewModel?.nextDate = date.addMonths(3)
                    }
                    else {
                        viewModel?.nextDate = Date().addMonths(3)
                    }
            }
        }
        else { AppLogger().logWarning("Unknown DateType value in DateActionsMenuDelegate handler") }
    }
    
    func dateActionsMenuChose6Months(_ sender: DateActionsMenu) {
        if let dateType = sender.userData as? DateType {
            switch dateType {
                case .lastDate:
                    if let date = viewModel?.lastDate {
                        viewModel?.lastDate = date.addMonths(6)
                    }
                    else {
                        viewModel?.lastDate = Date().addMonths(6)
                    }
                case .nextDate:
                    if let date = viewModel?.nextDate {
                        viewModel?.nextDate = date.addMonths(6)
                    }
                    else {
                        viewModel?.nextDate = Date().addMonths(6)
                    }
            }
        }
        else { AppLogger().logWarning("Unknown DateType value in DateActionsMenuDelegate handler") }
    }
    
    func dateActionsMenuChose1Year(_ sender: DateActionsMenu) {
        if let dateType = sender.userData as? DateType {
            switch dateType {
                case .lastDate:
                    if let date = viewModel?.lastDate {
                        viewModel?.lastDate = date.addYears(1)
                    }
                    else {
                        viewModel?.lastDate = Date().addYears(1)
                    }
                case .nextDate:
                    if let date = viewModel?.nextDate {
                        viewModel?.nextDate = date.addYears(1)
                    }
                    else {
                        viewModel?.nextDate = Date().addYears(1)
                    }
            }
        }
        else { AppLogger().logWarning("Unknown DateType value in DateActionsMenuDelegate handler") }
    }
    
}
