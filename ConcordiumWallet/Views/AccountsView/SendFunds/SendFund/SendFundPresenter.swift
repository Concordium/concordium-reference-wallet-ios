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
    @Published var recipientAddress: String?
    @Published var feeMessage: String?
    @Published var insufficientFunds: Bool = false
    @Published var firstBalance: String?
    @Published var firstBalanceName: String?
    @Published var secondBalance: String?
    @Published var secondBalanceName: String?
    @Published var addMemoText: String?
    @Published var showMemoRemoveButton = false
    @Published var sendButtonEnabled = false
    @Published var showMemoAndRecipient = false
    @Published var showShieldedLock = false
    @Published var pageTitle: String?
    @Published var buttonTitle: String?
    
    func setup(account: AccountDataType, transferType: TransferType) {
        switch transferType {
        case .simpleTransfer, .encryptedTransfer:
            // We show the memo and recipient for simple or encrypted transfers
            showMemoAndRecipient = true
        case .transferToSecret, .transferToPublic:
            // We hide the memo and recipient for shielding or unshielding
            showMemoAndRecipient = false
        }
        setPageAndSendButtonTitle(transferType: transferType)
        setBalancesFor(transferType: transferType, account: account)
    }
    
    func update(withRecipient recipient: RecipientDataType?) {
        recipientAddress = recipient?.address
    }
    
    func update(withMemo memo: Memo?) {
        if let memo = memo?.displayValue {
            addMemoText = memo
        } else {
            addMemoText = "sendFund.addMemo".localized
        }
        showMemoRemoveButton = (memo != nil)
    }
    
    private func setPageAndSendButtonTitle(transferType: TransferType) {
        switch transferType {
        case .simpleTransfer, .encryptedTransfer:
            pageTitle = "sendFund.pageTitle.send".localized
            buttonTitle = "sendFund.buttonTitle.send".localized
        case .transferToPublic:
            pageTitle = "sendFund.pageTitle.unshieldAmount".localized
            buttonTitle = "sendFund.buttonTitle.unshieldAmount".localized
        case .transferToSecret:
            pageTitle = "sendFund.pageTitle.shieldAmount".localized
            buttonTitle = "sendFund.buttonTitle.shieldAmount".localized
        }
    }
    private func setBalancesFor(transferType: TransferType, account: AccountDataType) {
        switch transferType {
        case .simpleTransfer, .transferToSecret:
            //for transfers from the public account, we show Total and at disposal for the public balance
            firstBalanceName = "sendFund.total".localized
            secondBalanceName = "sendFund.atDisposal".localized
            firstBalance = GTU(intValue: account.totalForecastBalance).displayValueWithGStroke()
            secondBalance = GTU(intValue: account.forecastAtDisposalBalance).displayValueWithGStroke()
        case .encryptedTransfer, .transferToPublic:
            //for transfers from the shielded account we should the public at disposal and the shielded balance
            let showLock = account.encryptedBalanceStatus == .partiallyDecrypted || account.encryptedBalanceStatus == .encrypted
            showShieldedLock = showLock
            firstBalanceName = "sendFund.balanceAtDisposal".localized
            secondBalanceName = "sendFund.shieldedBalance".localized
            firstBalance = GTU(intValue: account.forecastAtDisposalBalance).displayValueWithGStroke()
            secondBalance = GTU(intValue: account.finalizedEncryptedBalance).displayValueWithGStroke() + (showLock ? " + " : "")
        }
    }
    
}

// MARK: View
protocol SendFundViewProtocol: Loadable, ShowAlert, ShowToast {
    func bind(to viewModel: SendFundViewModel)
    var amountPublisher: AnyPublisher<String, Never> { get }
    var recipientAddressPublisher: AnyPublisher<String, Never> { get }
    
    func showMemoWarningAlert(_ completion: @escaping () -> Void)
}

// MARK: -
// MARK: Delegate
protocol SendFundPresenterDelegate: AnyObject {
    func sendFundPresenterClosed(_ presenter: SendFundPresenter)
    func sendFundPresenterAddMemo(_ presenter: SendFundPresenter, memo: Memo?)
    func sendFundPresenterSelectRecipient(_ presenter: SendFundPresenter, balanceType: AccountBalanceTypeEnum, currentAccount: AccountDataType)
    func sendFundPresenterShowScanQRCode(delegate: ScanAddressQRPresenterDelegate)
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
    func userTappedScanQR()
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
        
