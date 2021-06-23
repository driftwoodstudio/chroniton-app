//
//  ImagePickerWorker.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import DWLib


protocol ImagePickerWorkerDelegate: AnyObject {
    func imagePickerWorker(_ picker: ImagePickerWorker, didPickImage: UIImage)
    func imagePickerWorkerDidCancel(_ picker: ImagePickerWorker)
}


protocol ImageReceiver {
    func setWorkingImage(_ image: UIImage?)
}



// Worker object that is tied to a particular context (owning UIViewController)
// The owner may re-use as needed, but to use in a different context a new Worker
// must be created.
class ImagePickerWorker: NSObject, DWCameraDelegate {
   
    // Set at init, then immutable:
    weak var controllingView: UIViewController?
    weak var delegate: ImagePickerWorkerDelegate?
    var imageSize = CGSize.zero

    // Transitory state
    var cameraInterface: DWCamera?

    
    required init(controllingView: UIViewController, delegate: ImagePickerWorkerDelegate, imageSize: CGSize) {
        super.init()
        self.controllingView = controllingView
        self.delegate = delegate
        self.imageSize = imageSize
    }
    
    
    // MARK: - Action buttons
    
    
    func actionCameraRollButton(forSourceView: UIView) {
        guard let owner = self.controllingView else {
            // Owner has gone out of scope, we shouldn't even still exist
            return
        }
        let cameraInterface = DWCamera(parent: owner, delegate: self)
        
        // Need to wait for callback, so need to hold object in persistent var so it doesn't get gc'd
        self.cameraInterface = cameraInterface
        
        cameraInterface.pickImageFromLibrary(from: forSourceView)
    }
    
    
    func actionCameraButton() {
        guard let owner = self.controllingView else {
            // Owner has gone out of scope, we shouldn't even still exist
            return
        }

        let flag = DWCamera.isCameraAvailable()
        if !flag {
            AppLogger().logDebug("ImagePickerWorker: camera is not available")
            return
        }
        
        let cameraInterface = DWCamera(parent: owner, delegate: self)
        
        // Need to wait for callback, so need to hold object in persistent var so it doesn't get GC'd
        self.cameraInterface = cameraInterface
        
        _ = cameraInterface.takePicture()
    }
    
    
    // MARK: - Camera Delegate callbacks
    
    
    func cameraDidGet(_ image: UIImage) {
        if self.delegate != nil {
            AppLogger().logDebug("cameraDidGet() invoked")
            cameraInterface = nil
            let scaledImage = image.letterbox(targetSize: imageSize)
            delegate?.imagePickerWorker(self, didPickImage: scaledImage)
        }
    }
    
    
    func cameraDidCancel() {
        cameraInterface = nil
        delegate?.imagePickerWorkerDidCancel( self )
    }
    
}


