//
//  AccountDetailsIdentityDataCellView.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol AccountTransactionsDataCellViewDelegate: AnyObject {
    func lockButtonPressed(from cell: AccountTransactionsDataCellView)
}

class AccountTransactionsDataCellView: UITableViewCell {
    @IBOutlet weak var recipientName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var transactionIconStatusView: UIImageView!
    @IBOutlet weak var costLabel: UILabel!    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusIconImageView: UIImageView!
    @IBOutlet weak var amountCostStackView: UIStackView!
    @IBOutlet weak var lockButton: UIButton!
    
    weak var delegate: AccountTransactionsDataCellViewDelegate?
    var transactionHash: String?
    
    func updateUIBasedOn(_ viewModel: TransactionCellViewModel, useFullDate: Bool = false) {
        recipientName?.text = viewModel.title
        if useFullDate {
            timeLabel.text = viewModel.fullDate
        } else {
            timeLabel?.text = viewModel.date
        }
        totalLabel?.text = viewModel.total
        amountLabel.text = viewModel.amount
        recipientName.textColor = viewModel.titleColor
        statusIconImageView.image = viewModel.statusIcon
        totalLabel.textColor = viewModel.totalColor
        amountLabel.textColor = viewModel.amountColor
        costLabel.textColor = viewModel.costColor
        amountLabel.isHidden = !viewModel.showCostAndAmount
        costLabel.isHidden = !viewModel.showCostAndAmount
        amountCostStackView.isHidden = amountLabel.isHidden && costLabel.isHidden
        transactionIconStatusView.isHidden = !viewModel.showErrorIcon
        statusIconImageView.isHidden = !viewModel.showStatusIcon
        costLabel.text = viewModel.cost
        lockButton.isUserInteractionEnabled = viewModel.showLock
        
        if viewModel.showLock {
            lockButton.setImage(UIImage(named: "Icon_Shield"), for: .normal)
        } else {
            lockButton.setImage(nil, for: .normal)
        }
        layoutIfNeeded()
        
    }
    
    @IBAction func lockButtonPressed(_ sender: Any) {
        self.delegate?.lockButtonPressed(from: self)
    }
}
