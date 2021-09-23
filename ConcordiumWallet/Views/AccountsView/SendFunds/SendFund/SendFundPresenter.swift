//
//  SendFundPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/7/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

class SendFundViewModel {
    @Published var recipientName: String?
    @Published var selectRecipientText: String?
    @Published var addMemoText: String?
    @Published var feeMessage: String?
    @Published var isRecipientNameFaded = false
    @Published var errorMessage: String?
    @Published var sendButtonEnabled = false
    @Published var imageName: String? = "QR_code_icon"
    @Published var accountBalance: String?
    @Published var accountBalanceShielded: String?
    @Published var memo: Memo?
}

// MARK: View
protocol SendFundViewProtocol: Loadable, ShowError, ShowToast {
    func bind(to viewModel: SendFundViewModel)
    var amountPublisher: AnyPublisher<String, Never> { get }
    var buttonTitle: String? { get set }
    var pageTitle: String? { get set }
    var showSelectRecipient: Bool { get set }
    var showShieldedLock: Bool { get set }
    var showMemo: Bool { get set }
    func showMemoWarningAlert(_ completion: @escaping () -> Void)
}

// MARK: -
// MARK: Delegate
protocol SendFundPresenterDelegate: AnyObject {
    func sendFundPresenterClosed(_ presenter: SendFundPresenter)
    func sendFundPresenterAddMemo(_ presenter: SendFundPresenter, memo: Memo?)
    func sendFundPresenterSelectRecipient(_ presenter: SendFundPresenter, balanceType: AccountBalanceTypeEnum, currentAccount: AccountDataType)
    func sendFundPresenter(didSelectTransferAmount amount: GTU,
                           energyUsed energy: Int,
                           from account: AccountDataType,
                           to recipient: RecipientDataType,
                           memo: Memo?,
                           cost: GTU,
                           transferType: TransferType)
}

// MARK: -
// MARK: Presenter
protocol SendFundPresenterProtocol: AnyObject {
	var view: SendFundViewProtocol? { get set }
    func viewDidLoad()
    
    func userTappedClose()
    func userTappedSelectRecipient()
    func userTappedAddMemo()
    func userTappedRemoveMemo()
    func userTappedSendFund(amount: String)
    func userTappedDontShowMemoAlertAgain(_ completion: @escaping () -> Void)
    
    // By coordinator
    func setSelectedRecipient(recipient: RecipientDataType)
    func setAddedMemo(memo: Memo)
}

class SendFundPresenter: SendFundPresenterProtocol {
    weak var view: SendFundViewProtocol?
    weak var delegate: SendFundPresenterDelegate?
    
    @Published private var selectedRecipient: RecipientDataType?
    @Published private var addedMemo: Memo?
    
    private var cancellables = [AnyCancellable]()

    private var viewModel = SendFundViewModel()

    private var account: AccountDataType
    private var balanceType: AccountBalanceTypeEnum
    private var transferType: TransferType
    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider
    
    private var cost: GTU?
    private var energy: Int?

    init(account: AccountDataType,
         balanceType: AccountBalanceTypeEnum,
         transferType: TransferType,
         dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
         delegate: SendFundPresenterDelegate? = nil) {
        self.account = account
        self.balanceType = balanceType
        self.transferType = transferType
        self.delegate = delegate
        self.dependencyProvider = dependencyProvider
    }

    func viewDidLoad() {
        $selectedRecipient
            .map({$0?.name})
            .assign(to: \.recipientName, on: viewModel)
            .store(in: &cancellables)
        
        $selectedRecipient
            .map({($0?.name.isEmpty ?? true)})
            .assign(to: \.isRecipientNameFaded, on: viewModel)
            .store(in: &cancellables)
        
        $addedMemo
            .assign(to: \.memo, on: viewModel)
            .store(in: &cancellables)
        
        $addedMemo
            .sink { [weak self] memo in
                if let memo = memo?.memo {
                    self?.viewModel.addMemoText = memo
                } else {
                    self?.viewModel.addMemoText = "sendFund.addMemo".localized
                }
            }
            .store(in: &cancellables)

        // Show disposable balance.
        viewModel.accountBalance = GTU(intValue: account.forecastAtDisposalBalance).displayValueWithGStroke()
        viewModel.accountBalanceShielded = GTU(intValue: account.finalizedEncryptedBalance).displayValueWithGStroke()
        
        let showLock = account.encryptedBalanceStatus == .partiallyDecrypted || account.encryptedBalanceStatus == .encrypted
        view?.showShieldedLock = showLock
                
        viewModel.sendButtonEnabled = false
        viewModel.selectRecipientText = "sendFund.selectRecipient".localized
        
        setPageAndSendButtonTitle()

        // If transfertype is from/to shielded account, set recipient to own account.
        if transferType == .transferToPublic || transferType == .transferToSecret {
            let ownAccount = RecipientEntity(name: self.account.displayName, address: self.account.address)
            setSelectedRecipient(recipient: ownAccount)
            view?.showSelectRecipient = false
            view?.showMemo = false
        } else {
            viewModel.addMemoText = "sendFund.addMemo".localized
        }
        
        assignSendButtonEnabled()
        
        view?.bind(to: viewModel)
    }
    
