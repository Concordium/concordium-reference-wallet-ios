//
//  IdentityDataRowCellView.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/10/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class IdentityDataRowCellView: UITableViewCell {

    @IBOutlet var keyLabel: UILabel?
    @IBOutlet var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
