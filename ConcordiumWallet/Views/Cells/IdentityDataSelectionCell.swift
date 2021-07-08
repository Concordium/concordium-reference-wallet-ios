//
//  IdentityDataSelectionCell.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/19/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

protocol IdentityDataSelectionCellDelegate: AnyObject {
    func cellCheckTapped(_ cell: IdentityDataSelectionCell)
}

class IdentityDataSelectionCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var checkButton: UIButton!
    
    weak var delegate: IdentityDataSelectionCellDelegate?
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        delegate?.cellCheckTapped(self)
    }
}
