//
//  CustomCallout.swift
//  Violations
//
//  Created by Артем Загоскин on 18/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class CustomCallout: NSObject, MKAnnotation {

    var title: String?
    var comment: String
    var coordinate: CLLocationCoordinate2D
    var url: String
    var amountOfPhotos: String
    
    init(title: String, comment: String?, coordinate: CLLocationCoordinate2D, url: String, amountOfPhotos: String) {
        self.title = title
        self.comment = comment ?? "User didin't add comment"
        self.coordinate = coordinate
        self.url = url
        self.amountOfPhotos = amountOfPhotos
    }
    
    func mapItem() -> MKMapItem {  // open annotation on maps
        let addressDict = [CNPostalAddressStreetKey: title!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
}
