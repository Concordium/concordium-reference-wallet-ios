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
    var totalAmount: String //total amount = public + everything decrypted from shielded
    var generalAmount: String //public balance
    var totalLockStatus: ShieldedAccountEncryptionStatus
    
    var owner: String?
    var isBaking: Bool = false
    var isInitialAccount: Bool = true
    
    var atDisposalName: String
    var atDisposalAmount: String
    
    var isReadOnly: Bool = false
    #warning("RNI: For the purpose of March 2022 release isDelegating will not be implemented")
    // TODO: is delegating will need to be retreived from the network and saved in the local DB
    var isDelegating: Bool = false
    
    var sendTitle: String
    var receiveTitle: String
    var moreTitle: String
    
    var areActionsEnabled = true
    private var cancellables: [AnyCancellable] = []
    @Published var state: SubmissionStatusEnum
    
    var stateUpdater: AnyPublisher<SubmissionStatusEnum, Error>? {
        didSet {
            stateUpdater?.sink(receiveError: { _ in
                /* deliberately ignore - it does not matter if the state update fails, just update it next time we load the page */
            }, receiveValue: { [weak self] state in
                self?.state = state }).store(in: &cancellables)
        }
    }
    
    init(account: AccountDataType, createMode: Bool = false) {
        sendTitle = "accounts.overview.send".localized.uppercased()
        receiveTitle = "accounts.overview.receive".localized.uppercased()
        moreTitle = "accounts.overview.more".localized.uppercased()
        address = account.address
        name = account.displayName
        
        totalName = "account.accounttotal".localized
        totalAmount = GTU(intValue: account.totalForecastBalance).displayValueWithGStroke()
        state = account.transactionStatus ?? SubmissionStatusEnum.committed
        generalAmount = GTU(intValue: account.forecastBalance).displayValueWithGStroke()
         
        // TODO: this will need fixing in a future release. We currently don't show the lock
        #warning("RNI: This has been intentionally set to decrypted for the purpose of March 2022 release")
        totalLockStatus = .decrypted
        //totalLockStatus = (account.encryptedBalanceStatus == ShieldedAccountEncryptionStatus.decrypted) ? .decrypted : .partiallyDecrypted
        
        atDisposalName = "accounts.atdisposal".localized
        
        if !createMode {
            areActionsEnabled = !account.isReadOnly //actions are enabled if the account is not readonly
            if totalLockStatus != .decrypted {
                totalAmount += " + "
            }
        } else {
            state = SubmissionStatusEnum.finalized
            areActionsEnabled = false
        }
        
        owner = account.identity?.nickname
        isInitialAccount = account.credential?.value.credential.type == "initial"
        isBaking = account.bakerId > 0
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
    @Published var warning: WarningViewModel?
}

protocol AccountsPresenterDelegate: AnyObject {
    func createNewAccount()
    func createNewIdentity()
    func userPerformed(action: AccountCardAction, on account: AccountDataType)
    func noValidIdentitiesAvailable()
    func tryAgainIdentity()
    func didSelectMakeBackup()
    func didSelectPendingIdentity(identity: IdentityDataType)
    func newTermsAvailable()
}

// MARK: View
protocol AccountsViewProtocol: ShowAlert, Loadable {
    func bind(to viewModel: AccountsListViewModel)
    func showIdentityFailed(identityProviderName: String,
                            identityProviderSupport: String,
                            reference: String,
                            completion: @escaping (_ option: IdentityFailureAlertOption) -> Void)
    func showAccountFinalizedNotification(_ notification: FinalizedAccountsNotification)
    func showShieldedTransactionsAlert(for accountName: String, acceptCompletion: @escaping () -> Void, dismissCompletion: @escaping () -> Void)
//    func showBackupWarningBanner(_ show: Bool)
    var isOnScreen: Bool { get }
}

protocol AccountsPresenterProtocol: AnyObject {
    var view: AccountsViewProtocol? { get set }

    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func refresh()
    
