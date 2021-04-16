//
//  IdentityCardView.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 04/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

@IBDesignable
class IdentityCardView: UIView, NibLoadable {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var expirationDateLabel: UILabel?
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var statusIcon: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
}
