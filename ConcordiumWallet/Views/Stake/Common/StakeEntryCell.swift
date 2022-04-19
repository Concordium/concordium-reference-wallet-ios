//
//  StakeEntryCell.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 11/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit

class StakeEntryCell: UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
