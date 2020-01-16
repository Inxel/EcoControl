//
//  Handlers.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation


typealias Handler<T> = (T) -> Void
typealias DefaultHandler = () -> Void

typealias DequeueableCell = NIBLoadableView & ReusableView
