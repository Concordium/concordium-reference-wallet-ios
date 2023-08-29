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
    @IBOutlet weak var tokenImageView: SDAnimatedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
}
