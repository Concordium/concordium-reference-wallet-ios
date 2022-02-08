//
//  AccountCardView.swift
//  ConcordiumWallet
//
//  Concordium on 05/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

protocol AccountCardViewDelegate: AnyObject {
    func perform(action: AccountCardAction)
}

enum AccountCardAction {
    case tap
    case send
    case receive
    case more
}


enum AccountCardViewState {
    case basic
    case readonly
    case baking
    case delegating
}


@IBDesignable
class AccountCardView: UIView, NibLoadable {

    //Contained in accountView
    @IBOutlet weak private var accountName: UILabel!
    @IBOutlet weak var initialAccountLabel: UILabel!
    @IBOutlet weak private var pendingImageView: UIImageView!
    @IBOutlet weak private var accountOwner: UILabel!
    @IBOutlet weak private var stateImageView: UIImageView!
    @IBOutlet weak private var stateLabel: UILabel!
    
    
    //Contained in totalView
    @IBOutlet weak private var totalLabel: UILabel!
    @IBOutlet weak private var totalAmount: UILabel!
    @IBOutlet weak private var totalAmountLockImageView: UIImageView!
    
    //Contained in atDisposalView
    @IBOutlet weak private var atDisposalLabel: UILabel!
    @IBOutlet weak private var atDisposalAmount: UILabel!
    
    
    @IBOutlet weak private var stackCardView: UIStackView!
    @IBOutlet weak private var buttonsHStackViewView: UIStackView!

    weak var delegate: AccountCardViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        setupTapCardGesture()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        setupTapCardGesture()
    }
    
    func setupTapCardGesture() {
        let tapCard = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        stackCardView.addGestureRecognizer(tapCard)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.delegate?.perform(action: .tap)
    }
    
    func setup(accountViewModel: AccountViewModel) {
        self.setupStaticStrings(accountTotal: accountViewModel.totalName,
                                           atDisposal: accountViewModel.atDisposalName)
        let state: AccountCardViewState!
        if accountViewModel.isBaking {
            state = .baking
        } else if accountViewModel.isReadOnly {
            state = .readonly
        } else {
            state = .basic
        }
        
        let showLock = accountViewModel.totalLockStatus != .decrypted
       
        if accountViewModel.areActionsEnabled {
            buttonsHStackViewView.isHidden = true
        } else {
            buttonsHStackViewView.isHidden = false
        }
        
        self.setup(accountName: accountViewModel.name,
                              accountOwner: accountViewModel.owner,
                              isInitialAccount: accountViewModel.isInitialAccount,
                              totalAmount: accountViewModel.totalAmount,
                              showLock: showLock,
                              publicBalanceAmount: accountViewModel.generalAmount,
                              atDisposalAmount: accountViewModel.atDisposalAmount,
                              state: state)
    }
    
    private func setupStaticStrings(accountTotal: String,
                            atDisposal: String) {
        totalLabel.text = accountTotal
        atDisposalLabel.text = atDisposal
    }
    
    private func setup(accountName: String?,
               accountOwner: String?,
               isInitialAccount: Bool,
               totalAmount: String,
               showLock: Bool,
               publicBalanceAmount: String,
               atDisposalAmount: String,
               state: AccountCardViewState) {
        
        self.accountName.text = accountName
        self.accountOwner.text = accountOwner

        self.totalAmount.text = totalAmount
        self.atDisposalAmount.text = atDisposalAmount
        
        initialAccountLabel.isHidden = !isInitialAccount
        
        if showLock {
            self.showLock()
        } else {
            hideLock()
        }

        
        switch state {
        case .basic:
            self.stackCardView.alpha = 1
            self.stateLabel.isHidden = true
            self.stateImageView.isHidden = true
        case .readonly:
            self.stackCardView.alpha = 0.5
            self.stateLabel.text = "accounts.overview.readonly".localized
            self.stateImageView.image = UIImage(named: "icon_read_only")
        case .baking:
            self.stackCardView.alpha = 1
            self.stateLabel.text = "accounts.overview.baking".localized
            self.stateImageView.image = UIImage(named: "icon_bread")
        case .delegating:
            self.stackCardView.alpha = 1
            self.stateLabel.text = "accounts.overview.delegating".localized
            self.stateImageView.image = UIImage(named: "icon_delegate")
        }
    }
    
    
    func showStatusImage(_ statusImage: UIImage?) {
        pendingImageView.image = statusImage
        if statusImage == nil {
            pendingImageView.isHidden = true
        } else {
            pendingImageView.isHidden = false
        }
    }
    
    // MARK: Private
    @IBAction private func pressedSend(sender: Any) {
        delegate?.perform(action: .send)
    }
    
    @IBAction private func pressedReceive(sender: Any) {
        delegate?.perform(action: .receive)
    }
    
    @IBAction private func pressedMore(sender: Any) {
        delegate?.perform(action: .more)
    }
    
    // MARK: Helpers
    private func showLock() {
        self.totalAmountLockImageView.image = UIImage(named: "Icon_Shield")
        layoutIfNeeded()
    }
    
    private func hideLock() {
        self.totalAmountLockImageView.image = nil
        layoutIfNeeded()
    }
}
