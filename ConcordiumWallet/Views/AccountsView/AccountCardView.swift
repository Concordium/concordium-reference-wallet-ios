//
//  AccountCardView.swift
//  ConcordiumWallet
//
//  Concordium on 05/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

protocol AccountCardViewDelegate: AnyObject {
    func didTapGeneralBalance()
    func didTapShieldedBalance()
    func didTapExpand()
}

@IBDesignable
class AccountCardView: UIView, NibLoadable {
    @IBOutlet weak private var accountNameCollapsed: UILabel!
    @IBOutlet weak private var pendingIconCollapsedImageView: UIImageView!
    @IBOutlet weak private var breadIconCollapsedImageView: UIImageView!
    @IBOutlet weak private var readOnlyIconCollapsedImageView: UIImageView!
    @IBOutlet weak private var accountTotalAmountCollapsedLabel: UILabel!
    @IBOutlet weak private var accountTotalLockCollapsedImageView: UIImageView!
    
    @IBOutlet weak private var accountNameExpanded: UILabel!
    @IBOutlet weak private var pendingIconExpandedImageView: UIImageView!
    @IBOutlet weak private var breadIconExpandedImageView: UIImageView!
    @IBOutlet weak private var readOnlyIconExpandedImageView: UIImageView!
    @IBOutlet weak private var accountTotalAmountExpandedLabel: UILabel!
    @IBOutlet weak private var accountTotalLockExpandedImageView: UIImageView!
    
    @IBOutlet weak private var accountTotalStaticLabel: UILabel!
    @IBOutlet weak private var accountOwnerLabel: UILabel!
    
    @IBOutlet weak private var balanceStaticLabel: UILabel!
    @IBOutlet weak private var balanceAmountLabel: UILabel!
    
    @IBOutlet weak private var atDisposalStaticLabel: UILabel!
    @IBOutlet weak private var atDisposalAmountLabel: UILabel!
    
    @IBOutlet weak private var stakedStaticLabel: UILabel!
    @IBOutlet weak private var stakedAmountLabel: UILabel!
    
    @IBOutlet weak private var shieldedBalanceStaticLabel: UILabel!
    @IBOutlet weak private var shieldedBalanceAmountLabel: UILabel!
    @IBOutlet weak private var shieldedBalanceLockImageView: UIImageView!
    @IBOutlet weak private var expandImageView: UIImageView!
    
    // views that can be hidden/shown based on collapsed/expanded state
    @IBOutlet weak private var totalViewCollapsed: UIView!
    @IBOutlet weak private var accountViewExpanded: UIView!
    @IBOutlet weak private var totalViewExpanded: UIView!
    @IBOutlet weak private var atDisposalView: UIView!
    @IBOutlet weak private var stakedView: UIView!
    @IBOutlet weak private var expandView: UIView!
    
    @IBOutlet weak private var stackCardView: UIStackView!
    
    @IBOutlet weak var initialAccountCollapsedLabel: UILabel!
    @IBOutlet weak var initialAccountExpandedLabel: UILabel!
    
