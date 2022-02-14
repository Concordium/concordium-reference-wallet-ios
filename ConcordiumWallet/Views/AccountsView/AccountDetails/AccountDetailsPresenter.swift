//
//  AccountDetailsPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/30/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

enum AccountDetailTab {
    case transfers
    case identityData
}

protocol TransactionsFetcher {
    func getNextTransactions()
}

// MARK: View
protocol AccountDetailsViewProtocol: ShowAlert, Loadable {
    func bind(to viewModel: AccountDetailsViewModel)
    func showMenuButton(iconName: String)
}

// MARK: -
// MARK: Delegate
protocol AccountDetailsPresenterDelegate: AnyObject, ShowShieldedDelegate {
    func accountDetailsShowBurgerMenu(_ accountDetailsPresenter: AccountDetailsPresenter)

    func accountDetailsPresenterSend(_ accountDetailsPresenter: AccountDetailsPresenter)
    func accountDetailsPresenterShieldUnshield(_ accountDetailsPresenter: AccountDetailsPresenter)
    func accountDetailsPresenterAddress(_ accountDetailsPresenter: AccountDetailsPresenter)
    func accountDetailsPresenter(_ accountDetailsPresenter: AccountDetailsPresenter, retryFailedAccount: AccountDataType)
    func accountDetailsPresenter(_ accountDetailsPresenter: AccountDetailsPresenter, removeFailedAccount: AccountDataType)

    func transactionSelected(viewModel: TransactionViewModel)
    func accountDetailsClosed()
}

// MARK: -
// MARK: Presenter
protocol AccountDetailsPresenterProtocol: AnyObject {
    var view: AccountDetailsViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    
    func getTitle() -> String
    func userTappedSend()
    func userTappedShieldUnshield()
    func userTappedAddress()
    func userTappedRetryAccountCreation()
    func userTappedRemoveFailedAccount()
    func gtuDropTapped()
    func burgerButtonTapped()
    func pressedUnlock()

    func userSelectedIdentityData()
    func userSelectedGeneral()
    func userSelectedShieled() 
    func userSelectedTransfers()

    func showGTUDrop() -> Bool
    func getIdentityDataPresenter() -> AccountDetailsIdentityDataPresenter
    func getTransactionsDataPresenter() -> AccountTransactionsDataPresenter
    func updateTransfersOnChanges()
}

class AccountDetailsPresenter {

    weak var view: AccountDetailsViewProtocol?
    weak var delegate: (AccountDetailsPresenterDelegate & RequestPasswordDelegate)?
    private let storageManager: StorageManagerProtocol

    var account: AccountDataType
    private var balanceType: AccountBalanceTypeEnum
    private var cancellables: [AnyCancellable] = []
    private var viewModel: AccountDetailsViewModel

    private var transactionsPresenter: AccountTransactionsDataPresenter?

    private var accountsService: AccountsServiceProtocol
    private let transactionsLoadingHandler: TransactionsLoadingHandler
    
    private var shouldRefresh: Bool = true
    private var lastRefreshTime: Date = Date()
    
    private var lastTransactionListAll: [TransactionViewModel] = []
    
    init(dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
         account: AccountDataType,
         balanceType: AccountBalanceTypeEnum,
         delegate: (AccountDetailsPresenterDelegate & RequestPasswordDelegate)? = nil) {
        self.accountsService = dependencyProvider.accountsService()
        self.storageManager = dependencyProvider.storageManager()
        self.account = account
        self.delegate = delegate
        self.balanceType = balanceType
        
        viewModel = AccountDetailsViewModel(account: account, balanceType: balanceType)
        transactionsLoadingHandler = TransactionsLoadingHandler(account: account, balanceType: balanceType, dependencyProvider: dependencyProvider)
    }
}

extension AccountDetailsPresenter: AccountDetailsPresenterProtocol {
    
    func showGTUDrop() -> Bool {
        if balanceType == .shielded {
            return false
        }
        return true
    }
    
    func getTitle() -> String {
        if balanceType == .shielded {
            return self.account.displayName + " " + "accountDetails.generalshieldedbalance".localized
        } else {
            return self.account.displayName + " " + "accountDetails.generalbalance".localized
        }
    }
    
    func viewDidLoad() {
        view?.bind(to: viewModel)
    }
    
    func setShouldRefresh(_ refresh: Bool) {
        shouldRefresh = refresh
    }
    
    func showShieldedBalance(shouldShow: Bool) {
        account = account.withShowShielded(shouldShow)
        switchToBalanceType(self.balanceType)
    }
    
    func switchToBalanceType(_ balanceType: AccountBalanceTypeEnum) {
        self.balanceType = balanceType
        viewModel.setAccount(account: account, balanceType: balanceType)
        transactionsLoadingHandler.updateBalanceType(balanceType)
        for cancellable in cancellables {
            cancellable.cancel()
        }
        cancellables = []
        view?.bind(to: viewModel)
    }
    
