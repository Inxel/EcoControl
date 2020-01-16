//
//  StorageServiceFireBase.swift
//  Violations
//
//  Created by Артем Загоскин on 28/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import FirebaseStorage

struct StorageServiceFireBase {
    
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping Handler<URL?>) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return completion(nil)
        }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        reference.putData(imageData, metadata: metaData, completion: { (metadata, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                print("Upload failed :: ",error.localizedDescription)
                return completion(nil)
            }
            guard let downloadURL = metadata?.path else {
                print("Download url not found or error to upload")
                return completion(nil)
            }
            
            completion(URL(string: downloadURL))
        })
    }
}
