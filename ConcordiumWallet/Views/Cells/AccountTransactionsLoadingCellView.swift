//
//  AccountDetailsIdentityDataCellView.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

class AccountTransactionsLoadingCellView: UITableViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.startAnimating()
    }
}