    func updateTransfersOnChanges() {
        if lastRefreshTime.timeIntervalSinceNow * -1 < 60 { return }
        guard let delegate = delegate else { return }
        if viewModel.selectedTab == .transfers {
            accountsService.updateAccountBalancesAndDecryptIfNeeded(account: account, balanceType: balanceType, requestPasswordDelegate: delegate)
                .mapError(ErrorMapper.toViewError)
                .sink(receiveError: { [weak self] error in
                    self?.view?.showErrorAlert(error)
                    }, receiveValue: { [weak self] account in
                        self?.getTransactionsUpdateOnChanges()
                        if let balanceType = self?.balanceType {
                            self?.viewModel.setAccount(account: account, balanceType: balanceType)
                        }
                        self?.lastRefreshTime = Date()
                }).store(in: &cancellables)
        }
    }
    
    fileprivate func updateTransfers() {
        accountsService.updateAccountBalancesAndDecryptIfNeeded(account: account, balanceType: balanceType, requestPasswordDelegate: delegate!)
            .mapError(ErrorMapper.toViewError)
            .sink(receiveError: { [weak self] error in
                self?.view?.showErrorAlert(error)
                }, receiveValue: { [weak self] account in
                    // We cannot get transactions from server before we have updated our
                    // local store of transactions in the updateAccountsBalances call
                    self?.getTransactions()
                    if let balanceType = self?.balanceType {
                        self?.viewModel.setAccount(account: account, balanceType: balanceType)
                    }
                    self?.lastRefreshTime = Date()
            }).store(in: &cancellables)
    }

    func viewWillAppear() {
        if shouldRefresh {
            updateTransfers()
            shouldRefresh = false
        }
    }
    
    func viewWillDisappear() {
        delegate?.accountDetailsClosed()
        transactionsPresenter?.viewUnload()
    }
    
    func userTappedSend() {
        guard let delegate = delegate else { return }
        accountsService.recalculateAccountBalance(account: account, balanceType: balanceType)
            .mapError(ErrorMapper.toViewError)
            .sink(receiveError: { [weak self] error in
                self?.view?.showErrorAlert(error)
                }, receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    delegate.accountDetailsPresenterSend(self)
                    self.shouldRefresh = true
            }).store(in: &cancellables)
    }

    func userTappedShieldUnshield() {
        guard let delegate = delegate else { return }
        accountsService.recalculateAccountBalance(account: account, balanceType: balanceType)
            .mapError(ErrorMapper.toViewError)
            .sink(receiveError: { [weak self] error in
                self?.view?.showErrorAlert(error)
                }, receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    delegate.accountDetailsPresenterShieldUnshield(self)
                    self.shouldRefresh = true
            }).store(in: &cancellables)
    }
    
    func userTappedAddress() {
        delegate?.accountDetailsPresenterAddress(self)
        shouldRefresh = true
    }

    func userTappedRetryAccountCreation() {
        storageManager.removeAccount(account: nil)
        delegate?.accountDetailsPresenter(self, retryFailedAccount: account)
        shouldRefresh = true
    }

    func userTappedRemoveFailedAccount() {
        storageManager.removeAccount(account: nil)
        delegate?.accountDetailsPresenter(self, removeFailedAccount: account)
    }

     func burgerButtonTapped() {
        viewModel.toggleMenu()
        delegate?.accountDetailsShowBurgerMenu(self)
    }

    func pressedUnlock() {
        guard let delegate = delegate else { return }
        transactionsLoadingHandler.decryptUndecryptedTransactions(requestPasswordDelegate: delegate)
            .mapError(ErrorMapper.toViewError)
            .sink(receiveError: {[weak self] error in
                self?.view?.showErrorAlert(error)
                }, receiveValue: { [weak self] _ in
                    self?.updateTransfers()
            }).store(in: &cancellables)
    }
    
    func userSelectedShieled() {
        if balanceType != .shielded {
            switchToBalanceType(.shielded)
            userSelectedTransfers()
        }
    }
    
    func userSelectedGeneral() {
        if balanceType != .balance {
            switchToBalanceType(.balance)
            userSelectedTransfers()
        }
    }
    
    func userSelectedIdentityData() {
        viewModel.selectedTab = .identityData
    }

    func userSelectedTransfers() {
        updateTransfers()
        viewModel.selectedTab = .transfers
    }

    func getIdentityDataPresenter() -> AccountDetailsIdentityDataPresenter {
        AccountDetailsIdentityDataPresenter(account: account)
    }

    func getTransactionsDataPresenter() -> AccountTransactionsDataPresenter {
        transactionsPresenter = AccountTransactionsDataPresenter(
                delegate: self, account: account,
                viewModel: viewModel.transactionsList,
                transactionsFetcher: self)
        return transactionsPresenter!
    }

    func gtuDropTapped() {
        accountsService.gtuDrop(for: account.address)
                .mapError(ErrorMapper.toViewError)
                .sink(receiveError: { [weak self] in
                    self?.view?.showErrorAlert($0)
                }, receiveValue: { [weak self] _ in
                    self?.updateTransfers()
                })
                .store(in: &cancellables)
        updateTransfers()
    }

    func getTransactionsUpdateOnChanges() {
        let transactionCall = transactionsLoadingHandler.getTransactions(startingFrom: nil).eraseToAnyPublisher()

        transactionCall
                .mapError(ErrorMapper.toViewError)
                .sink(receiveError: {[weak self] error in
                    self?.view?.showErrorAlert(error)
                }, receiveValue: { [weak self] (transactionsListFiltered, transactionListAll) in
                    guard let self = self else { return }

                    // Any changes since last auto update?
                    let equal = zip(transactionListAll, self.lastTransactionListAll)
                        .enumerated()
                        .filter { $1.0.details.transactionHash == $1.1.details.transactionHash && $1.0.status == $1.1.status }
                        .map { $1.0 }

                    if equal.count != transactionListAll.count {
                        self.lastTransactionListAll = transactionListAll

                        self.viewModel.setTransactions(transactions: transactionsListFiltered)
                        self.viewModel.hasTransfers = self.viewModel.transactionsList.transactions.count > 0
                        self.viewModel.setAllAccountTransactions(transactions: transactionListAll)

                        if transactionsListFiltered.count == 0 &&
                            transactionListAll.count != 0 &&
                            transactionListAll.last?.isLast != true {
                            self.getTransactions(startingFrom: transactionListAll.last)
                        }
                    }
                }).store(in: &cancellables)
    }
    
    func getTransactions(startingFrom: TransactionViewModel? = nil) {

        var transactionCall = transactionsLoadingHandler.getTransactions(startingFrom: startingFrom).eraseToAnyPublisher()

        if startingFrom == nil {// Only show loading indicator (blocking the view) in the first call
            transactionCall = transactionCall.showLoadingIndicator(in: self.view).eraseToAnyPublisher()
        }

        transactionCall
                .mapError(ErrorMapper.toViewError)
                .sink(receiveError: {[weak self] error in
                    self?.view?.showErrorAlert(error)
                }, receiveValue: { [weak self] (transactionsListFiltered, transactionListAll) in
                    guard let self = self else { return }
                    if startingFrom == nil {
                        self.viewModel.setTransactions(transactions: transactionsListFiltered)
                        self.viewModel.setAllAccountTransactions(transactions: transactionListAll)
                    } else {
                        self.viewModel.appendTransactions(transactions: transactionsListFiltered)
                        self.viewModel.appendAllAccountTransactions(transactions: transactionListAll)
                    }
                    self.viewModel.hasTransfers = self.viewModel.transactionsList.transactions.count > 0
                    if transactionsListFiltered.count == 0 &&
                        transactionListAll.count != 0 &&
                        transactionListAll.last?.isLast != true {
                        self.getTransactions(startingFrom: transactionListAll.last)
                    }
                }).store(in: &cancellables)
    }
}

