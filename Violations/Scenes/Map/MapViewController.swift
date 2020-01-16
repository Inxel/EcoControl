//
//  MapViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 07/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import SVProgressHUD
import TransitionButton
import Alamofire
import SwiftyJSON
import RealmSwift


class MapViewController: CustomTransitionViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var realm = try! Realm()
    private let weatherData = WeatherData()
    private let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    private let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var tappedCoordinates: CGPoint?
    private var userLocationButton: MKUserTrackingButton?
    
    private var annotations: [CustomCallout] = []
    
    private var user = Auth.auth().currentUser
    
    @IBOutlet weak var addByTapBottomConstraint: NSLayoutConstraint! {
        didSet {
            addByTapBottomConstraint.constant = -30
        }
    }
    @IBOutlet weak var addToLocationBottomConstraint: NSLayoutConstraint! {
        didSet {
            addToLocationBottomConstraint.constant = -30
        }
    }
    
    @IBOutlet weak var viewForShadow: UIView! {
        didSet {
            viewForShadow.layer.cornerRadius = viewForShadow.frame.height / 2
            viewForShadow.layer.shadowOffset = CGSize(width: -2, height: 2)
            viewForShadow.layer.shadowOpacity = 0.6
            viewForShadow.layer.shadowRadius = 2
        }
    }
    
    @IBOutlet weak var addAnotation: UIButton! {
        didSet {
            addAnotation.layer.cornerRadius = addAnotation.frame.height / 2
        }
    }
    
    @IBOutlet weak var weatherView: UITextView! {
        didSet {
            weatherView.layer.cornerRadius = 5
            weatherView.textContainerInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
            weatherView.textColor = Theme.current.textColor
            weatherView.backgroundColor = Theme.current.background
        }
    }
    
    @IBOutlet weak var addByTapButton: PrimaryButton! {
        didSet {
            addByTapButton.alpha = 0
        }
    }
    @IBOutlet weak var addToLocationButton: PrimaryButton! {
        didSet {
            addToLocationButton.alpha = 0
        }
    }
    
    private var canAddAnnotation = false
    private var addAnnotationTapped = false
    private var showAddButtons = false
    private var addToLocationTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultStyle(.dark)
        
         print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        mapView.delegate = self
    
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        setupUserTrackingButton()
        
        retrieveMarkers()
        
        if !CheckInternet.connection() {
            createAlert(Message: "Internet connection issues")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        weatherView.textColor = Theme.current.textColor
        weatherView.backgroundColor = Theme.current.background
        changeColorOf(addAnotation)
        changeColorOf(addByTapButton)
        changeColorOf(addToLocationButton)
        setupUserTrackingButton()
    }

    @IBAction func addAnnotationTapped(_ sender: Any) {
        addAnnotationTapped = !addAnnotationTapped
        showAddButtons = canAddAnnotation ? showAddButtons : !showAddButtons
        canAddAnnotation = false
        addAnnotationAnimate()
    }
    
    @IBAction func addByTapButtonTapped(_ sender: Any) {
        canAddAnnotation = true
        showAddButtons = false
        addToLocationTapped = false
        addAnnotationAnimate()
    }
    
    @IBAction func addToLocationButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "createMarkDetail", sender: Any?.self)
        
        addToLocationTapped = true
        showAddButtons = false
        addAnnotationTapped = false
        addAnnotationAnimate()
    }
    
    func createAlert(Message: String){
        let alert = UIAlertController(title: "Alert", message: Message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}


//MARK: - Location methods

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                mapView.setRegion(viewRegion, animated: true)
            }
        }
        
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
            self.locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func setupUserTrackingButton() {
        mapView.showsCompass = false

        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 1, alpha: 0.99).cgColor
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.backgroundColor = Theme.current.background.cgColor
        button.tintColor = Theme.current.trackingButton
        view.addSubview(button)
        
        let scale = MKScaleView(mapView: mapView)
        scale.legendAlignment = .trailing
        scale.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scale)
        
        NSLayoutConstraint.activate([button.topAnchor.constraint(equalTo: view.topAnchor, constant: self.view.frame.height / 2),
                                     button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)])
    }
    
}


//MARK: - Add marker by tap


extension MapViewController: UIGestureRecognizerDelegate, tappedButtonDelegate {
    
    @objc func handleTap(_ gestureReconizer: UILongPressGestureRecognizer) {
        if canAddAnnotation {
        
            performSegue(withIdentifier: "createMarkDetail", sender: Any?.self)
            
            tappedCoordinates = gestureReconizer.location(in: mapView)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createMarkDetail" {
            
            let destinationVC = segue.destination as! MarkDetailViewController
            
            destinationVC.delegate = self
            
        }
    }
    
