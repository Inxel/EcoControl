//
//  ThemeModeCell.swift
//  Violations
//
//  Created by Artyom Zagoskin on 10.04.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


final class ThemeModeCell: UITableViewCell, DequeueableCell {
    
    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = .primary
    }
    
}


// MARK: - Public API

extension ThemeModeCell {
    
    func setUp(title: String, isSelected: Bool, themeProtocol: ThemeProtocol) {
        titleLabel.text = title
        accessoryType = isSelected ? .checkmark : .none
        
        backgroundColor = themeProtocol.background
        titleLabel.textColor = themeProtocol.textColor
    }
    
}
