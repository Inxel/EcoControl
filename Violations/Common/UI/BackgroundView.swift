//
//  BackgroundView.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


final class BackgroundView: UIView {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.layer.cornerRadius = 20
    }
    
}
