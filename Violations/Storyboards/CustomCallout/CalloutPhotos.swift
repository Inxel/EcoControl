//
//  CalloutPhotos.swift
//  Violations
//
//  Created by Артем Загоскин on 30/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import FirebaseStorage

class CalloutPhotos: ViewControllerPannable {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}



//MARK: - Class for cell

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: Image!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
            didSet {
                self.activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
    }
    
    func downloadImage(_ url: String, _ index: Int, completion: @escaping (UIImage?) -> Void) {
        Storage.storage().reference().child("\(url)/\(index)").getData(maxSize: 10000000) { ( data, error) in
            guard let _data = data else {
                print(error!)
                return
            }
            let photo = UIImage(data: _data)!
            
            self.imageView.image = photo
            self.activityIndicator.stopAnimating()
            completion(photo)
        }
    }
    
}
