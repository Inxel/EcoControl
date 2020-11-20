//
//  MarkerDescriptionCell.swift
//  Violations
//
//  Created by Artyom Zagoskin on 20.11.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit

final class MarkerDescriptionCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    
}


// MARK: - Public API

extension MarkerDescriptionCell {
    
    func setUp(with text: String?) {
        titleLabel.text = text
    }
    
}
