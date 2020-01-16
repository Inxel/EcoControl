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
        
        self.layer.cornerRadius = 20
        self.layer.borderColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.4330878519, alpha: 1)
        
    }
    
}
