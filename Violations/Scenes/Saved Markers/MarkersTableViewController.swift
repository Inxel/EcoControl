//
//  MarkersTableViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 07/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import MapKit

class MarkersTableViewController: UIViewController {

    private let realm = try! Realm()
    
    private var savedMarkers: Results<SavedMarker>?
    private var userMarkers: Results<UserMarker>?
    
    private var markersFromServer: [SavedMarker] = []
    private var user = Auth.auth().currentUser
    
    @IBOutlet var markersTableView: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl! {
        didSet {
            segmentController.tintColor = Theme.current.cellBackground
            segmentController.layer.cornerRadius = 10
            segmentController.layer.borderWidth = 1
            segmentController.layer.borderColor = Theme.current.cellBackground.cgColor
            segmentController.layer.masksToBounds = true
        }
    }
    
    
    @IBOutlet weak var noMarkersLabel: UILabel! {
        didSet {
            noMarkersLabel.text = "Save markers to have offline access"
            noMarkersLabel.textAlignment = .center
        }
    }
    @IBOutlet weak var labelLeftConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        markersTableView.delegate = self
        markersTableView.dataSource = self
        //markersTableView.register(UINib(nibName: "MarkerCell", bundle: nil) , forCellReuseIdentifier: "customMarkerCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        if CheckInternet.connection() {
            markersFromServer = []
            fetchMarkers()
        } else {
            loadMarkers()
        }
        noMarkersLabel.layer.opacity = savedMarkers?.count == 0 ? 1 : 0
        applyTheme()
        markersTableView.reloadData()
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        markersTableView.reloadData()
        
        if savedMarkers?.count == 0 {
            UIView.animate(withDuration: 0.4) {
                self.noMarkersLabel.layer.opacity = self.segmentController.selectedSegmentIndex == 0 ? 1 : 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MarkerInfoViewController
        
        if let indexPath = markersTableView.indexPathForSelectedRow {
            if segmentController.selectedSegmentIndex == 0 {
                destinationVC.savedMarker = savedMarkers?[indexPath.row]
                destinationVC.ifSavedSegment = true
            }
            else {
                destinationVC.userMarker = userMarkers?[indexPath.row]
                destinationVC.ifSavedSegment = false
            }
            
        }
        
    }
}
    

//MARK: - Table View methods

extension MarkersTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (segmentController.selectedSegmentIndex == 0 ? savedMarkers?.count : userMarkers?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMarkerCell", for: indexPath) as! CustomMarkerCell
        
        cell.applyTheme()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm   dd.MM.yy"
        
        if segmentController.selectedSegmentIndex == 0 {
        
            cell.reportTitle.text = savedMarkers?[indexPath.row].title
            cell.commentText.text = savedMarkers?[indexPath.row].comment
            cell.dateCreated.text = formatter.string(from: (savedMarkers?[indexPath.row].dateCreated)!)
        } else {
            cell.reportTitle.text = userMarkers?[indexPath.row].title
            cell.commentText.text = userMarkers?[indexPath.row].comment
            cell.dateCreated.text = formatter.string(from: (userMarkers?[indexPath.row].dateCreated)!)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (segmentController.selectedSegmentIndex == 0 ? savedMarkers?.count : userMarkers?.count) != 0 {
            performSegue(withIdentifier: "showMarkerInfo", sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return segmentController.selectedSegmentIndex == 0
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
////        guard editingStyle == .delete else { return }
////
////        updateModel(at: indexPath)
////
////        tableView.deleteRows(at: [indexPath], with: .automatic)
//    }
//
//    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
//        if savedMarkers?.count == 0 && segmentController.selectedSegmentIndex == 0 {
//            UIView.animate(withDuration: 0.4) {
//                self.noMarkersLabel.layer.opacity = 1
//                self.view.layoutIfNeeded()
//            }
//        }
        
//    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = tableView.cellForRow(at: indexPath) as? CustomMarkerCell {
            cell.background.transform = .init(scaleX: 0.75, y: 0.75)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            if let cell = tableView.cellForRow(at: indexPath) as? CustomMarkerCell {
                cell.background.transform = .identity
            }
        }
    }
}


//MARK: - Realm methods

extension MarkersTableViewController {
    
    func loadMarkers() {
        savedMarkers = realm.objects(SavedMarker.self).sorted(byKeyPath: "dateCreated", ascending: true)
        userMarkers = realm.objects(UserMarker.self).sorted(byKeyPath: "dateCreated", ascending: true)
        
        savedMarkers?.forEach { marker in
            guard
                let lat = Double(marker.latitude ?? ""),
                let lon = Double(marker.longitude ?? ""),
                !markersFromServer.contains(where: { $0.url == marker.url })
            else { return }
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            saveMarkerToFirebase(coordinate, marker.title, marker.comment, marker.url, marker.amountOfPhotos)
        }
        
        markersTableView.reloadData()
    }
    
    func fetchMarkers() {
        TakeMarkersFromFirebase.downloadMarkers(child: "SavedMarkers/\(user!.uid)") { snapshotValue in
            let title = snapshotValue["Title"]!
            let comment = snapshotValue["Comment"]!
            let latitude = snapshotValue["Latitude"]!
            let longitude = snapshotValue["Longitude"]!
            let url = snapshotValue["URL"]!
            let amountOfPhotos = snapshotValue["AmountOfPhotos"]!
            
            let marker = SavedMarker()
            marker.title = title
            marker.comment = comment
            marker.dateCreated = Date()
            marker.url = url
            marker.amountOfPhotos = Int(amountOfPhotos)!
            marker.latitude = latitude
            marker.longitude = longitude
            
            self.markersFromServer.append(marker)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.loadMarkers()
        }
        
    }
    
    func saveMarkerToFirebase(_ coordinate: CLLocationCoordinate2D, _ title: String, _ comment: String, _ url: String, _ amountOfPhotos: Int) {
        guard CheckInternet.connection() else { return }
        let markersDB = Database.database().reference().child("SavedMarkers/\(user!.uid)")
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
    
    func updateModel(at indexPath: IndexPath) {
        if let markerForDeletion = self.savedMarkers?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(markerForDeletion)
                }
            } catch {
                print("Can't delete 'cause: \(error)")
            }
        }
        
    }
}


//MARK: - Change theme

extension MarkersTableViewController {
    func applyTheme() {
        markersTableView.backgroundColor = Theme.current.tableViewBackground
        view.backgroundColor = Theme.current.tableViewBackground
        segmentController.tintColor = Theme.current.cellBackground
        segmentController.layer.borderColor = Theme.current.cellBackground.cgColor
        if segmentController.selectedSegmentIndex == 1 {
            noMarkersLabel.layer.opacity = 0
        }
    }
}
