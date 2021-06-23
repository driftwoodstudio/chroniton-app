//
//  EventListTableDelegate.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit

class EventListTableDelegate: NSObject, UITableViewDelegate {

    private let category: Category?
    
    init(forCategory: Category) {
        self.category = forCategory
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ViewFactory.listHeaderHeight()
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let name = category?.name ?? "ERROR: category.name nil"
        return ViewFactory.makeListHeaderView(text: name)
    }
    
    
    
    // The owner of this delegate object, the ViewController we are managing the table for
    weak var owner: EventListViewController? = nil
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        owner?.activateEventAtRow( indexPath.row )
    }

}
