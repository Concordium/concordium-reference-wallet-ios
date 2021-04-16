//
//  BurgerMenuPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 04/12/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

enum BurgerMenuAction {
    case releaseSchedule
    case transferFilters
    case dismiss
}

struct BurgerMenuViewModel: Hashable {
}

// MARK: View
protocol BurgerMenuViewProtocol: class {
    func bind(to viewModel: BurgerMenuViewModel)
}

// MARK: Delegate
protocol BurgerMenuPresenterDelegate: class {
    func pressedOption(action: BurgerMenuAction, account: AccountDataType)
}

// MARK: -
// MARK: Presenter
protocol BurgerMenuPresenterProtocol: class {
    var view: BurgerMenuViewProtocol? { get set }
    func viewDidLoad()
    
    func pressedShowRelease()
    func pressedShowFilters()
    func pressedDismiss()
    
}

protocol BurgerMenuDismissDelegate: class {
    func bugerMenuDismissedWithAction(_action: BurgerMenuAction)
}

class BurgerMenuPresenter: BurgerMenuPresenterProtocol {
    weak var view: BurgerMenuViewProtocol?
    weak var delegate: BurgerMenuPresenterDelegate?
    weak var dismissDelegate: BurgerMenuDismissDelegate?
    
    private var viewModel = BurgerMenuViewModel()
    private var account: AccountDataType
    init(delegate: BurgerMenuPresenterDelegate,
         account: AccountDataType,
         dismissDelegate: BurgerMenuDismissDelegate) {
        self.delegate = delegate
        self.account = account
        self.dismissDelegate = dismissDelegate
        viewModel = BurgerMenuViewModel()
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

    func pressedDismiss() {
        self.delegate?.pressedOption(action: .dismiss, account: account)
        self.dismissDelegate?.bugerMenuDismissedWithAction(_action: .releaseSchedule)
    }
}
