//
//  UIPageViewController+ScrollView.swift
//  Violations
//
//  Created by Artyom Zagoskin on 24.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


extension UIPageViewController {

    var scrollView: UIScrollView? { view.subviews.filter { $0 is UIScrollView }.first as? UIScrollView }
    
}
