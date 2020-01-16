//
//  UserMarkers.swift
//  Violations
//
//  Created by Артем Загоскин on 23/06/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import Foundation
import RealmSwift


final class UserMarker: Object {
    @objc dynamic var title = ""
    @objc dynamic var comment = ""
    @objc dynamic var url = ""
    @objc dynamic var amountOfPhotos = 0
    @objc dynamic var dateCreated: Date?
    @objc dynamic var latitude: String?
    @objc dynamic var longitude: String?
}