extension AccountDetailsPresenter: AccountTransactionsDataPresenterDelegate {
    func transactionSelected(_ transaction: TransactionViewModel) {
        delegate?.transactionSelected(viewModel: transaction)
    }
    
    func userSelectedDecryption(for transactionWithHash: String) {
        guard let delegate = delegate else { return }
        transactionsLoadingHandler.decryptUndecryptedTransaction(withTransactionHash: transactionWithHash, requestPasswordDelegate: delegate)
            .mapError(ErrorMapper.toViewError)
            .sink(receiveError: {[weak self] error in
                self?.view?.showErrorAlert(error)
                }, receiveValue: { [weak self] _ in
                    self?.updateTransfers()
            }).store(in: &cancellables)
    }
}

extension AccountDetailsPresenter: TransactionsFetcher {
    func getNextTransactions() {
        guard let lastRemoteTransaction = viewModel.allAccountTransactionsList.transactions.last(where: { $0.source is Transaction }),
                     lastRemoteTransaction.isLast == false else {
                       return
                   }
        let startingFrom = lastRemoteTransaction
        getTransactions(startingFrom: startingFrom)
    }
}

extension AccountDetailsPresenter: BurgerMenuDismissDelegate {
    func bugerMenuDismissedWithAction(_action action: BurgerMenuAction) {
        self.viewModel.menuState = .closed
        if case let BurgerMenuAction.shieldedBalance(shouldShow, _ ) = action {
            //we only take action here for hiding the shielded balance.
            //The showing will be done after the carousel is being presented
            if !shouldShow {
                showShieldedBalance(shouldShow: false)
            }
        }
    }
}

extension AccountDetailsPresenter: ShowShieldedDelegate {
    func onboardingCarouselSkiped() {
        showShieldedBalance(shouldShow: true)
        self.delegate?.onboardingCarouselSkiped()
    }
    
    func onboardingCarouselFinished() {
        showShieldedBalance(shouldShow: true)
        self.delegate?.onboardingCarouselFinished()
    }
}
