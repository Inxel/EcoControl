//
//  PostServiceFirebase.swift
//  Violations
//
//  Created by Артем Загоскин on 28/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import FirebaseStorage


struct PostServiceFireBase {
    static func create(for image: UIImage,path: String, completion: @escaping Handler<String?>) {
        let filePath = path
        
        let imageRef = Storage.storage().reference().child(filePath)
        StorageServiceFireBase.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                print("Download url not found or error to upload")
                return completion(nil)
            }
            
            completion(downloadURL.absoluteString)
        }
    }

}
