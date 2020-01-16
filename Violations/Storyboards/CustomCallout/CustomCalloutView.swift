//
//  CustomCalloutView.swift
//  Violations
//
//  Created by Артем Загоскин on 18/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import MapKit
import MapViewPlus
import RealmSwift
import SVProgressHUD
import SKPhotoBrowser
import FirebaseStorage

protocol photoTapped {
    func userTapped()
}


class CustomCalloutView: MKAnnotationView, CalloutViewPlus, SKPhotoBrowserDelegate {
    
    var realm = try! Realm()
    var delegate: photoTapped?
    
    @IBOutlet weak var calloutView: UIView! {
        didSet {
            calloutView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var calloutPhotosView: UIView! {
        didSet {
            calloutPhotosView.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.layer.cornerRadius = 10
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(CustomCell.self, forCellWithReuseIdentifier: cellID)
        }
    }
    
    private var images = [SKPhotoProtocol]()
    private let cellID = "cellID"
    var mark: CustomCallout?
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var flipCalloutButton: UIButton!
    
    
    func configureCallout(_ viewModel: CalloutViewModel) {
        let viewModel = viewModel as! CustomCallout
        
        title.text = viewModel.title
        comment.text = showComment(viewModel.comment)
        
        mark = viewModel
        
        configureSKPhoto()
    }
    
    func showComment(_ text: String) -> String{
        if text == "" {
            comment.textColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
            comment.textAlignment = .center
            return "User didn't add comment"
        }
        return text
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        let marker = Marker()
        marker.title = title.text!
        marker.comment = comment.text == "User didn't add comment" ? "" : comment.text
        marker.dateCreated = Date()
        marker.url = mark!.url
        marker.amountOfPhotos = Int(mark!.amountOfPhotos)!
        
        do {
            try realm.write {
                realm.add(marker)
                SVProgressHUD.showSuccess(withStatus: "Marker has been successfully saved")
            }
        } catch {
            print("Fuckin' error")
            SVProgressHUD.showError(withStatus: "Try later")
        }
        
    }
    
//    @IBAction func showOnMapTapped(_ sender: Any) {
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        mark!.mapItem().openInMaps(launchOptions: launchOptions)
//    }
    
    @IBAction func showPhotosTapped(_ sender: Any) {
//        if calloutPhotosView.alpha == 1 {
//            calloutPhotosView.alpha = 0
//            flipCalloutButton.setTitle("Show photos", for: .normal)
//        } else {
//            calloutPhotosView.alpha = 1
//            flipCalloutButton.setTitle("Show details", for: .normal)
//        }
//        UIView.transition(with: calloutView, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
//    }
        delegate?.userTapped()
    }
    
}


extension CustomCalloutView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(mark!.amountOfPhotos)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CustomCell
        
        //cell.downloadImage(mark!.url, indexPath.item) { image in }
        
//        cell.imageView.image = UIImage(named: "bio")
//
//        let photo = SKPhoto.photoWithImage(cell.imageView.image!)
//        photo.shouldCachePhotoURLImage = true
//        self.images[indexPath.item] = photo
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 130, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
}


extension CustomCalloutView {
    
    func configureSKPhoto() {
        images = Array(repeating: SKPhoto.photoWithImage(#imageLiteral(resourceName: "loading")), count: Int(mark!.amountOfPhotos)!)
        SKCache.sharedCache.imageCache = CustomImageCache()
        
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayCounterLabel = true
        SKPhotoBrowserOptions.displayBackAndForwardButton = true
    }
    
}


class CustomCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        image.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        return image
    }()
    
    func setupView() {
        addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
    }
    
    func downloadImage(_ url: String, _ index: Int, completion: @escaping (UIImage?) -> Void) {
        Storage.storage().reference().child("\(url)/\(index)").getData(maxSize: 10000000) { ( data, error) in
            guard let _data = data else {
                print("ERROR: \(error!.localizedDescription)")
                return
            }
            let photo = UIImage(data: _data)!
            
            self.imageView.image = photo
            completion(photo)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