    func userTappedButton(button: String, title: String, comment: String, url: String, amountOfPhotos: String) {
        if button ==  "Save" {
            let coordinate: CLLocationCoordinate2D?
            
            if addToLocationTapped {
                guard let userLocation = currentLocation?.coordinate else {
                    SVProgressHUD.showError(withStatus: "Connection issues")
                    addToLocationTapped = false
                    return
                }
                coordinate = userLocation
            } else {
                coordinate = mapView.convert(tappedCoordinates!, toCoordinateFrom: mapView)
            }
            
            addAnnotationTapped = false
            canAddAnnotation = false
            addToLocationTapped = false
            
            let marker = UserMarker()
            marker.title = title
            marker.comment = comment
            marker.dateCreated = Date()
            marker.url = url
            marker.amountOfPhotos = Int(amountOfPhotos)!
            marker.latitude = String(describing: coordinate!.latitude)
            marker.longitude = String(describing: coordinate!.longitude)
            saveToRealm(marker)
            
            saveMarkerToFirebase(coordinate!, title, comment, url, Int(amountOfPhotos)!)
        }
        
        addToLocationTapped = false
        addAnnotationAnimate()
        
    }
}


//MARK: - Animation methods

extension MapViewController {
    func addAnnotationAnimate() {
        UIView.animate(withDuration: 0.2) {
            self.addAnotation.transform = CGAffineTransform(rotationAngle: !self.addAnnotationTapped ? CGFloat(Double.pi*2) : CGFloat(Double.pi/4))
            self.addByTapBottomConstraint.constant = self.showAddButtons ? 20 : -30
            self.addToLocationBottomConstraint.constant = self.showAddButtons ? 20 : -30
            self.addByTapButton.alpha = self.showAddButtons ? 1 : 0
            self.addToLocationButton.alpha = self.showAddButtons ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }
}


//MARK: - Firebase methods

extension MapViewController {
    
    func saveMarkerToFirebase(_ coordinate: CLLocationCoordinate2D, _ title: String, _ comment: String, _ url: String, _ amountOfPhotos: Int) {
        let markersDB = Database.database().reference().child("Markers")
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
    
    func retrieveMarkers() {
        
        TakeMarkersFromFirebase.downloadMarkers(child: "Markers") { snapshotValue in
            let title = snapshotValue["Title"]!
            let comment = snapshotValue["Comment"]!
            let latitude = snapshotValue["Latitude"]!
            let longitude = snapshotValue["Longitude"]!
            let url = snapshotValue["URL"]!
            let amountOfPhotos = snapshotValue["AmountOfPhotos"]!
            
            let lat = Double(latitude)
            let lon = Double(longitude)
            
            let coordinates = CLLocationCoordinate2D(latitude:lat!, longitude:lon!)
            
            // Add marker on map
            
            let viewModel = CustomCallout(title: title, comment: comment, coordinate: coordinates, url: url, amountOfPhotos: amountOfPhotos)
            
            self.annotations.append(viewModel)
            
            self.mapView.addAnnotations(self.annotations)
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomCallout else { return nil }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = false
            
            view.clusteringIdentifier = "AnnotationViewIdentifier"
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation as? CustomCallout else { return }
        
        let calloutVC = CalloutView.instance() as! CalloutView
        calloutVC.comment = annotation.comment
        calloutVC.titleOfMarker = annotation.title!
        calloutVC.amountOfPhotos = Int(annotation.amountOfPhotos)
        calloutVC.url = annotation.url
        calloutVC.location = annotation.coordinate
        present(calloutVC, animated: true)
        
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
}


//MARK: - API Requesting

extension MapViewController {
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the weather data")
                let weatherJSON: JSON = JSON(response.result.value!)
                
                print(weatherJSON)
                
                self.weatherView.isHidden = false
                
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    func updateWeatherData(json : JSON) {
        
        let tempResult = json["main"]["temp"].doubleValue
        
        weatherData.temperature = Int(tempResult - 273.15)
        weatherData.condition = json["weather"][0]["id"].intValue
        weatherData.weather = "\(weatherData.temperature)º\n\(weatherData.updateWeatherEmoji(condition: weatherData.condition))"
        
        weatherView.text = weatherData.weather
    }
    
}


//MARK: - Change theme

extension MapViewController {
    func changeColorOf(_ button: UIButton) {
        button.backgroundColor = Theme.current.tableViewBackground
    }
}


//MARK: - Realm methods

extension MapViewController {
    func saveToRealm(_ marker: UserMarker) {
        
        do {
            try realm.write {
                realm.add(marker)
            }
        } catch {
            print("Fuckin' error")
        }
        
    }
}
