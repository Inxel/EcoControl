//
//  PrimaryButton.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import TransitionButton


final class PrimaryButton: TransitionButton {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 20
        layer.borderColor = UIColor.primary.cgColor
    }
    
}
