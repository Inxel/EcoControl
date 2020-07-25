//
//  String+BlankChecking.swift
//  Violations
//
//  Created by Artyom Zagoskin on 21.07.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation


extension String {
    
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
}