    func userPressedCreate()
    func userPerformed(action: AccountCardAction, on accountIndex: Int)
    func userSelectedMakeBackup()
    func userPressedWarning()
    func userPressedDisimissWarning()
}

class AccountsPresenter: AccountsPresenterProtocol {
    weak var view: AccountsViewProtocol?
    weak var delegate: AccountsPresenterDelegate?
    private var cancellables: [AnyCancellable] = []
    var warningDisplayer: WarningDisplayer
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
        self.warningDisplayer = WarningDisplayer()
        self.warningDisplayer.delegate = self
        self.warningDisplayer.$shownWarningDisplay.sink { warningVM in
            self.viewModel.warning = warningVM
        }.store(in: &cancellables)
    }
    
    func viewDidLoad() {
        view?.bind(to: viewModel)
        checkForNewTerms()
    }
    
    func viewWillAppear() {
        refresh(showLoadingIndicator: true)
        checkForBackup()
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
        self.updatePendingIdentitiesWarnings()
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

                let totalBalance = updatedAccounts.reduce(into: 0, { $0 = $0 + $1.forecastBalance })
                let atDisposal = updatedAccounts.reduce(into: 0, { $0 = $0 + $1.forecastAtDisposalBalance })
                let staked = updatedAccounts.reduce(into: 0, { $0 = $0 + $1.stakedAmount })
                
//                let countLocked = updatedAccounts.filter { $0.encryptedBalanceStatus != ShieldedAccountEncryptionStatus.decrypted }.count
//                self.viewModel.totalBalanceLockStatus = countLocked > 0 ? .encrypted : .decrypted
                #warning("RNI: Intentionally set to decrypted for MArch release")
                // TODO: readd the lock after March release
                self.viewModel.totalBalanceLockStatus = .decrypted
                self.viewModel.totalBalance = GTU(intValue: totalBalance)
                self.viewModel.atDisposal = GTU(intValue: atDisposal)
                self.viewModel.staked = GTU(intValue: staked)
                self.checkForIdentityFailed()
                self.updatePendingIdentitiesWarnings()
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
            AppSettings.needsBackupWarning = true
            checkForBackup()
            view?.showAccountFinalizedNotification(.multiple)
            finalizedAccounts.forEach { markPendingAccountAsFinalized(account: $0) }
        } else if finalizedAccounts.count == 1, let account = finalizedAccounts.first {
            AppSettings.needsBackupWarning = true
            checkForBackup()
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

    private func checkForBackup() {
        let finalizedAccounts = dependencyProvider.storageManager().getAccounts().filter { $0.transactionStatus == .finalized }
        let showWarning = finalizedAccounts.isEmpty ? false : AppSettings.needsBackupWarning
        warningDisplayer.clearBackupWarnings()
        if showWarning {
            warningDisplayer.addWarning(Warning.backup)
        }
    }
    
    private func updatePendingIdentitiesWarnings() {
        let identities = dependencyProvider.storageManager().getIdentities()
        let pendingIdentities = identities.filter { $0.state == .pending }
        warningDisplayer.clearIdentityWarnings()
        for identity in pendingIdentities {
            warningDisplayer.addWarning(Warning.identityPending(identity: identity))
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
    
    func userPerformed(action: AccountCardAction, on accountIndex: Int) {
        delegate?.userPerformed(action: action, on: accounts[accountIndex])
    }
    
    func userSelectedMakeBackup() {
        delegate?.didSelectMakeBackup()
    }
    
    func userPressedWarning() {
        warningDisplayer.pressedWarning()
    }
    
    func userPressedDisimissWarning() {
        warningDisplayer.dismissedWarning()
    }
}

extension AccountsPresenter: WarningDisplayerDelegate {
    func performAction(for warning: Warning) {
        switch warning {
        case .backup:
            delegate?.didSelectMakeBackup()
        case .identityPending(let identity):
            delegate?.didSelectPendingIdentity(identity: identity)
        }
    }
}
