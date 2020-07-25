//
//  Optional+Colllection.swift
//  Violations
//
//  Created by Artyom Zagoskin on 25.07.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation


extension Optional where Wrapped: Collection {
    
    var isEmpty: Bool { self?.isEmpty ?? true }
    
    var count: Int { self?.count ?? 0 }
    
}
