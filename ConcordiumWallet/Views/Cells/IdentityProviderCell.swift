//
//  IdentityProviderCell.swift
//  ConcordiumWallet
//
//  Concordium on 04/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

class IdentityProviderCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
//    @IBOutlet weak var detailsLabel: UILabel?
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var privacyPolicyButton: UIButton?
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 4
        self.contentView.layer.cornerRadius = 4
    }
}
