//
//  AccountsPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 06/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

class AccountViewModel: Hashable {
    var address: String
    var name: String
    var totalName: String
    var totalAmount: String
    
    var generalName: String
    var generalAmount: String
    
    var shieldedName: String
    var shieldedAmount: String
    
    var totalLockStatus: ShieldedAccountEncryptionStatus
    var shieldedLockStatus: ShieldedAccountEncryptionStatus
    
    var owner: String?
    var isBaking: Bool = false
    var isInitialAccount: Bool = true
    
    var atDisposalName: String
    var atDisposalAmount: String
    
    var stakedName: String
    var stakedAmount: String
    
    var isReadOnly: Bool = false
    
    @Published var isExpanded: Bool = false
    @Published var state: SubmissionStatusEnum
    
    private var cancellables: [AnyCancellable] = []
    
    var expandedChanged = PassthroughSubject<Bool, Never>()
    
    var stateUpdater: AnyPublisher<SubmissionStatusEnum, Error>? {
        didSet {
            stateUpdater?.sink(receiveError: { _ in
                /* deliberately ignore - it does not matter if the state update fails, just update it next time we load the page */
            }, receiveValue: { [weak self] state in
                self?.state = state }).store(in: &cancellables)
        }
    }
    
    init(account: AccountDataType, createMode: Bool = false) {
        address = account.address
        //        self.balanceType = balanceType
        
        name = account.displayName
        
        totalName = "account.accounttotal".localized
        totalAmount = GTU(intValue: account.totalForecastBalance).displayValueWithGStroke()
        state = account.transactionStatus ?? SubmissionStatusEnum.committed
        
        generalName = "accounts.balance".localized
        generalAmount = GTU(intValue: account.forecastBalance).displayValueWithGStroke()
        
        shieldedName = "accounts.shieldedbalance".localized
        shieldedAmount = GTU(intValue: account.forecastEncryptedBalance).displayValueWithGStroke()
        shieldedLockStatus = account.encryptedBalanceStatus ?? .encrypted
                
        totalLockStatus = (account.encryptedBalanceStatus == ShieldedAccountEncryptionStatus.decrypted) ? .decrypted : .partiallyDecrypted
        
        atDisposalName = "accounts.atdisposal".localized
        stakedName = "accounts.staked".localized
        
        if !createMode {
            if shieldedLockStatus == .encrypted {
                shieldedAmount = ""
            } else if shieldedLockStatus == .partiallyDecrypted {
                shieldedAmount += " + "
            }
            if totalLockStatus != .decrypted {
                totalAmount += " + "
            }
        } else {
            state = SubmissionStatusEnum.finalized
        }
        
        owner = account.identity?.nickname
        isInitialAccount = account.credential?.value.credential.type == "initial"
        isBaking = account.bakerId > 0
        stakedAmount = GTU(intValue: account.stakedAmount).displayValueWithGStroke()
        atDisposalAmount = GTU(intValue: account.forecastAtDisposalBalance).displayValueWithGStroke()
        isReadOnly = account.isReadOnly
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
        hasher.combine(name)
    }
    
    static func == (lhs: AccountViewModel, rhs: AccountViewModel) -> Bool {
        lhs.address == rhs.address &&
            lhs.name == rhs.name
    }
}

enum AccountsUIState {
    case newIdentity
    case newAccount
    case showAccounts
}

enum FinalizedAccountsNotification {
    case singleAccount(accountName: String)
    case multiple
}

class AccountsListViewModel {
    @Published var viewState: AccountsUIState = .newIdentity
    @Published var accounts = [AccountViewModel]()
    @Published var totalBalance = GTU(intValue: 0)
    @Published var totalBalanceLockStatus: ShieldedAccountEncryptionStatus  = .decrypted
    @Published var atDisposal = GTU(intValue: 0)
    @Published var staked = GTU(intValue: 0)
}

protocol AccountsPresenterDelegate: AnyObject {
    func createNewAccount()
    func createNewIdentity()
    func userSelected(account: AccountDataType, balanceType: AccountBalanceTypeEnum)
    func noValidIdentitiesAvailable()
    func tryAgainIdentity()
    func didSelectMakeBackup()
    func newTermsAvailable()
}

// MARK: View
protocol AccountsViewProtocol: ShowAlert, Loadable {
    func bind(to viewModel: AccountsListViewModel)
    func showIdentityFailed(identityProviderName: String, identityProviderSupport: String, reference: String, completion: @escaping (_ option: IdentityFailureAlertOption) -> Void)
    func showAccountFinalizedNotification(_ notification: FinalizedAccountsNotification)
    var isOnScreen: Bool { get }
}

protocol AccountsPresenterProtocol: AnyObject {
    var view: AccountsViewProtocol? { get set }

    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func refresh()
    
