//
//  CalloutView.swift
//  Violations
//
//  Created by Артем Загоскин on 01/05/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import FirebaseStorage
import RealmSwift
import MapKit
import Firebase

class CalloutView: ViewControllerPannable, ProgressHUDShowing {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = Theme.current.background
        }
    }
    
    @IBOutlet weak var commentTextview: UITextView! {
        didSet {
            commentTextview.text = comment
            commentTextview.textColor = Theme.current.textColor
            commentTextview.backgroundColor = Theme.current.background
        }
    }
    
    @IBOutlet weak var backgroundView: BackgroundView! {
        didSet {
            backgroundView.backgroundColor = Theme.current.background
        }
    }
    
    @IBOutlet weak var underButtonView: UIView! {
        didSet {
            underButtonView.backgroundColor = Theme.current.background
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = titleOfMarker
            titleLabel.textColor = Theme.current.textColor
        }
    }
    
    private var realm = try! Realm()
    private var markersFromRealm: Results<SavedMarker>?
    private var isExist = false
    
    var titleOfMarker = ""
    var comment = ""
    var url = ""
    var amountOfPhotos: Int?
    var location: CLLocationCoordinate2D?
    var mark: CustomCallout?
    
    private var images = [SKPhotoProtocol]()
    private var data = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        images = Array(repeating: SKPhoto.photoWithImage(#imageLiteral(resourceName: "loading")), count: amountOfPhotos!)
        
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayCounterLabel = true
        SKPhotoBrowserOptions.displayBackAndForwardButton = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        markersFromRealm = realm.objects(SavedMarker.self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        commentTextview.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @IBAction func dismissCallout(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        showProgressHUD()
        let marker = SavedMarker()
        marker.title = titleOfMarker
        marker.comment = comment == "User didn't add comment" ? "" : comment
        marker.dateCreated = Date()
        marker.url = url
        marker.amountOfPhotos = amountOfPhotos!
        marker.latitude = String(describing: location!.latitude)
        marker.longitude = String(describing: location!.longitude)
        
        markersFromRealm?.forEach {
            if $0.url == self.url {
                self.isExist = true
                return
            }
        }
        
        if !isExist {
            saveToRealm(marker)
            
            let coordinate = CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude)
            
            saveMarker(coordinate, titleOfMarker, comment, url, amountOfPhotos!)
        } else {
            showProgressHUDError(with: "You've already saved this marker")
        }
        
    }
    
    @IBAction func showMore(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: #"Show on "Maps""#, style: .default, handler: { _ in
            self.mark = CustomCallout(title: self.titleOfMarker, comment: self.comment, coordinate: self.location!, url: self.url, amountOfPhotos: String(describing: self.amountOfPhotos))
            let launchOptions = [MKLaunchOptionsDirectionsModeKey:
                MKLaunchOptionsDirectionsModeDriving]
            self.mark!.mapItem().openInMaps(launchOptions: launchOptions)
        }))
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }

}


//MARK: - Realm methods


extension CalloutView {
    
    func saveToRealm(_ marker: SavedMarker) {
        
        do {
            try realm.write {
                realm.add(marker)
                showProgressHUDSuccess(with: "Marker has been successfully saved")
            }
        } catch {
            print("Fuckin' error")
            showProgressHUDError(with: "Try later")
        }
        
    }
    
    func saveMarker(_ coordinate: CLLocationCoordinate2D, _ title: String, _ comment: String, _ url: String, _ amountOfPhotos: Int) {
        guard CheckInternet.connection() else { return }
        let markersDB = Database.database().reference().child("SavedMarkers/\(Auth.auth().currentUser!.uid)")
        let markersDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "Title": title,
                                 "Comment": comment,
                                 "Latitude": String(coordinate.latitude),
                                 "Longitude": String(coordinate.longitude),
                                 "URL": url,
                                 "AmountOfPhotos": String(amountOfPhotos)]
    
        markersDB.childByAutoId().setValue(markersDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Marker saved successfully!")
            }
        }
    }
    
}


//MARK: - CollectionView delegate methods


extension CalloutView: UICollectionViewDelegate, SKPhotoBrowserDelegate {
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = SKPhotoBrowser(photos: images, initialPageIndex: indexPath.item)
        browser.delegate = self
        
        present(browser, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: UIScreen.main.bounds.size.width / 2 - 5, height: 300)
        } else {
            return CGSize(width: UIScreen.main.bounds.size.width / 2 - 5, height: 200)
        }
    }
    
}


//MARK: - CollectionView datasource methods


extension CalloutView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return amountOfPhotos!
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.downloadImage(url, indexPath.item) { image in
            let photo = SKPhoto.photoWithImage(image!)
            photo.shouldCachePhotoURLImage = true
            self.images[indexPath.item] = photo
        }
        
        return cell
    }
    
}


//MARK: - CollectionView layout methods


extension CalloutView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.width - 40
        
        let cellSize = size / 2
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
}
