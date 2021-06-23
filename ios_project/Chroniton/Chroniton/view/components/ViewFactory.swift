//
//  ViewFactory.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit

class ViewFactory {

    // Build white view with red horizontal banner over it
    class func makeListHeaderView(text: String) -> UIView {

        // Container
        let view = UIView()

        // Red bar
        let barImg = UIImageView(image: UIImage(named: "red_bar"))
        barImg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barImg)
        
        // Label on bar
        let label = UILabel()
        label.textColor = UIColor.white
        if let aSize = UIFont(name: "GillSans-Bold", size: 15.0) {
            label.font = aSize
        }
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        // Set constraints in container
        let views = ["label": label, "bar": barImg, "view": view]
        let barHConstraints =
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bar]-50-|",
                                           options: .alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(barHConstraints)
        let barVConstraints =
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bar]-5-|",
                                           options: .alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(barVConstraints)
        let labelHContraints =
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[label]-60-|",
                                           options: .alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(labelHContraints)
        let labelVConstraints =
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[label]-5-|",
                                           options: .alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(labelVConstraints)

        return view
    }
    
    class func listHeaderHeight() -> CGFloat {
        return 60
    }
}
