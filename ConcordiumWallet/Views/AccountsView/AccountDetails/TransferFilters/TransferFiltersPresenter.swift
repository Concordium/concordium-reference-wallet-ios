//
//  TransferFiltersPresenter.swift
//  Mock
//
//  Created by Concordium on 26/02/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

class TransferFiltersViewModel {
    @Published var title: String?
    @Published var showRewards: Bool = true
    @Published var showFinalRewards: Bool = true
    
    init() {}
    
    init(account: AccountDataType) {
        self.title = account.displayName + " " + "transferfilters.title".localized
    }
}

// MARK: View
protocol TransferFiltersViewProtocol: AnyObject {
    func bind(to viewModel: TransferFiltersViewModel)
}

// MARK: Delegate
protocol TransferFiltersPresenterDelegate: AnyObject {
    func refreshTransactionList()
}

// MARK: -
// MARK: Presenter
protocol TransferFiltersPresenterProtocol: AnyObject {
    var view: TransferFiltersViewProtocol? { get set }
    func viewDidLoad()
    func setShowRewardsEnabled(_ enabled: Bool)
    func setShowFinalRewardsEnabled(_ enabled: Bool)
}

class TransferFiltersPresenter: TransferFiltersPresenterProtocol {
    weak var view: TransferFiltersViewProtocol?
    weak var delegate: TransferFiltersPresenterDelegate?
 
    private var viewModel = TransferFiltersViewModel()
    private var account: AccountDataType?
    
    init(delegate: TransferFiltersPresenterDelegate, account: AccountDataType) {
        self.delegate = delegate
        self.account = account
        self.viewModel = TransferFiltersViewModel(account: account)

        self.viewModel.showRewards = self.account?.transferFilters?.showRewardTransactions ?? true
        self.viewModel.showFinalRewards = self.account?.transferFilters?.showFinalRewardTransactions ?? true
    }
    
    func viewDidLoad() {
        view?.bind(to: viewModel)
    }

    func setShowRewardsEnabled(_ enabled: Bool) {
        self.viewModel.showRewards = enabled
        self.account = self.account?.withTransferFilters(filters: TransferFilter(showRewards: self.viewModel.showRewards,
                                                                                 showFinalRewards: self.viewModel.showFinalRewards))
        // Bind sub-choice to the primary choice.
        if !enabled || (enabled && !viewModel.showFinalRewards) {
            setShowFinalRewardsEnabled(enabled)
        }
        delegate?.refreshTransactionList()
    }
    
    func setShowFinalRewardsEnabled(_ enabled: Bool) {
        self.viewModel.showFinalRewards = enabled
        self.account = self.account?.withTransferFilters(filters: TransferFilter(showRewards: self.viewModel.showRewards,
                                                                                 showFinalRewards: self.viewModel.showFinalRewards))
        
        // Enable primary choice if disabled.
        if enabled && !viewModel.showRewards {
            setShowRewardsEnabled(enabled)
        }
        delegate?.refreshTransactionList()
    }
    
}