        // If transfertype is from/to shielded account, set recipient to own account.
        if transferType == .transferToPublic || transferType == .transferToSecret {
            let ownAccount = RecipientEntity(name: self.account.displayName, address: self.account.address)
            setSelectedRecipient(recipient: ownAccount)
        }
    }
    
    func viewDidLoad() {
        viewModel.setup(account: account, transferType: transferType)
        
        $addedMemo.sink { [weak self] memo in
            self?.viewModel.update(withMemo: memo)
        }.store(in: &cancellables)
        
        $selectedRecipient.sink { [weak self] recipient in
            self?.viewModel.update(withRecipient: recipient)
        }.store(in: &cancellables)
        
        view?.recipientAddressPublisher.sink(receiveValue: {[weak self] address in
            if !address.isEmpty {
                self?.selectedRecipient = RecipientEntity(name: "", address: address)
                self?.updateTransferCostEstimate()
            } else {
                self?.clearEstimatedTransferCost()
            }
        }).store(in: &cancellables)
        
        guard let amountPublisher = view?.amountPublisher else { return }
        
        //A publisher that returns true if the amount can be transfered from the account
        //(this publisher will return true for an empty amount)
        amountPublisher.map { [weak self] amount in
            guard let self = self else { return false }
            return !self.hasSufficientFunds(amount: amount)
        }
        .assign(to: \.insufficientFunds, on: self.viewModel)
        .store(in: &cancellables)
        
        //A publisher that returns true is the amount is sufficient and not empty
        let validAmountPublisher = amountPublisher.map { [weak self] amount -> Bool in
            if amount.isEmpty {
                return false
            }
            guard let self = self else { return false }
            return self.hasSufficientFunds(amount: amount)
        }.eraseToAnyPublisher()
        
        Publishers.CombineLatest3(viewModel.$recipientAddress, viewModel.$feeMessage, validAmountPublisher)
            .receive(on: DispatchQueue.main)
            .map { (recipientAddress, feeMessage, validAmount) in
                !(recipientAddress ?? "").isEmpty &&
                !(feeMessage ?? "").isEmpty &&
                validAmount
            }
            .assign(to: \.sendButtonEnabled, on: self.viewModel)
            .store(in: &cancellables)
        
        view?.bind(to: viewModel)
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
            updateTransferCostEstimate()
        } else {
            clearEstimatedTransferCost()
        }
    }
    
    func userTappedSelectRecipient() {
        delegate?.sendFundPresenterSelectRecipient(self, balanceType: balanceType, currentAccount: account)
    }
    
    func userTappedScanQR() {
        delegate?.sendFundPresenterShowScanQRCode(delegate: self)
    }
    
    func setSelectedRecipient(recipient: RecipientDataType) {
        selectedRecipient = recipient
        updateTransferCostEstimate()
    }
    
    func setAddedMemo(memo: Memo) {
        addedMemo = memo
        updateTransferCostEstimate()
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
    
    private func hasSufficientFunds(amount: String) -> Bool {
        guard let cost = self.cost else {
            return true
        }
        return account.canTransfer(amount: GTU(displayValue: amount),
                                   withTransferCost: cost,
                                   onBalance: balanceType)
    }
    
    private func updateTransferCostEstimate() {
        dependencyProvider.transactionsService()
            .getTransferCost(transferType: transferType, memoSize: addedMemo?.size)
            .sink(receiveError: { [weak self] (error) in
                Logger.error(error)
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }, receiveValue: { [weak self] (value) in
                let cost = GTU(intValue: (Int(value.cost) ?? 0))
                self?.cost = cost
                self?.energy = value.energy
                let feeMessage = "sendFund.feeMessage".localized + cost.displayValue()
                self?.viewModel.feeMessage = feeMessage
            }).store(in: &cancellables)
    }
    
    private func clearEstimatedTransferCost() {
        viewModel.feeMessage = nil
        cost = nil
        energy = nil
    }
}

extension SendFundPresenter: ScanAddressQRPresenterDelegate {
    func scanAddressQr(didScanAddress: String) {
        self.selectedRecipient = RecipientEntity(name: "", address: didScanAddress)
    }
}