    private func assignSendButtonEnabled() {
        guard let amountPublisher = view?.amountPublisher else { return }
        
        Publishers.CombineLatest3(
            viewModel.$recipientName,
            viewModel.$feeMessage,
            amountPublisher
        )
        .receive(on: DispatchQueue.main)
        .map { [weak self] (recipientName, feeMessage, amount) in
            guard let self = self else { return false }
            
            if !self.hasSufficientFunds(amount: amount) {
                self.viewModel.errorMessage = "sendFund.insufficientFunds".localized
            } else {
                self.viewModel.errorMessage = ""
            }
            
            return
                !(recipientName ?? "").isEmpty &&
                !(feeMessage ?? "").isEmpty &&
                !amount.isEmpty &&
                self.hasSufficientFunds(amount: amount)
        }
        .assign(to: \.sendButtonEnabled, on: viewModel)
        .store(in: &cancellables)
    }

    private func hasSufficientFunds(amount: String) -> Bool {
        guard let cost = self.cost else {
            return true
        }
        
        if balanceType == .balance {
            let balance = self.account.forecastAtDisposalBalance
            return GTU(displayValue: amount).intValue + cost.intValue <= balance
        } else {
            return GTU(displayValue: amount).intValue <= self.account.forecastEncryptedBalance && cost.intValue <= self.account.forecastBalance
        }
    }

    func userTappedClose() {
        delegate?.sendFundPresenterClosed(self)
    }
    
    func userTappedAddMemo() {
        delegate?.sendFundPresenterAddMemo(self, memo: addedMemo)
    }
    
    func userTappedRemoveMemo() {
        addedMemo = nil
        
        if selectedRecipient != nil {
            estimateTransferCost()
        } else {
            restEstimatedTransferCost()
        }
    }
    
    func userTappedSelectRecipient() {
        delegate?.sendFundPresenterSelectRecipient(self, balanceType: balanceType, currentAccount: account)
    }

    func setSelectedRecipient(recipient: RecipientDataType) {
        let recipientName: String
        let isOwnAccountTransfer = recipient.address == self.account.address

        if isOwnAccountTransfer {
            if balanceType == .shielded {
                transferType = .transferToPublic
                recipientName = "accounts.amountwillbeunshielded".localized
                viewModel.imageName = ""
            } else {
                transferType = .transferToSecret
                recipientName = "accounts.amountwillbeshielded".localized
                viewModel.imageName = "Icon_Shield_Send_Funds"
            }
        } else {
             recipientName = recipient.name
            if balanceType == .shielded {
                transferType = .encryptedTransfer
                viewModel.imageName = "Icon_Shield_Send_Funds"
            } else {
                transferType = .simpleTransfer
                viewModel.imageName = ""
            }
        }
        
        let updatedRecipient = RecipientEntity(name: recipientName, address: recipient.address)
        selectedRecipient = updatedRecipient
        
        estimateTransferCost()
        setPageAndSendButtonTitle()
    }
    
    private func estimateTransferCost() {
        dependencyProvider.transactionsService()
            .getTransferCost(transferType: transferType, memoSize: addedMemo?.size)
            .sink(receiveError: { [weak self] (error) in
                Logger.error(error)
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }, receiveValue: { [weak self] (value) in
                self?.cost = GTU(intValue: (Int(value.cost) ?? 0))
                self?.energy = value.energy
                let feeMessage = "sendFund.feeMessage".localized + GTU(intValue: Int(value.cost) ?? 0).displayValue()
                self?.viewModel.feeMessage = feeMessage
            }).store(in: &cancellables)
    }
    
    private func restEstimatedTransferCost() {
        viewModel.feeMessage = nil
        cost = nil
        energy = nil
    }
    
    func setAddedMemo(memo: Memo) {
        addedMemo = memo
        estimateTransferCost()
    }
    
    func userTappedSendFund(amount: String) {
        let sendFund = { [weak self] in
            guard
                let self = self,
                let selectedRecipient = self.selectedRecipient,
                let cost = self.cost,
                let energy = self.energy
            else {
                // never happens since button is disabled in this case
                return
            }
            
            let recipient: RecipientDataType
            if selectedRecipient.address == self.account.address {
                recipient = RecipientEntity(name: self.account.displayName, address: self.account.address)
            } else {
                recipient = selectedRecipient
            }
            
            self.delegate?.sendFundPresenter(
                didSelectTransferAmount: GTU(displayValue: amount),
                energyUsed: energy,
                from: self.account,
                to: recipient,
                memo: self.addedMemo,
                cost: cost,
                transferType: self.transferType
            )
        }
        
        if addedMemo == nil || AppSettings.dontShowMemoAlertWarning {
            sendFund()
        } else {
            view?.showMemoWarningAlert { sendFund() }
        }
    }
    
    func userTappedDontShowMemoAlertAgain(_ completion: @escaping () -> Void) {
        AppSettings.dontShowMemoAlertWarning = true
        completion()
    }

    func setPageAndSendButtonTitle() {
        switch transferType {
        case .simpleTransfer, .encryptedTransfer:
            view?.pageTitle = "sendFund.pageTitle.send".localized
            view?.buttonTitle = "sendFund.buttonTitle.send".localized
        case .transferToPublic:
            view?.pageTitle = "sendFund.pageTitle.unshieldAmount".localized
            view?.buttonTitle = "sendFund.buttonTitle.unshieldAmount".localized
        case .transferToSecret:
            view?.pageTitle = "sendFund.pageTitle.shieldAmount".localized
            view?.buttonTitle = "sendFund.buttonTitle.shieldAmount".localized
        }
    }
}
