//
//  ImageCollectionViewCell.swift
//  Violations
//
//  Created by Артем Загоскин on 29/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import FirebaseStorage


// MARK: - Protocols

protocol ImageCellDelegate: class {
    func delete(cell: ImageCollectionViewCell)
}


// MARK: - Base

final class ImageCollectionViewCell: UICollectionViewCell {
    
    private var sizeOfDeleteButton = 25
    weak var delegate: ImageCellDelegate?
    
    lazy private var imageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "loading"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        image.backgroundColor = UIColor.lightGray
        image.contentMode = .scaleAspectFill
        
        return image
    }()
    
    lazy private var blurEffect: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = CGFloat(sizeOfDeleteButton / 2)
        blur.layer.masksToBounds = true
        
        return blur
    }()
    
    lazy private var deleteButton: UIButton = {
        let delete = UIButton()
        delete.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        delete.setImage(UIImage(named: "plus"), for: .normal)
        delete.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))
        delete.translatesAutoresizingMaskIntoConstraints = false
        
        return delete
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(imageView)
        addSubview(blurEffect)
        insertSubview(deleteButton, aboveSubview: blurEffect)
        
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        blurEffect.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        blurEffect.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        blurEffect.widthAnchor.constraint(equalToConstant: CGFloat(sizeOfDeleteButton)).isActive = true
        blurEffect.heightAnchor.constraint(equalToConstant: CGFloat(sizeOfDeleteButton)).isActive = true
        
        deleteButton.centerXAnchor.constraint(equalTo: blurEffect.centerXAnchor).isActive = true
        deleteButton.centerYAnchor.constraint(equalTo: blurEffect.centerYAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: blurEffect.bottomAnchor).isActive = true
        deleteButton.topAnchor.constraint(equalTo: blurEffect.topAnchor).isActive = true
        deleteButton.leftAnchor.constraint(equalTo: blurEffect.leftAnchor).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: blurEffect.rightAnchor).isActive = true
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton!) {
        delegate?.delete(cell: self)
    }
    
    func downloadImage(_ url: String, _ index: Int, completion: @escaping Handler<UIImage?>) {
        
        blurEffect.isHidden = true
        deleteButton.isHidden = true
        
        Storage.storage().reference().child("\(url)/\(index)").getData(maxSize: 10000000) { ( data, error) in
            
            guard let _data = data else {
                print(error!)
                return
            }
            
            let photo = UIImage(data: _data)!
            
            self.setup(with: photo)
            completion(photo)
            
        }
    }
    
    func setup(with image: UIImage) {
        imageView.image = image
    }
}
