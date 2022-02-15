//
//  BurgerMenuPresenter.swift
//  ConcordiumWallet
//
//  Concordium on 04/12/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

enum BurgerMenuAction {
    case releaseSchedule
    case transferFilters
    case shieldedBalance(shouldShow: Bool, delegate: ShowShieldedDelegate?)
    case dismiss
}

struct BurgerMenuViewModel: Hashable {
    var shieldButtonName: String
    var canEnableShielded: Bool
    
    init(account: AccountDataType) {
        if account.showsShieldedBalance {
            shieldButtonName = String(format: "burgermenu.hideshieldedbalance".localized, account.displayName)
        } else {
            shieldButtonName = String(format: "burgermenu.showshieldedbalance".localized, account.displayName)
        }
        canEnableShielded = !account.isReadOnly //if the account is readonly shielding cannot be enabled
    }
}

// MARK: View
protocol BurgerMenuViewProtocol: AnyObject {
    func bind(to viewModel: BurgerMenuViewModel)
}

// MARK: Delegate
protocol BurgerMenuPresenterDelegate: AnyObject {
    func pressedOption(action: BurgerMenuAction, account: AccountDataType)
}

// MARK: -
// MARK: Presenter
protocol BurgerMenuPresenterProtocol: AnyObject {
    var view: BurgerMenuViewProtocol? { get set }
    func viewDidLoad()
    
    func pressedShowRelease()
    func pressedShowFilters()
    func pressedShieldedBalance()
    func pressedDismiss()
    
}

protocol BurgerMenuDismissDelegate: AnyObject {
    func bugerMenuDismissedWithAction(_action: BurgerMenuAction)
}

class BurgerMenuPresenter: BurgerMenuPresenterProtocol {
    weak var view: BurgerMenuViewProtocol?
    weak var delegate: BurgerMenuPresenterDelegate?
    weak var dismissDelegate: BurgerMenuDismissDelegate?
    weak var showShieldedDelegate: ShowShieldedDelegate?
    
    private var viewModel: BurgerMenuViewModel
    private var account: AccountDataType
    init(delegate: BurgerMenuPresenterDelegate,
         account: AccountDataType,
         dismissDelegate: BurgerMenuDismissDelegate,
         showShieldedDelegate: ShowShieldedDelegate) {
        self.delegate = delegate
        self.account = account
        self.dismissDelegate = dismissDelegate
        self.showShieldedDelegate = showShieldedDelegate
        viewModel = BurgerMenuViewModel(account: account)
    }
    
    func viewDidLoad() {
        view?.bind(to: viewModel)
    }
    
    func pressedShowRelease() {
        self.delegate?.pressedOption(action: .releaseSchedule, account: account)
        self.dismissDelegate?.bugerMenuDismissedWithAction(_action: .releaseSchedule)
    }

    func pressedShowFilters() {
        self.delegate?.pressedOption(action: .transferFilters, account: account)
        self.dismissDelegate?.bugerMenuDismissedWithAction(_action: .transferFilters)
    }

    func pressedShieldedBalance() {
        let action = BurgerMenuAction.shieldedBalance(shouldShow: !account.showsShieldedBalance, delegate: showShieldedDelegate)
        let account: AccountDataType!
        if self.account.showsShieldedBalance {
            //if we are hiding it, we hide it here directly
            account = self.account.withShowShielded(!self.account.showsShieldedBalance)
        } else {
            account = self.account
        }
        self.delegate?.pressedOption(action: action, account: account)
        self.dismissDelegate?.bugerMenuDismissedWithAction(_action: action)
        
    }

    func pressedDismiss() {
        self.delegate?.pressedOption(action: .dismiss, account: account)
        self.dismissDelegate?.bugerMenuDismissedWithAction(_action: .releaseSchedule)
    }
}
