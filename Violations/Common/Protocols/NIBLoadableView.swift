//
//  NIBLoadableView.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


protocol NIBLoadableView: class {
    var contentView: UIView? { get set }
}


extension NIBLoadableView where Self: UIView, Self: ReusableView {
    static var nib: UINib { .init(nibName: reuseID, bundle: nil) }

    var contentView: UIView? { get { fatalError("Needs to be overridden") } set { fatalError("Needs to be overridden") } }
    
    func loadViewFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = bounds
        addSubview(view)
        contentView = view
    }
}
