//
//  MarkerTableViewCell.swift
//  Violations
//
//  Created by Артем Загоскин on 13/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit

class CustomMarkerCell: UITableViewCell {
    
    @IBOutlet weak var comment: UILabel!
    
    @IBOutlet weak var report: UILabel!
    
    @IBOutlet var reportTitle: UILabel!
    
    @IBOutlet var commentText: UILabel! {
        didSet {
            commentText.adjustsFontSizeToFitWidth = false
            commentText.lineBreakMode = NSLineBreakMode.byTruncatingTail
        }
    }
    
    @IBOutlet weak var background: UIView! {
        didSet {
            background.layer.cornerRadius = 10
            background.layer.shadowColor = UIColor.black.cgColor
            background.layer.shadowOpacity = 0.7
            background.layer.shadowOffset = .zero
            background.layer.shadowRadius = 7
            background.backgroundColor = Theme.current.cellBackground
        }
    }
    @IBOutlet weak var outter: UIView! {
        didSet {
            outter.backgroundColor = Theme.current.tableViewBackground
        }
    }
    
    @IBOutlet var dateCreated: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func applyTheme() {
        background.backgroundColor = Theme.current.cellBackground
        outter.backgroundColor = Theme.current.tableViewBackground
    }
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
