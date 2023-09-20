//
//  AccountDetailsPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/30/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Combine
import Foundation
import RealmSwift
import BigInt

protocol TransactionsFetcher {
    func getNextTransactions()
}

// MARK: View

protocol AccountDetailsViewProtocol: ShowAlert, Loadable {
    func bind(to viewModel: AccountDetailsViewModel)
}

// MARK: -

// MARK: Delegate

protocol AccountDetailsPresenterDelegate: ShowShieldedDelegate {
    func accountDetailsShowBurgerMenu(_ accountDetailsPresenter: AccountDetailsPresenter,
                                      balanceType: AccountBalanceTypeEnum,
                                      showsDecrypt: Bool)

    func accountDetailsPresenterSend(_ accountDetailsPresenter: AccountDetailsPresenter, balanceType: AccountBalanceTypeEnum)
    func accountDetailsPresenterShieldUnshield(_ accountDetailsPresenter: AccountDetailsPresenter, balanceType: AccountBalanceTypeEnum)
    func accountDetailsPresenterAddress(_ accountDetailsPresenter: AccountDetailsPresenter)
    func accountDetailsPresenter(_ accountDetailsPresenter: AccountDetailsPresenter, retryFailedAccount: AccountDataType)
    func accountDetailsPresenter(_ accountDetailsPresenter: AccountDetailsPresenter, removeFailedAccount: AccountDataType)
    func showEarn()
    func showManageCIS2TokensView()
    func tokenSelected(_ token: CIS2TokenSelectionRepresentable)
    func transactionSelected(viewModel: TransactionViewModel)
    func accountDetailsClosed()
}

/// Defines methods that can be called from AccountTokensViewController.
protocol AccountTokensPresenterProtocol {
    var account: AccountDataType { get }
    func userSelected(token: CIS2TokenSelectionRepresentable)
    func showManageTokensView()
    func fetchCachedTokens() -> [CIS2TokenSelectionRepresentable]
    var cachedTokensPublisher: AnyPublisher<[CIS2TokenSelectionRepresentable], Error> { get }
}

// MARK: -

// MARK: Presenter

protocol AccountDetailsPresenterProtocol: AnyObject, AccountTokensPresenterProtocol {
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
    func showEarn()

    func userSelectedGeneral()
    func userSelectedShieled()
    func showGTUDrop() -> Bool
    func createTransactionsDataPresenter() -> AccountTransactionsDataPresenter
    func updateTransfersOnChanges()
}

class AccountDetailsPresenter {
    weak var view: AccountDetailsViewProtocol?
    weak var delegate: (AccountDetailsPresenterDelegate & RequestPasswordDelegate)?
    private let storageManager: StorageManagerProtocol

    var account: AccountDataType
    private var balanceType: AccountBalanceTypeEnum = .balance
    private var cancellables: [AnyCancellable] = []
    private var viewModel: AccountDetailsViewModel

    private var transactionsPresenter: AccountTransactionsDataPresenter?

    private var accountsService: AccountsServiceProtocol
    private let transactionsLoadingHandler: TransactionsLoadingHandler
    private let cis2Service: CIS2ServiceProtocol
    private var shouldRefresh: Bool = true
    private var lastRefreshTime: Date = Date()

    private var lastTransactionListAll: [TransactionViewModel] = []

    init(dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
         account: AccountDataType,
         delegate: (AccountDetailsPresenterDelegate & RequestPasswordDelegate)? = nil) {
        accountsService = dependencyProvider.accountsService()
        storageManager = dependencyProvider.storageManager()
        cis2Service = dependencyProvider.cis2Service()
        self.account = account
        self.delegate = delegate
        viewModel = AccountDetailsViewModel(account: account, balanceType: balanceType)
        transactionsLoadingHandler = TransactionsLoadingHandler(account: account, balanceType: balanceType, dependencyProvider: dependencyProvider)
    }
}

import UIKit

struct AccountTokensViewModel {
    let name: String
    let symbol: String?
    let thumbnailURL: URL?
    let localThumbnailImage: UIImage?
    let unique: Bool?
    let balance: String
}

