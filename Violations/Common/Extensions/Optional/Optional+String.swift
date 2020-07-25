//
//  Optional+EmptyString.swift
//  Violations
//
//  Created by Artyom Zagoskin on 21.07.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation


extension Optional where Wrapped == String {
    
    var isEmpty: Bool { self?.isEmpty ?? true }
    
    var isBlank: Bool { self?.isBlank ?? true }
    
    var count: Int { self?.count ?? 0 }
    
}
