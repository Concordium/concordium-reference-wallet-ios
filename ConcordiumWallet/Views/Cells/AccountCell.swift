//
//  AccountCell.swift
//  ConcordiumWallet
//
//  Created by Mohamed Ghonemi on 3/26/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol AccountCellDelegate: class {
    func cellCheckTapped(cellRow: Int, index: Int)
    func tappedExpanded(cellRow: Int)
}

class AccountCell: UITableViewCell {

    @IBOutlet weak var accountCardView: AccountCardView!

    var cancellables: [AnyCancellable] = []
    weak var delegate: AccountCellDelegate?
    var cellRow: Int?
    
    override func awakeFromNib() {
        accountCardView.delegate = self
        clipsToBounds = false
        layer.masksToBounds = false
        contentView.layer.masksToBounds = false
    }

    func setupStaticStrings(accountTotal: String,
                            publicBalance: String,
                            atDisposal: String,
                            staked: String,
                            shieldedBalance: String) {
        accountCardView.setupStaticStrings(accountTotal: accountTotal, publicBalance: publicBalance, atDisposal: atDisposal, staked: staked, shieldedBalance: shieldedBalance)
    }
    
    func setup(accountName: String?,
               accountOwner: String?,
               isInitialAccount: Bool,
               isBaking: Bool,
               isReadOnly: Bool,
               totalAmount: String,
               showLock: Bool,
               publicBalanceAmount: String,
               atDisposalAmount: String,
               stakedAmount: String,
               shieldedAmount: String,
               isExpanded: Bool,
               isExpandable: Bool = true) {
        accountCardView.setup(accountName: accountName, accountOwner: accountOwner, isInitialAccount: isInitialAccount, isBaking: isBaking, isReadOnly: isReadOnly, totalAmount: totalAmount, showLock: showLock, publicBalanceAmount: publicBalanceAmount, atDisposalAmount: atDisposalAmount, stakedAmount: stakedAmount, shieldedAmount: shieldedAmount, isExpanded: isExpanded)
        
    }
    
    func showStatusImage(_ image: UIImage?) {
        accountCardView.showStatusImage(image)
    }
    
    func setExpanded(_ isExpanded: Bool) {
        accountCardView.setExpanded(isExpanded)
         layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        cancellables = []
    }
    
}

extension AccountCell: AccountCardViewDelegate {
    func didTapGeneralBalance() {
        guard let cellRow = cellRow else { return }
        delegate?.cellCheckTapped(cellRow: cellRow, index: 1)
    }
    func didTapShieldedBalance() {
        guard let cellRow = cellRow else { return }
        delegate?.cellCheckTapped(cellRow: cellRow, index: 2)
    }
    func didTapExpand() {
         guard let cellRow = cellRow else { return }
        delegate?.tappedExpanded(cellRow: cellRow)
    }
}