extension AccountDetailsPresenter: AccountDetailsPresenterProtocol {
    var cachedTokensPublisher: AnyPublisher<[CIS2TokenSelectionRepresentable], Error> {
        storageManager.getCIS2TokensPublisher(for: account.address)
            .map {
                Publishers.MergeMany(
                    $0.map { token in
                        self.cis2Service.fetchTokensBalance(
                            contractIndex: token.contractIndex,
                            contractSubindex: "0",
                            accountAddress: token.accountAddress,
                            tokenId: token.tokenId
                        )
                        .compactMap { $0.first }
                        .map {
                            CIS2TokenSelectionRepresentable(
                                contractName: token.contractName,
                                tokenId: token.tokenId,
                                balance: BigInt($0.balance) ?? .zero,
                                contractIndex: token.contractIndex,
                                name: token.name,
                                symbol: token.symbol,
                                decimals: token.decimals,
                                description: token.tokenDescription,
                                thumbnail: URL(string: token.thumbnail ?? ""),
                                unique: token.unique,
                                accountAddress: token.accountAddress
                            )
                        }
                    }
                )
                .collect()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func fetchCachedTokens() -> [CIS2TokenSelectionRepresentable] {
        storageManager.getUserStoredCIS2Tokens(for: account.address).map { $0.asRepresentable() }
    }

    func showGTUDrop() -> Bool {
        balanceType != .shielded
    }

    func getTitle() -> String {
        account.displayName
    }

    func viewDidLoad() {
        view?.bind(to: viewModel)
    }

    func setShouldRefresh(_ refresh: Bool) {
        shouldRefresh = refresh
    }

    func showShieldedBalance(shouldShow: Bool) {
        account = account.withShowShielded(shouldShow)
        if shouldShow {
            switchToBalanceType(.shielded)
        } else {
            switchToBalanceType(.balance)
        }
        updateTransfers()
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

    fileprivate func updateTransfers() {
        guard let delegate = delegate else { return }
        accountsService.updateAccountBalancesAndDecryptIfNeeded(account: account, balanceType: balanceType, requestPasswordDelegate: delegate)
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
                delegate.accountDetailsPresenterSend(self, balanceType: self.balanceType)
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
                delegate.accountDetailsPresenterShieldUnshield(self, balanceType: self.balanceType)
                self.shouldRefresh = true
            }).store(in: &cancellables)
    }

    func showEarn() {
        delegate?.showEarn()
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
        delegate?.accountDetailsShowBurgerMenu(self, balanceType: balanceType, showsDecrypt: viewModel.showUnlockButton)
    }

    func pressedUnlock() {
        guard let delegate = delegate else { return }
        transactionsLoadingHandler.decryptUndecryptedTransactions(requestPasswordDelegate: delegate)
            .mapError(ErrorMapper.toViewError)
            .sink(receiveError: { [weak self] error in
                self?.view?.showErrorAlert(error)
            }, receiveValue: { [weak self] _ in
                self?.switchToBalanceType(.shielded)
                self?.updateTransfers()
            }).store(in: &cancellables)
    }

    func userSelectedShieled() {
        if balanceType != .shielded {
            switchToBalanceType(.shielded)
            updateTransfers()
        }
    }

    func userSelectedGeneral() {
        if balanceType != .balance {
            switchToBalanceType(.balance)
            updateTransfers()
        }
    }

    func createTransactionsDataPresenter() -> AccountTransactionsDataPresenter {
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
            .sink(receiveError: { [weak self] error in
                self?.view?.showErrorAlert(error)
            }, receiveValue: { [weak self] transactionsListFiltered, transactionListAll in
                guard let self = self else { return }

                // The old implementation
//                    // Any changes since last auto update?
//                    let equal = zip(transactionListAll, self.lastTransactionListAll)
//                        .enumerated()
//                        .filter { $1.0.details.transactionHash == $1.1.details.transactionHash && $1.0.status == $1.1.status }
//                        .map { $1.0 }

                // The new implementation
                // Any changes since last auto update?
                let equalUnmapped = zip(transactionListAll, self.lastTransactionListAll)
                    .enumerated()
                    .filter { $1.0.details.transactionHash == $1.1.details.transactionHash && $1.0.status == $1.1.status }
                let equal = equalUnmapped.map { $1.0 }

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

    func getTransactions(startingFrom transaction: TransactionViewModel? = nil) {
        guard !viewModel.hasInflightTransactionListRequest(startingFrom: transaction) else { return }
        viewModel.transactionListRequestStarted(startingFrom: transaction)

        var transactionCall = transactionsLoadingHandler.getTransactions(startingFrom: transaction).eraseToAnyPublisher()

        if transaction == nil { // Only show loading indicator (blocking the view) in the first call
            transactionCall = transactionCall
                .showLoadingIndicator(in: view)
                .eraseToAnyPublisher()
        }

        transactionCall
            .mapError(ErrorMapper.toViewError)
            .handleEvents(
                receiveCompletion: { [weak self] _ in
                    self?.viewModel.transactionListRequestEnded(startingFrom: transaction)
                }
            )
            .sink(receiveError: { [weak self] error in
                self?.view?.showErrorAlert(error)
            }, receiveValue: { [weak self] transactionsListFiltered, transactionListAll in
                guard let self = self else { return }
                if transaction == nil {
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
            .sink(receiveError: { [weak self] error in
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

extension AccountDetailsPresenter: BurgerMenuAccountDetailsDismissDelegate {
    func bugerMenuDismissedWithAction(_action action: BurgerMenuAccountDetailsAction) {
        viewModel.menuState = .closed
        if case let BurgerMenuAccountDetailsAction.shieldedBalance(_, shouldShow, _) = action {
            // we only take action here for hiding the shielded balance.
            // The showing will be done after the carousel is being presented
            if !shouldShow {
                showShieldedBalance(shouldShow: false)
            }
        } else if case BurgerMenuAccountDetailsAction.decrypt = action {
            pressedUnlock()
        }
    }
}

extension AccountDetailsPresenter: ShowShieldedDelegate {
    func onboardingCarouselClosed() {
        delegate?.onboardingCarouselClosed()
    }

    func onboardingCarouselSkiped() {
        showShieldedBalance(shouldShow: true)
        delegate?.onboardingCarouselSkiped()
    }

    func onboardingCarouselFinished() {
        showShieldedBalance(shouldShow: true)
        delegate?.onboardingCarouselFinished()
    }
}

// MARK: AccountTokensPresenterProtocol

extension AccountDetailsPresenter {
    func userSelected(token: CIS2TokenSelectionRepresentable) {
        delegate?.tokenSelected(token)
    }

    func showManageTokensView() {
        delegate?.showManageCIS2TokensView()
    }
}
