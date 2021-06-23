//
//  ImageManager.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import DWLib

class ImageManager: NSObject {
    
    // Given previously pack()'d data, inflate to UIImage
    // Nil input data produces nil output image
    class func inflate(data: Data?) -> UIImage? {
        if let d = data {
            let image = UIImage(data: d)
            return image
        }
        return nil
    }

    // Pack image into Data bytes
    // A nil input image produces nil output data
    class func pack(_ image: UIImage?) -> Data? {
        if let img = image {
            let data = img.pngData()
            return data
        }
        return nil
    }
}

