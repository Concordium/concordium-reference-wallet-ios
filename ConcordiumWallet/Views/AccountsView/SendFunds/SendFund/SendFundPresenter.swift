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
    @Published var sendAllVisible = true
    @Published var sendAllEnabled = false
    @Published var sendAllAmount: String?
    @Published var selectedSendAllDisposableAmount = false
    @Published var disposalAmount: GTU?
    
    func setup(account: AccountDataType, transferType: SendFundTransferType) {
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
    
    private func setPageAndSendButtonTitle(transferType: SendFundTransferType) {
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
    private func setBalancesFor(transferType: SendFundTransferType, account: AccountDataType) {
        switch transferType {
        case .simpleTransfer, .transferToSecret:
            // for transfers from the public account, we show Total and at disposal for the public balance
            firstBalanceName = "sendFund.total".localized
            secondBalanceName = "sendFund.atDisposal".localized
            // We don't show the send all button for shielding transfers as it is likely a user mistake
            sendAllVisible = transferType != .transferToSecret
            firstBalance = GTU(intValue: account.forecastBalance).displayValueWithGStroke()
            secondBalance = GTU(intValue: account.forecastAtDisposalBalance).displayValueWithGStroke()
            disposalAmount = GTU(intValue: account.forecastAtDisposalBalance)
        case .encryptedTransfer, .transferToPublic:
            // for transfers from the shielded account we should the public at disposal and the shielded balance
            let showLock = account.encryptedBalanceStatus == .partiallyDecrypted || account.encryptedBalanceStatus == .encrypted
            showShieldedLock = showLock
            firstBalanceName = "sendFund.balanceAtDisposal".localized
            secondBalanceName = "sendFund.shieldedBalance".localized
            firstBalance = GTU(intValue: account.forecastAtDisposalBalance).displayValueWithGStroke()
            secondBalance = GTU(intValue: account.finalizedEncryptedBalance).displayValueWithGStroke() + (showLock ? " + " : "")
            disposalAmount = GTU(intValue: account.finalizedEncryptedBalance)
        }
    }
    
}

// MARK: View
protocol SendFundViewProtocol: Loadable, ShowAlert, ShowToast {
    func bind(to viewModel: SendFundViewModel)
    var amountSubject: PassthroughSubject<String, Never> { get }
    var recipientAddressPublisher: AnyPublisher<String, Never> { get }
    
    func showAddressInvalid()
    func showMemoWarningAlert(_ completion: @escaping () -> Void)
}

// MARK: -
// MARK: Delegate
protocol SendFundPresenterDelegate: AnyObject {
    func sendFundPresenterClosed(_ presenter: SendFundPresenter)
    func sendFundPresenterAddMemo(_ presenter: SendFundPresenter, memo: Memo?)
    func sendFundPresenterSelectRecipient(_ presenter: SendFundPresenter, balanceType: AccountBalanceTypeEnum, currentAccount: AccountDataType)
    func sendFundPresenterShowScanQRCode(delegate: ScanQRPresenterDelegate)
    func sendFundPresenter(didSelectTransferAmount amount: GTU,
                           energyUsed energy: Int,
                           from account: AccountDataType,
                           to recipient: RecipientDataType,
                           memo: Memo?,
                           cost: GTU,
                           transferType: SendFundTransferType)
    func dismissQR()
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
    func userTappedSendAll()
    func userChangedAmount()
    func finishedEditingRecipientAddress()
    
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
    private var transferType: SendFundTransferType
    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider
    
    private var cost: GTU?
    private var energy: Int?
    
    init(account: AccountDataType,
         balanceType: AccountBalanceTypeEnum,
         transferType: SendFundTransferType,
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
                self?.selectedRecipient = RecipientEntity(name: "", address: address)
        }).store(in: &cancellables)
        
        guard let amountSubject = view?.amountSubject else { return }
        
        // A publisher that returns true if the amount can be transfered from the account
        // (this publisher will return true for an empty amount)
        // we combine with fee message to make sure the insufficient funds label is updated
        // also when the fee is calculated

        Publishers.CombineLatest(amountSubject, viewModel.$feeMessage)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { [weak self] amount, _ in
                guard let self = self else { return false }
                return !self.hasSufficientFunds(amount: amount)
            }
            .assign(to: \.insufficientFunds, on: self.viewModel)
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            viewModel.$recipientAddress,
            viewModel.$feeMessage,
            amountSubject
        )
        .receive(on: DispatchQueue.main)
        .map { [weak self] (recipientAddress, feeMessage, amount) in
            guard let self = self else { return false }
            guard let recipientAddress = recipientAddress else { return false }
            let isAddressValid = !recipientAddress.isEmpty && self.dependencyProvider.mobileWallet().check(accountAddress: recipientAddress)
            
            return isAddressValid &&
            !(feeMessage ?? "").isEmpty &&
            self.hasSufficientFunds(amount: amount)
        }
        .assign(to: \.sendButtonEnabled, on: viewModel)
        .store(in: &cancellables)
        
        viewModel.$disposalAmount
            .compactMap { $0 }
            .sink(receiveValue: { [weak self] disposalAmount in
                self?.viewModel.sendAllEnabled = disposalAmount.intValue > 0
            })
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

        sendAllFundsIfNeeded()
    }
    
    func userTappedSelectRecipient() {
        delegate?.sendFundPresenterSelectRecipient(self, balanceType: balanceType, currentAccount: account)
    }
    
    func userTappedScanQR() {
        PermissionHelper.requestAccess(for: .camera) { [weak self] permissionGranted in
            guard let self = self else { return }
            
            guard permissionGranted else {
                self.view?.showRecoverableErrorAlert(
                    .cameraAccessDeniedError,
                    recoverActionTitle: "errorAlert.continueButton".localized,
                    hasCancel: true
                ) {
                    SettingsHelper.openAppSettings()
                }
                return
            }

            self.delegate?.sendFundPresenterShowScanQRCode(delegate: self)
        }
    }
    
    func setSelectedRecipient(recipient: RecipientDataType) {
        selectedRecipient = recipient
        updateTransferCostEstimate()
        sendAllFundsIfNeeded()
    }
    
    func setAddedMemo(memo: Memo) {
        addedMemo = memo
        updateTransferCostEstimate()
        sendAllFundsIfNeeded()
    }
    
    func finishedEditingRecipientAddress() {
        guard let address = selectedRecipient?.address else { return }
        if !dependencyProvider.mobileWallet().check(accountAddress: address) {
            view?.showAddressInvalid()
            self.clearEstimatedTransferCost()
        } else {
            updateTransferCostEstimate()
        }

        sendAllFundsIfNeeded()
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
                // if we try to make a simple or an encrypted transfer to own account, we show an error
                if self.transferType == .simpleTransfer || self.transferType == .encryptedTransfer {
                    self.view?.showToast(withMessage: "sendFund.sendingToOwnAccountDisallowed".localized, time: 1)
                    return
                }
                
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
        
        if transferType == .transferToSecret {
            showShieldAmountWarningIfNeeded(amount: amount, completion: sendFund)
        } else if addedMemo == nil || AppSettings.dontShowMemoAlertWarning {
            sendFund()
        } else {
            view?.showMemoWarningAlert { sendFund() }
        }
    }

    func userChangedAmount() {
        guard viewModel.selectedSendAllDisposableAmount else { return }
        viewModel.selectedSendAllDisposableAmount = false
    }

    func userTappedSendAll() {
        guard !viewModel.selectedSendAllDisposableAmount else { return }
        viewModel.selectedSendAllDisposableAmount = true
        sendAllFundsIfNeeded()
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
        dependencyProvider
            .transactionsService()
            .getTransferCost(transferType: transferType.actualType, costParameters: TransferCostParameter.parametersForMemoSize(addedMemo?.size))
            .sink(receiveError: { [weak self] (error) in
                Logger.error(error)
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }, receiveValue: { [weak self] value in
                let cost = GTU(intValue: (Int(value.cost) ?? 0))
                self?.cost = cost
                self?.energy = value.energy
                let feeMessage = "sendFund.feeMessage".localized + cost.displayValue()
                self?.viewModel.feeMessage = feeMessage
            }).store(in: &cancellables)
    }

    private func sendAllFundsIfNeeded() {
        guard viewModel.selectedSendAllDisposableAmount else { return }

        guard let disposalAmount = viewModel.disposalAmount?.intValue else { return }

        dependencyProvider
            .transactionsService()
            .getTransferCost(transferType: transferType.actualType, costParameters: TransferCostParameter.parametersForMemoSize(addedMemo?.size))
            .sink(receiveError: { [weak self] (error) in
                Logger.error(error)
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }, receiveValue: { [weak self] value in
                guard let self = self else { return }
                let cost = GTU(intValue: Int(value.cost) ?? 0)
                let totalAmount: String!
                if self.balanceType == .shielded {
                    // the cost is always deducted from the public balance, not
                    // from the shielded
                    totalAmount = GTU(intValue: disposalAmount).displayValue()
                } else {
                    totalAmount = (GTU(intValue: disposalAmount) - cost).displayValue()
                }
                self.view?.amountSubject.send(totalAmount)
                self.viewModel.sendAllAmount = totalAmount
                self.cost = cost
                self.energy = value.energy
                let feeMessage = "sendFund.feeMessage".localized + cost.displayValue()
                self.viewModel.feeMessage = feeMessage
            }).store(in: &cancellables)

    }

    private func clearEstimatedTransferCost() {
        viewModel.feeMessage = nil
        cost = nil
        energy = nil
    }
    
    private func showShieldAmountWarningIfNeeded(amount: String, completion: @escaping () -> Void) {
        guard let disposableAmount = viewModel.disposalAmount?.intValue else {
            completion()
            return
        }
        
        let gtuAmount = GTU(displayValue: amount)
        
        let maxGTU = disposableAmount - (disposableAmount / 20) // 95% of disposableAmount
        
        if gtuAmount.intValue >= maxGTU {
            let continueAction = AlertAction(
                name: "sendFund.warning.shield.continue".localized,
                completion: completion,
                style: .default
            )
            let newAmountAction = AlertAction(
                name: "sendFund.warning.shield.newamount".localized,
                completion: nil,
                style: .default
            )
            
            let alertOptions = AlertOptions(
                title: "sendFund.warning.shield.title".localized,
                message: "sendFund.warning.shield.message".localized,
                actions: [continueAction, newAmountAction]
            )
            
            self.view?.showAlert(with: alertOptions)
        } else {
            completion()
        }
    }
}

extension SendFundPresenter: ScanQRPresenterDelegate {
    func scanQr(didScanQrCode: String) {
        self.setSelectedRecipient(recipient: RecipientEntity(name: "", address: didScanQrCode))
        self.delegate?.dismissQR()
    }
}
