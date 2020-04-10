//
//  MarkerInfoCell.swift
//  Violations
//
//  Created by Artyom Zagoskin on 23.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


// MARK: - Base

final class MarkerInfoCell: UITableViewCell, DequeueableCell {

    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var commentLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var background: UIView! {
        didSet {
            background.layer.cornerRadius = 10
            background.layer.shadowColor = UIColor.black.cgColor
            background.layer.shadowOpacity = 0.7
            background.layer.shadowOffset = .zero
            background.layer.shadowRadius = 7
        }
    }
    
}


// MARK: - Public API

extension MarkerInfoCell {
    
    func setUp(title: String, comment: String, date: Date?, themeProtocol: ThemeProtocol) {
        titleLabel.text = title
        commentLabel.text = comment
        dateLabel.text = date?.formattedDate(.long)
        titleLabel.textColor = themeProtocol.textColor
        background.backgroundColor = themeProtocol.cellBackground
        backgroundColor = themeProtocol.tableViewBackground
    }
    
    func changeBackgroundSize(transform: CGAffineTransform) {
        background.transform = transform
    }
    
}
