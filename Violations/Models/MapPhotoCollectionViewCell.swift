//
//  AddPhotoCollectionViewCell.swift
//  Violations
//
//  Created by Артем Загоскин on 30/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit

class AddPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: Image!
    
    func setup(with image: UIImage) {
        imageView.image = image
    }
}
