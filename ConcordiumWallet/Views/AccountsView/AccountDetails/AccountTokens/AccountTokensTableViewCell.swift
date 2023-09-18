//
//  AccountTokensTableViewCell.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 08/08/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit
import SDWebImage

class AccountTokensTableViewCell: UITableViewCell {
    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        balanceLabel.text = ""
        tokenImageView.image = nil
    }
}