    func userPressedCreate()
    func userSelected(accountIndex: Int, balanceIndex: Int)
    func toggleExpand(accountIndex: Int)
    func userSelectedMakeBackup()
}

class AccountsPresenter: AccountsPresenterProtocol {
    weak var view: AccountsViewProtocol?
    weak var delegate: AccountsPresenterDelegate?
    private var cancellables: [AnyCancellable] = []

    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider
    
    var accounts: [AccountDataType] = [] {
        didSet {
            updateViewState()
        }
    }
    
    private var viewModel = AccountsListViewModel()
    
    private func updateViewState() {
        if accounts.count > 0 {
            viewModel.viewState = .showAccounts
        } else if dependencyProvider.storageManager().getConfirmedIdentities().count > 0 {
            viewModel.viewState = .newAccount
        } else {
            viewModel.viewState = .newIdentity
        }
    }
    
    init(dependencyProvider: AccountsFlowCoordinatorDependencyProvider, delegate: AccountsPresenterDelegate) {
        self.dependencyProvider = dependencyProvider
        self.delegate = delegate
    }
    
    func viewDidLoad() {
        view?.bind(to: viewModel)
        checkForNewTerms()
    }
    
    func viewWillAppear() {
        refresh(showLoadingIndicator: true)
    }

    func viewDidAppear() {
        checkPendingAccountsStatusesIfNeeded()
    }
    
    func refresh() {
        refresh(showLoadingIndicator: false)
        checkPendingAccountsStatusesIfNeeded()
    }
    
    func refresh(showLoadingIndicator: Bool) {
        accounts = dependencyProvider.storageManager().getAccounts()
        var publisher = dependencyProvider.accountsService().updateAccountsBalances(accounts: accounts).eraseToAnyPublisher()
        if showLoadingIndicator {
            publisher = publisher
                .showLoadingIndicator(in: self.view)
                .eraseToAnyPublisher()
        }
        publisher
            .mapError(ErrorMapper.toViewError)
            .sink(receiveError: { [weak self] in
                self?.view?.showErrorAlert($0)
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                // Sort by created time and with readonly accounts at the end of the list.
                let updatedAccounts = $0.sorted { $0.createdTime < $1.createdTime }.sorted { !$0.isReadOnly && $1.isReadOnly }
                self.accounts = updatedAccounts
                
                self.identifyPendingAccounts(updatedAccounts: updatedAccounts)
                self.viewModel.accounts = self.createAccountViewModelWithUpdatedStatus(accounts: updatedAccounts)

                let totalBalance = updatedAccounts.reduce(into: 0, { $0 = $0 + $1.forecastBalance + $1.forecastEncryptedBalance })
                let atDisposal = updatedAccounts.reduce(into: 0, { $0 = $0 + $1.forecastAtDisposalBalance + $1.forecastEncryptedBalance })
                let staked = updatedAccounts.reduce(into: 0, { $0 = $0 + $1.stakedAmount })
                let countLocked = updatedAccounts.filter { $0.encryptedBalanceStatus != ShieldedAccountEncryptionStatus.decrypted }.count
                self.viewModel.totalBalanceLockStatus = countLocked > 0 ? .encrypted : .decrypted
                self.viewModel.totalBalance = GTU(intValue: totalBalance)
                self.viewModel.atDisposal = GTU(intValue: atDisposal)
                self.viewModel.staked = GTU(intValue: staked)
                self.checkForIdentityFailed()
            }).store(in: &cancellables)
    }
    
    private func checkPendingAccountsStatusesIfNeeded() {
        let pendingAccountsAddresses = dependencyProvider.storageManager().getPendingAccountsAddresses()
        
        guard !pendingAccountsAddresses.isEmpty else { return }
        
        var pendingAccounts: [AccountDataType] = []

        for address in pendingAccountsAddresses {
            guard let account = dependencyProvider.storageManager().getAccount(withAddress: address) else { return }
            pendingAccounts.append(account)
        }

        var pendingAccountStatusRequests = [AnyPublisher<AccountSubmissionStatus, Error>]()

        for account in pendingAccounts {
            if account.submissionId != "" {
                pendingAccountStatusRequests.append(dependencyProvider.accountsService().getState(for: account))
            } else {
                pendingAccountStatusRequests.append(dependencyProvider.identitiesService().getInitialAccountStatus(for: account))
            }
        }

        Publishers.MergeMany(pendingAccountStatusRequests)
            .collect()
            .sink(
                receiveError: { _ in },
                receiveValue: { [weak self] in
                    self?.handleFinalizedAccountsIfNeeded($0)
                })
            .store(in: &cancellables)
    }

