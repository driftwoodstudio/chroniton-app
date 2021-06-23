//
//  ImageViewController.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


// Allows user to select/clear image associated with an Event
// then notify a listener that the image was set to something new
//
// Used by Event detail/edit screen to change Event's image
//
class ImageViewController: UIViewController, ImagePickerWorkerDelegate, ImageReceiver {

    var workingImage: UIImage?
    var receiverForChanges: DetailViewController?
    var imagePickerWorker: ImagePickerWorker?

    @IBOutlet weak var outletImageView: UIImageView!
    @IBOutlet weak var outletImageBackground: UILabel!

    @IBOutlet weak var outletClearButton: DecoratedUIButton!
    @IBOutlet weak var outletPictureButton: DecoratedUIButton!
    @IBOutlet weak var outletCameraButton: DecoratedUIButton!
    
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if DWCamera.isCameraAvailable() {
            outletCameraButton.isHidden = false
        } else {
            outletCameraButton.isHidden = true
        }
        
        imagePickerWorker = ImagePickerWorker(controllingView: self, delegate: self, imageSize: CGSize(width: 300, height: 300))
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // workingImage is generally set before view fully loads
        self.displayWorkingImage()
    }
    
    
    private func displayWorkingImage() {
        if self.outletImageView != nil {
            DispatchQueue.main.async {
                self.outletImageView.image = self.workingImage
            }
        }
    }
    

    
    // MARK: - <ImageReceiver>
    
    func setWorkingImage(_ image: UIImage?) {
        workingImage = image
        AppLogger().logDebug("Setting image: \(String(describing: image))")
    }
    
    
    // MARK: - Action buttons
    
    @IBAction func actionClearButton(_ sender: Any) {
        setWorkingImage( nil )
        displayWorkingImage()
        receiverForChanges?.notifyImageChanged(nil)
    }
    
    @IBAction func actionCameraRollButton(_ sender: Any) {
        if let sourceView = sender as? UIView {
            imagePickerWorker?.actionCameraRollButton(forSourceView: sourceView)
        }
        else {
            AppLogger().logWarning("actionCameraRollButton() invoked from non-UIView sender object")
        }
    }
    
    @IBAction func actionCameraButton(_ sender: Any) {
        imagePickerWorker?.actionCameraButton()
    }
    
    
    // MARK: - <ImagePickerWorkerDelegate>
    
    func imagePickerWorker(_ picker: ImagePickerWorker, didPickImage image: UIImage) {
        DispatchQueue.main.async {
            self.setWorkingImage( image )
            self.displayWorkingImage()
            self.receiverForChanges?.notifyImageChanged(image)
        }
    }

    func imagePickerWorkerDidCancel(_ picker: ImagePickerWorker) {
        // nothing
    }

}
