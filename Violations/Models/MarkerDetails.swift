//
//  Marker.swift
//  Violations
//
//  Created by Артем Загоскин on 13/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import Foundation
import RealmSwift

class SavedMarkerDetails: Object {
    @objc dynamic var title = ""
    @objc dynamic var comment = ""
    @objc dynamic var url = ""
    @objc dynamic var amountOfPhotos = 0
    @objc dynamic var dateCreated: Date?
}