    private func handleFinalizedAccountsIfNeeded(_ data: [AccountSubmissionStatus]) {
        let finalizedAccounts = data.filter { $0.status == .finalized }.map { $0.account }

        guard
            !finalizedAccounts.isEmpty,
            let isOnScreen = view?.isOnScreen,
            isOnScreen
        else {
            return
        }

        if finalizedAccounts.count > 1 {
            view?.showAccountFinalizedNotification(.multiple)
            finalizedAccounts.forEach { markPendingAccountAsFinalized(account: $0) }
        } else if finalizedAccounts.count == 1, let account = finalizedAccounts.first {
            view?.showAccountFinalizedNotification(.singleAccount(accountName: account.name ?? ""))
            markPendingAccountAsFinalized(account: account)
        }
    }
    
    private func markPendingAccountAsFinalized(account: AccountDataType) {
        dependencyProvider.storageManager().removePendingAccount(with: account.address)
    }

    private func identifyPendingAccounts(updatedAccounts: [AccountDataType]) {
        let newPendingAccounts = updatedAccounts
            .filter { $0.transactionStatus == .committed || $0.transactionStatus == .received }
            .map { $0.address }

        for pendingAccount in newPendingAccounts {
            dependencyProvider.storageManager().storePendingAccount(with: pendingAccount)
        }
    }
    
    private func checkForNewTerms() {
        let currentTermsHash = HashingHelper.hash(TermsHelper.currentTerms)
        let acceptedTermsHash = AppSettings.acceptedTermsHash
        
        if currentTermsHash != acceptedTermsHash {
            self.delegate?.newTermsAvailable()
        }
    }
    
    private func checkForIdentityFailed() {
        let identities = dependencyProvider.storageManager().getIdentities()
        let failedIdentities = identities.filter { $0.state == .failed }
        
        for identity in failedIdentities {
            guard let reference = identity.hashedIpStatusUrl else {
                continue
            }
            
            // if there is an account associated with the identity, we delete the account and show the error
            if let account = dependencyProvider.storageManager().getAccounts(for: identity).first {
                dependencyProvider.storageManager().removeAccount(account: account)
                let identityProviderName = identity.identityProviderName ?? ""
                //if no ip support email is present, we use Concordium's
                let identityProviderSupportEmail = identity.identityProvider?.support ?? AppConstants.Support.concordiumSupportMail
                view?.showIdentityFailed(identityProviderName: identityProviderName,
                                         identityProviderSupport: identityProviderSupportEmail,
                                         reference: reference) { [weak self] chosenAlertOption in
                    switch chosenAlertOption {
                    case .tryAgain:
                        self?.delegate?.tryAgainIdentity()
                    case .support, .copy, .cancel:
                        self?.refresh(showLoadingIndicator: false)
                    }
                }
                break // we break here because if there are more accounts that failed, we want to show that later on
            }
        }
    }
    
    private func cleanIdentitiesAndAccounts() {
        let accounts = dependencyProvider.storageManager().getAccounts().filter { $0.transactionStatus == SubmissionStatusEnum.absent }
        for account in accounts {
            dependencyProvider.storageManager().removeAccount(account: account)
        }
        let identities = dependencyProvider.storageManager().getIdentities().filter { $0.state == .failed }
        for identity in identities {
            dependencyProvider.storageManager().removeIdentity(identity)
        }
    }
    
    func createAccountViewModelWithUpdatedStatus(accounts: [AccountDataType]) -> [AccountViewModel] {
        accounts.map { account in
            let accountVM = AccountViewModel(account: account)
            
            #warning("CHECK IF IT IS INITIAL USING CREDENTIAL")
            // TODO: change to check if it is initial!!!!!
            if account.submissionId != "" {
                accountVM.stateUpdater = self.dependencyProvider
                    .accountsService()
                    .getState(for: account)
                    .map { $0.status }
                    .eraseToAnyPublisher()
            } else {
                accountVM.stateUpdater = self.dependencyProvider
                    .identitiesService()
                    .getInitialAccountStatus(for: account)
                    .map { $0.status }
                    .eraseToAnyPublisher()
            }
            return accountVM
        }
    }
    
    func userPressedCreate() {
        switch viewModel.viewState {
        case .newIdentity:
            delegate?.createNewIdentity()
        default:
            delegate?.createNewAccount()
        }
    }
    
    func userSelected(accountIndex: Int, balanceIndex: Int) {
        if balanceIndex == 1 {
            delegate?.userSelected(account: accounts[accountIndex], balanceType: .balance)
        } else if balanceIndex == 2 {
            delegate?.userSelected(account: accounts[accountIndex], balanceType: .shielded)
        }
    }
    
    func toggleExpand(accountIndex: Int) {
        let account = accounts[accountIndex]
        if let accountVM = self.viewModel.accounts.first(where: {$0.address == account.address}) {
            accountVM.isExpanded = !accountVM.isExpanded
            accountVM.expandedChanged.send(accountVM.isExpanded)
        }
    }
    
    func userSelectedMakeBackup() {
        delegate?.didSelectMakeBackup()
    }
}
