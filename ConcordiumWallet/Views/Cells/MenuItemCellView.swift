//
//  MenuItemCellView.swift
//  ConcordiumWallet
//
//  Created by Concordium on 5/10/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

class MenuItemCellView: UITableViewCell {
    @IBOutlet weak var menuItemTitleLabel: UILabel!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundColor = highlighted ? UIColor(white: 0.85, alpha: 1.0) : .clear
    }
}
