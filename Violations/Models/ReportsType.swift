//
//  ReportsType.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation


enum ReportsType: String, CaseIterable {
    case airPollution = "Air pollution"
    case waterPollution = "Water pollution"
    case landPollution = "Land pollution"
    case deforestation = "Deforestation"
    case trashProblem = "Trash problem"
    case waste = "Waste"
    case other = "Other"
}
