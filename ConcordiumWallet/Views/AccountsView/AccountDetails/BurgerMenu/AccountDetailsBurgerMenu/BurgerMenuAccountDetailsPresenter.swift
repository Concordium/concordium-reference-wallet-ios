//
//  BurgerMenuAccountDetailsPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 28/02/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

// MARK: Delegate
protocol BurgerMenuAccountDetailsPresenterDelegate: AnyObject {
    func pressedOption(action: BurgerMenuAccountDetailsAction, account: AccountDataType)
}

protocol BurgerMenuAccountDetailsDismissDelegate: AnyObject {
    func bugerMenuDismissedWithAction(_action: BurgerMenuAccountDetailsAction)
}

enum BurgerMenuAccountDetailsAction: BurgerMenuAction {
    case releaseSchedule
    case transferFilters
    case shieldedBalance(accountName: String, shouldShow: Bool, delegate: ShowShieldedDelegate?)
    case exportPrivateKey
    case dismiss
    case decrypt
    case exportTransactionLog
    case renameAccount
    
    func getDisplayName() -> String {
        switch self {
        case .releaseSchedule:
            return "burgermenu.releaseschedule".localized
        case .transferFilters:
            return "burgermenu.transferfilters".localized
        case .shieldedBalance(let accountName, let shouldShow, _):
            if shouldShow {
                return String(format: "burgermenu.showshieldedbalance".localized, accountName)
            } else {
                return String(format: "burgermenu.hideshieldedbalance".localized, accountName)
            }
        case .exportPrivateKey:
            return "burgermenu.exportprivatekey".localized
        case .exportTransactionLog:
            return "burgermenu.exporttransactionlog".localized
        case .decrypt:
            return "burgermenu.decrypt".localized
        case .renameAccount:
            return "burgermenu.renameaccount".localized
        case .dismiss:
            return "" // this will not be shown in the ui
        }
    }
}

class BurgerMenuAccountDetailsPresenter: BurgerMenuPresenterProtocol {
//    associatedtype Action: BurgerMenuPresenterDelegate.Action
    weak var delegate: BurgerMenuAccountDetailsPresenterDelegate?
    
    weak var view: BurgerMenuViewProtocol?
    weak var dismissDelegate: BurgerMenuAccountDetailsDismissDelegate?
    var actions: [BurgerMenuAccountDetailsAction]
    
    private var viewModel = BurgerMenuViewModel()
    private var account: AccountDataType
    init(
        delegate: BurgerMenuAccountDetailsPresenterDelegate,
        account: AccountDataType,
        balance: AccountBalanceTypeEnum,
        showsDecrypt: Bool,
        dismissDelegate: BurgerMenuAccountDetailsDismissDelegate,
        showShieldedDelegate: ShowShieldedDelegate,
        dependencyProvider: AccountsFlowCoordinatorDependencyProvider
    ) {
        self.delegate = delegate
        self.account = account
        self.dismissDelegate = dismissDelegate
        if account.isReadOnly {
            self.actions = [
                .releaseSchedule,
                .transferFilters]
        } else {
            if balance == .balance {
                self.actions = [
                    .releaseSchedule,
                    .transferFilters,
                    .shieldedBalance(accountName: account.displayName,
                                     shouldShow: !account.showsShieldedBalance,
                                     delegate: showShieldedDelegate),
                     .exportPrivateKey,
                     .exportTransactionLog,
                     .renameAccount]
            } else {
                if showsDecrypt {
                    self.actions = [
                        .decrypt,
                        .shieldedBalance(accountName: account.displayName,
                                         shouldShow: !account.showsShieldedBalance,
                                         delegate: showShieldedDelegate)]
                } else {
                    self.actions = [
                        .shieldedBalance(accountName: account.displayName,
                                         shouldShow: !account.showsShieldedBalance,
                                         delegate: showShieldedDelegate)]
                }
            }
        }
    }
    
    func viewDidLoad() {
        viewModel.setup(actions: actions)
        view?.bind(to: viewModel)
    }
    
    func selectedAction(at index: Int) {
        let action = self.actions[index]
        selectedAction(action)
    }
    
    func selectedAction(_ action: BurgerMenuAccountDetailsAction) {
        let account: AccountDataType!
        if case .shieldedBalance = action, self.account.showsShieldedBalance {
            // if we are hiding it, we hide it here directly
            account = self.account.withShowShielded(!self.account.showsShieldedBalance)
        } else {
            account = self.account
        }
     
        self.delegate?.pressedOption(action: action, account: account)
        self.dismissDelegate?.bugerMenuDismissedWithAction(_action: action)
    }

    func pressedDismiss() {
        selectedAction(.dismiss)
    }
}
