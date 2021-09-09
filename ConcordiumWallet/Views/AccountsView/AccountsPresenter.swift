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
}

// MARK: View
protocol AccountsViewProtocol: ShowError, Loadable {
    func bind(to viewModel: AccountsListViewModel)
    func showIdentityFailed(reference: String, completion: @escaping () -> Void)
}

protocol AccountsPresenterProtocol: AnyObject {
    var view: AccountsViewProtocol? { get set }
    
    func viewDidLoad()
    func viewWillAppear()
    func refresh()
    
    func userPressedCreate()
    func userSelected(accountIndex: Int, balanceIndex: Int)
    func toggleExpand(accountIndex: Int)
}

class AccountsPresenter: AccountsPresenterProtocol {
    weak var view: AccountsViewProtocol?
    weak var delegate: AccountsPresenterDelegate?
    private var cancellables: [AnyCancellable] = []
    
    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider
    private var latestAccountList: [AccountDataType] = []
    
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
    }
    
    func viewWillAppear() {
        refresh(showLoadingIndicator: true)
    }
    
    func refresh() {
        refresh(showLoadingIndicator: false)
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
                // self.latestAccountList = updatedAccounts
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
    
    private func checkForIdentityFailed() {
        let identities = dependencyProvider.storageManager().getIdentities()
        let failedIdentities = identities.filter { $0.state == .failed }
        
        for identity in failedIdentities {
            guard let reference = identity.hashedIpStatusUrl else {
                return
            }
            
            // if there is an account associated with the identity, we delete the account and show the error
            if let account = dependencyProvider.storageManager().getAccounts(for: identity).first {
                dependencyProvider.storageManager().removeAccount(account: account)
                refresh()
                view?.showIdentityFailed(reference: reference) { [weak self] in
                    self?.delegate?.tryAgainIdentity()
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
                accountVM.stateUpdater = self.dependencyProvider.accountsService().getState(for: account).eraseToAnyPublisher()
            } else {
                accountVM.stateUpdater = self.dependencyProvider.identitiesService().getInitialAccountStatus(for: account)
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
}
