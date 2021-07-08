//
//  IdentityCell.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

class IdentityCell: UITableViewCell {

    @IBOutlet weak var identityCardView: IdentityCardView?

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 4
        self.contentView.layer.cornerRadius = 4
    }
}