    weak var delegate: AccountCardViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        setExpanded(true)
        setupExpandCollapseGesture()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        setExpanded(true)
        setupExpandCollapseGesture()
    }
    
    func setupExpandCollapseGesture() {
        let tapCollapsed = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        totalViewCollapsed.addGestureRecognizer(tapCollapsed)
        let tapExpanded = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        accountViewExpanded.addGestureRecognizer(tapExpanded)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        pressedExpand(sender: self)
    }
    
    func setupStaticStrings(accountTotal: String,
                            publicBalance: String,
                            atDisposal: String,
                            staked: String,
                            shieldedBalance: String) {
        accountTotalStaticLabel.text = accountTotal
        balanceStaticLabel.text = publicBalance
        atDisposalStaticLabel.text = atDisposal
        stakedStaticLabel.text = staked
        shieldedBalanceStaticLabel.text = shieldedBalance
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
               isExpanded: Bool = false,
               isExpandable: Bool = true) {
        
        accountNameExpanded.text = accountName
        accountNameCollapsed.text = accountName
        
        accountOwnerLabel.text = accountOwner
        breadIconExpandedImageView.isHidden = !isBaking
        breadIconCollapsedImageView.isHidden = !isBaking
        
        readOnlyIconExpandedImageView.isHidden = !isReadOnly
        readOnlyIconCollapsedImageView.isHidden = !isReadOnly
        
        accountTotalAmountExpandedLabel.text = totalAmount
        accountTotalAmountCollapsedLabel.text = totalAmount
        
        balanceAmountLabel.text = publicBalanceAmount
        atDisposalAmountLabel.text = atDisposalAmount
        stakedAmountLabel.text = stakedAmount
        shieldedBalanceAmountLabel.text = shieldedAmount
        
        if isInitialAccount {
            initialAccountCollapsedLabel.isHidden = false
            initialAccountExpandedLabel.isHidden = false
        } else {
            initialAccountCollapsedLabel.isHidden = true
            initialAccountExpandedLabel.isHidden = true
        }
        
        if showLock {
            self.showLock()
        } else {
            hideLock()
        }
        
        if isExpandable {
            expandView.isHidden = false
        } else {
            expandView.isHidden = true
        }
        setExpanded(isExpanded)
        
        if isReadOnly {
            self.stackCardView.alpha = 0.5
        } else {
            self.stackCardView.alpha = 1
        }
    }
    
    func setExpanded(_ isExpanded: Bool) {
        let hideExpandedViews = !isExpanded
        let hideCollapsedViews = isExpanded
        
        self.totalViewCollapsed.isHidden = hideCollapsedViews
        self.totalViewExpanded.isHidden = hideExpandedViews
        self.accountViewExpanded.isHidden = hideExpandedViews
        self.atDisposalView.isHidden = hideExpandedViews
        self.stakedView .isHidden = hideExpandedViews
        
        self.stackCardView.layoutIfNeeded()
        
        if isExpanded {
            expandImageView.image = UIImage(named: "Icon_arrow_top")
        } else {
            expandImageView.image = UIImage(named: "Icon_arrow_bottom")
        }
        
        self.layoutIfNeeded()
        
    }
    
    func showStatusImage(_ statusImage: UIImage?) {
        pendingIconExpandedImageView.image = statusImage
        pendingIconCollapsedImageView.image = statusImage
        if statusImage == nil {
            pendingIconExpandedImageView.isHidden = true
            pendingIconCollapsedImageView.isHidden = true
        } else {
            pendingIconExpandedImageView.isHidden = false
            pendingIconCollapsedImageView.isHidden = false
        }
    }
    
    // MARK: Private
    @IBAction private func pressedGeneralBalance(sender: Any) {
        delegate?.didTapGeneralBalance()
        //        guard let cellRow = cellRow else { return }
        //        delegate?.cellCheckTapped(cellRow: cellRow, index: 1)
    }
    
    @IBAction private func pressedShieldedBalance(sender: Any) {
        delegate?.didTapShieldedBalance()
        //        guard let cellRow = cellRow else { return }
        //        delegate?.cellCheckTapped(cellRow: cellRow, index: 2)
    }
    
    @IBAction private func pressedExpand(sender: Any) {
        delegate?.didTapExpand()
    }
    
    // MARK: Helpers
    
    private func showLock() {
        self.shieldedBalanceLockImageView.image = UIImage(named: "Icon_Shield")
        self.accountTotalLockExpandedImageView.image = UIImage(named: "Icon_Shield")
        self.accountTotalLockCollapsedImageView.image = UIImage(named: "Icon_Shield")
        layoutIfNeeded()
    }
    
    private func hideLock() {
        self.shieldedBalanceLockImageView.image = nil
        self.accountTotalLockExpandedImageView.image = nil
        self.accountTotalLockCollapsedImageView.image = nil
        layoutIfNeeded()
    }
}

enum AccountCardState {
    case expanded
    case collapsed
}
