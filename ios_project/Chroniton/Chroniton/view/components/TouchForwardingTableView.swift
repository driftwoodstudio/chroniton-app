//
//  TouchForwardingTableView.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//


import UIKit


class TouchForwardingTableView: UITableView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
        super .touchesBegan(touches, with: event)
    }
}
