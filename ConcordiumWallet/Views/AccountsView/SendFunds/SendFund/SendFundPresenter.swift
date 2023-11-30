//
//  SendFundPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/7/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import BigInt
import Combine
import Foundation

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
    @Published var enteredAmount: SendFundsAmount?
    @Published var selectedTokenType: SendFundsTokenType = .ccd
    private var cancellables: Set<AnyCancellable> = []
    func setup(account: AccountDataType, transferType: SendFundTransferType, tokenType: SendFundsTokenType) {
        switch transferType {
        case .simpleTransfer, .encryptedTransfer:
            // We show the memo and recipient for simple or encrypted transfers
            showMemoAndRecipient = true
        case .transferToSecret, .transferToPublic, .contractUpdate:
            // We hide the memo and recipient for shielding or unshielding
            showMemoAndRecipient = false
        }

        setPageAndSendButtonTitle(transferType: transferType)
        setBalancesFor(transferType: transferType, account: account)
        selectedTokenType = tokenType
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
        case .simpleTransfer, .encryptedTransfer, .contractUpdate:
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

    func setBalancesFor(transferType: SendFundTransferType, account: AccountDataType) {
        switch transferType {
        case .contractUpdate:
            if case let SendFundsTokenType.cis2(token: token) = selectedTokenType {
                firstBalanceName = "\(token.symbol ?? token.name) balance: "
                secondBalanceName = "sendFund.atDisposal".localized
                firstBalance = token.balanceDisplayValue
            }
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
    var selectedTokenType: PassthroughSubject<SendFundsTokenType, Never> { get }
    func showAddressInvalid()
    func showMemoWarningAlert(_ completion: @escaping () -> Void)
}

// MARK: -

// MARK: Delegate

protocol SendFundPresenterDelegate: AnyObject {
    func sendFundPresenterClosed(_ presenter: SendFundPresenter)
    func sendFundPresenter(_ presenter: SendFundPresenter, didUpdate sendFundsTokenType: SendFundsTokenType)
    func sendFundPresenterAddMemo(_ presenter: SendFundPresenter, memo: Memo?)
    func sendFundPresenterSelectRecipient(_ presenter: SendFundPresenter, balanceType: AccountBalanceTypeEnum, currentAccount: AccountDataType)
    func sendFundPresenterShowScanQRCode(didScanQRCode: @escaping ((String) -> Void))
    func sendFundPresenter(didSelectTransferAmount amount: SendFundsAmount,
                           energyUsed energy: Int,
                           from account: AccountDataType,
                           to recipient: RecipientDataType,
                           memo: Memo?,
                           cost: GTU,
                           transferType: SendFundTransferType)
    func dismissQR()
    func sendFundPresenterShowTokenTypeSelector(didSelectToken: @escaping ((CIS2TokenSelectionRepresentable?) -> Void))
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
    func userTappedSendFund()
    func userTappedDontShowMemoAlertAgain(_ completion: @escaping () -> Void)
    func userTappedSendAll()
    func userChangedAmount()
    func finishedEditingRecipientAddress()
    func selectTokenType()

    // By coordinator
    func setSelectedRecipient(recipient: RecipientDataType)
    func setAddedMemo(memo: Memo)
}

struct FungibleToken {
    var intValue: BigInt
    let decimals: Int
    let conversionFactor: BigInt
    let symbol: String?
    init(displayValue: String, decimals: Int, symbol: String?) {
        let wholePart = BigInt(displayValue.unsignedWholePart)
        let conversionFactor = BigInt(pow(10.0, Double(decimals)))
        let fractionalPart = BigInt(displayValue.fractionalPart(precision: decimals))
        self.conversionFactor = conversionFactor
        self.symbol = symbol
        self.decimals = decimals
        intValue = wholePart * conversionFactor + fractionalPart
    }

    var displayValue: String {
        intValue.formatIntegerWithFractionDigits(fractionDigits: decimals) + (symbol ?? "")
    }
}

enum SendFundsAmount {
    case ccd(GTU)
    case fungibleToken(token: FungibleToken)
    case nonFungibleToken(name: String?)

    var intValue: BigInt {
        switch self {
        case let .ccd(gtu):
            return BigInt(gtu.intValue)
        case let .fungibleToken(token: amount):
            return amount.intValue
        case .nonFungibleToken:
            return 1
        }
    }

    var displayValue: String {
        switch self {
        case let .ccd(gtu):
            return gtu.displayValueWithGStroke()
        case let .fungibleToken(token):
            return token.displayValue
        case let .nonFungibleToken(name):
            return name ?? " - "
        }
    }
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
    private var tokenType: SendFundsTokenType

    init(account: AccountDataType,
         balanceType: AccountBalanceTypeEnum,
         transferType: SendFundTransferType,
         dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
         delegate: SendFundPresenterDelegate? = nil,
         tokenType: SendFundsTokenType
    ) {
        self.account = account
        self.balanceType = balanceType
        self.transferType = transferType
        self.delegate = delegate
        self.dependencyProvider = dependencyProvider
        self.tokenType = tokenType

        // If transfertype is from/to shielded account, set recipient to own account.
        if transferType == .transferToPublic || transferType == .transferToSecret {
            let ownAccount = RecipientEntity(name: self.account.displayName, address: self.account.address)
            setSelectedRecipient(recipient: ownAccount)
        }
    }

    func viewDidLoad() {
        viewModel.setup(account: account, transferType: transferType, tokenType: tokenType)

        $addedMemo.sink { [weak self] memo in
            self?.viewModel.update(withMemo: memo)
        }.store(in: &cancellables)

        $selectedRecipient.sink { [weak self] recipient in
            self?.viewModel.update(withRecipient: recipient)
        }.store(in: &cancellables)

        view?.recipientAddressPublisher.sink(receiveValue: { [weak self] address in
            self?.selectedRecipient = RecipientEntity(name: "", address: address)
        }).store(in: &cancellables)

        // Unwrapping the publisher that emits string value from amount text field.
        guard let amountSubject = view?.amountSubject else { return }

        // Map the amount value to `SendFundsAmount`
        amountSubject.compactMap { [unowned self] in
            switch viewModel.selectedTokenType {
            case .ccd:
                return SendFundsAmount.ccd(GTU(displayValue: $0))
            case let SendFundsTokenType.cis2(token: token):
                if token.unique {
                    return .nonFungibleToken(name: token.name)
                } else {
                    return .fungibleToken(token: FungibleToken(displayValue: $0, decimals: token.decimals, symbol: token.name))
                }
            }
        }
        .assign(to: \.enteredAmount, on: viewModel)
        .store(in: &cancellables)

        // A publisher that returns true if the amount can be transfered from the account
        // (this publisher will return true for an empty amount)
        // we combine with fee message to make sure the insufficient funds label is updated
        // also when the fee is calculated
        Publishers.CombineLatest(viewModel.$enteredAmount, viewModel.$feeMessage)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { [weak self] amount, _ in
                guard let self = self, let amount = amount else { return false }
                return !self.hasSufficientFunds(amount: amount)
            }
            .assign(to: \.insufficientFunds, on: viewModel)
            .store(in: &cancellables)

        Publishers.CombineLatest3(
            viewModel.$recipientAddress,
            viewModel.$feeMessage,
            viewModel.$enteredAmount
        )
        .receive(on: DispatchQueue.main)
        .map { [weak self] recipientAddress, feeMessage, amount in
            // Called when editing the amount or address.
            guard let self = self,
                  let recipientAddress = recipientAddress,
                  let amount = amount else { return false }
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

    func selectTokenType() {
        delegate?.sendFundPresenterShowTokenTypeSelector(didSelectToken: { [weak self] token in
            guard let self = self else { return }
            if let token = token {
                self.viewModel.selectedTokenType = .cis2(token: token)
                self.transferType = .contractUpdate
                self.viewModel.setBalancesFor(transferType: .contractUpdate, account: self.account)
            } else {
                self.transferType = .simpleTransfer
                self.viewModel.selectedTokenType = .ccd
                self.viewModel.setBalancesFor(transferType: .simpleTransfer, account: self.account)
            }
            self.delegate?.sendFundPresenter(self, didUpdate: viewModel.selectedTokenType)
            self.updateTransferCostEstimate()
        })
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

            self.delegate?.sendFundPresenterShowScanQRCode(didScanQRCode: { [weak self] address in
                guard let self = self else { return }
                // Validating address in SendFundsCoordinator.showScanAddressQR.
                self.setSelectedRecipient(recipient: RecipientEntity(name: "", address: address))
                self.delegate?.dismissQR()
            })
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
        // Called when keyboard is dismissed after editing receiver address.
        guard let address = selectedRecipient?.address else { return }
        if !dependencyProvider.mobileWallet().check(accountAddress: address) {
            view?.showAddressInvalid()
            clearEstimatedTransferCost()
        } else {
            updateTransferCostEstimate()
        }

        sendAllFundsIfNeeded()
    }

    func userTappedSendFund() {
        let sendFund = { [weak self] in
            guard
                let self = self,
                let selectedRecipient = self.selectedRecipient,
                let cost = self.cost,
                let energy = self.energy,
                let enteredAmount = viewModel.enteredAmount
            else {
                // never happens since button is disabled in this case
                return
            }
            
            let recipient: RecipientDataType
            if selectedRecipient.address == account.address {
                // if we try to make a simple or an encrypted transfer to own account, we show an error
                if transferType == .simpleTransfer || transferType == .encryptedTransfer {
                    view?.showToast(withMessage: "sendFund.sendingToOwnAccountDisallowed".localized, time: 1)
                    return
                }
                
                recipient = RecipientEntity(name: account.displayName, address: account.address)
            } else {
                recipient = selectedRecipient
            }
            
            
            delegate?.sendFundPresenter(
                didSelectTransferAmount: enteredAmount,
                energyUsed: energy,
                from: account,
                to: recipient,
                memo: addedMemo,
                cost: cost,
                transferType: transferType
            )
        }

        if transferType == .transferToSecret {
            showShieldAmountWarningIfNeeded(completion: sendFund)
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

    private func hasSufficientFunds(amount: SendFundsAmount) -> Bool {
        guard let cost = cost else { return true }

        switch viewModel.selectedTokenType {
        case .ccd:
            if case let SendFundsAmount.ccd(gtu) = amount {
                return account.canTransfer(
                    amount: gtu,
                    withTransferCost: cost,
                    onBalance: balanceType
                )
            }
        case let .cis2(token: token):
            if case let SendFundsAmount.fungibleToken(amountToken) = amount {
                return amountToken.intValue <= token.balance
            }
            if case SendFundsAmount.nonFungibleToken = amount {
                return amount.intValue <= token.balance
            }
        }

        return false
    }

    private func buildTransferCostParameter() -> [TransferCostParameter] {
        var costParameters: [TransferCostParameter] = []
        if transferType == .contractUpdate, case let SendFundsTokenType.cis2(token: token) = viewModel.selectedTokenType {
            let parameters = try? dependencyProvider.mobileWallet().serializeTokenTransferParameters(
                input: .init(
                    tokenId: token.tokenId,
                    amount: "\(viewModel.enteredAmount?.intValue ?? 0)",
                    from: account.address,
                    to: selectedRecipient?.address ?? "")
            )
            costParameters = [
                .amount("0"),
                .contractIndex(Int(token.contractIndex) ?? 0),
                .contractSubindex(0),
                .receiveName(token.contractName + ".transfer"),
                .sender(account.address),
                .parameter(parameters?.parameter ?? ""),
            ]
        } else {
            costParameters = TransferCostParameter.parametersForMemoSize(addedMemo?.size)
        }
        return costParameters
    }

    private func updateTransferCostEstimate() {
        dependencyProvider
            .transactionsService()
            .getTransferCost(transferType: transferType.actualType.toWalletProxyTransferType(), costParameters: buildTransferCostParameter())
            .sink(receiveError: { [weak self] error in
                Logger.error(error)
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }, receiveValue: { [weak self] value in
                let cost = GTU(intValue: Int(value.cost) ?? 0)
                self?.cost = cost
                self?.energy = value.energy
                let feeMessage = "sendFund.feeMessage".localized + cost.displayValue()
                self?.viewModel.feeMessage = feeMessage
                print(value)
            })
            .store(in: &cancellables)
    }

    private func sendAllFundsIfNeeded() {
        guard viewModel.selectedSendAllDisposableAmount else { return }

        guard let disposalAmount = viewModel.disposalAmount?.intValue else { return }

        dependencyProvider
            .transactionsService()
            .getTransferCost(transferType: transferType.actualType.toWalletProxyTransferType(), costParameters: buildTransferCostParameter())
            .sink(receiveError: { [weak self] error in
                Logger.error(error)
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }, receiveValue: { [weak self] value in
                guard let self = self else { return }
                let cost = GTU(intValue: Int(value.cost) ?? 0)
                let totalAmount: String!
                if case let SendFundsTokenType.cis2(token: token) = viewModel.selectedTokenType {
                    totalAmount = token.unique ? "1" : token.balanceDisplayValue
                } else if self.balanceType == .shielded {
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
            })
            .store(in: &cancellables)
    }

    private func clearEstimatedTransferCost() {
        viewModel.feeMessage = nil
        cost = nil
        energy = nil
    }

    private func showShieldAmountWarningIfNeeded(completion: @escaping () -> Void) {
        guard let disposableAmount = viewModel.disposalAmount?.intValue else {
            completion()
            return
        }

        let gtuAmount = viewModel.enteredAmount!

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

            view?.showAlert(with: alertOptions)
        } else {
            completion()
        }
    }
}
