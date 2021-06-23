//
//  ImageZoomController.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit

class ImageZoomControllerIPadViewController: UIViewController, ImageReceiver {

    private var workingImage: UIImage?
    
    @IBOutlet private weak var outletImageView: UIImageView!

    
    override func viewDidAppear(_ animated: Bool) {
        outletImageView.image = workingImage
    }

    
    // <ImageReceiver>
    func setWorkingImage(_ image: UIImage?) {
        workingImage = image
    }

}
