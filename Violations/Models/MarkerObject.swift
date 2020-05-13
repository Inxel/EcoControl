//
//  MarkerObject.swift
//  Violations
//
//  Created by Artyom Zagoskin on 13.05.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation
import RealmSwift


class MarkerObject: Object {
    @objc dynamic var title = ""
    @objc dynamic var comment = ""
    @objc dynamic var url = ""
    @objc dynamic var amountOfPhotos = 0
    @objc dynamic var date: Date?
    @objc dynamic var latitude: String?
    @objc dynamic var longitude: String?
}
