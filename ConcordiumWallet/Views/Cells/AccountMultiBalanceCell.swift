//
//  AccountMultiBalanceCell.swift
//  ConcordiumWallet
//
//  Concordium on 16/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol AccountMultiBalanceCellDelegate: AnyObject {
    func cellCheckTapped(cellRow: Int, index: Int)
}

class AccountMultiBalanceCell: UITableViewCell {
    var statusImageWidth: CGFloat = 0.0
    
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var amountLabel: UILabel?
    @IBOutlet weak var lockImageView: UIImageView?
    
    @IBOutlet weak var generalBalanceNameLabel: UILabel?
    @IBOutlet weak var generalBalanceAmountLabel: UILabel?
    
    @IBOutlet weak var shieldedBalanceNameLabel: UILabel?
    @IBOutlet weak var shieldedBalanceAmountLabel: UILabel?
    @IBOutlet weak var shieldedLockImageView: UIImageView?
   
    @IBOutlet weak var statusImageView: UIImageView?
    @IBOutlet weak var statusImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var roundedView: UIView?
    
    weak var delegate: AccountMultiBalanceCellDelegate?
    var cellRow: Int?
    
    override func awakeFromNib() {
        statusImageWidth =
            // To get it from storyboard
            statusImageWidthConstraint.constant
        _ = leftAlignmentConstraint.constant
        roundedView?.applyConcordiumEdgeStyle()
        clipsToBounds = false
        layer.masksToBounds = false
        contentView.layer.masksToBounds = false
    }
    
    func showStatusImage(_ name: String) {
        statusImageWidthConstraint.constant = statusImageWidth
        leftAlignmentConstraint.constant = 8
        statusImageView?.image = UIImage(named: name)
    }
    
    func hideStatusImage() {
        statusImageWidthConstraint.constant = 0
        leftAlignmentConstraint.constant = 0
    }
    
    func showLock() {
        self.lockImageView?.image = UIImage(named: "Icon_Shield")
        self.shieldedLockImageView?.image = UIImage(named: "Icon_Shield")
        layoutIfNeeded()
    }
    
    func hideLock() {
        self.lockImageView?.image = nil
        self.shieldedLockImageView?.image = nil
         layoutIfNeeded()
    }
    
    @IBAction func pressedGeneralBalance(sender: Any) {
        guard let cellRow = cellRow else { return }
        delegate?.cellCheckTapped(cellRow: cellRow, index: 1)
    }
    
    @IBAction func pressedShieldedBalance(sender: Any) {
        guard let cellRow = cellRow else { return }
        delegate?.cellCheckTapped(cellRow: cellRow, index: 2)
    }
    
}
