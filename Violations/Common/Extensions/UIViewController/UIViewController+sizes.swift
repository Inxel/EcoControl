//
//  UIViewController+sizes.swift
//  Violations
//
//  Created by Artyom Zagoskin on 25.07.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


extension UIViewController {
    
    final var safeAreaBottomInset: CGFloat {
        UIApplication.shared.windows.last?.safeAreaInsets.bottom ?? 0
    }
    
    final var safeAreaTopInset: CGFloat {
        UIApplication.shared.windows.last?.safeAreaInsets.top ?? 0
    }
    
    final var statusBarHeight: CGFloat {
        UIApplication.shared.windows.last?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    
}
