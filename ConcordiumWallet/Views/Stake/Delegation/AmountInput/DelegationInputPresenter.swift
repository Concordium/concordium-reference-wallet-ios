//
//  DelegationInputPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 03/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: -
// MARK: Delegate
protocol DelegationAmountInputPresenterDelegate: AnyObject {
    func finishedAmountInput(dataHandler: StakeDataHandler, cost: GTU, energy: Int)
    func switchToRemoveDelegator(cost: GTU, energy: Int)
    func pressedClose()
}

class DelegationAmountInputPresenter: StakeAmountInputPresenterProtocol {

    weak var view: StakeAmountInputViewProtocol?
    weak var delegate: DelegationAmountInputPresenterDelegate?
    
    var account: AccountDataType
    var viewModel = StakeAmountInputViewModel()
    
    @Published private var bakerPoolResponse: BakerPoolResponse?
    @Published private var cost: GTU?
    @Published private var energy: Int?
    
    private var isInCooldown: Bool = false
    var restake: Bool = true
    
    private var dataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    private var stakeService: StakeServiceProtocol
    private var transactionService: TransactionsServiceProtocol
    private var storageManager: StorageManagerProtocol
    let validator: StakeAmountInputValidator
    
    // swiftlint:disable function_body_length
    init(account: AccountDataType,
         delegate: DelegationAmountInputPresenterDelegate? = nil,
         dependencyProvider: StakeCoordinatorDependencyProvider,
         dataHandler: StakeDataHandler,
         bakerPoolResponse: BakerPoolResponse?) {
        self.account = account
        self.delegate = delegate
        self.dataHandler = dataHandler
        self.bakerPoolResponse = bakerPoolResponse
        self.stakeService = dependencyProvider.stakeService()
        self.transactionService = dependencyProvider.transactionsService()
        self.storageManager = dependencyProvider.storageManager()
    
        isInCooldown = self.account.delegation?.isInCooldown ?? false
        let newPool: PoolDelegationData? = dataHandler.getNewEntry()
        let existingPool: PoolDelegationData? = dataHandler.getCurrentEntry()
        let previouslyStakedInPool = GTU(intValue: self.account.delegation?.stakedAmount ?? 0)
        let showsPoolLimits: Bool
        // If we are updating delegation and we dont't change the pool,
        // we need to check the existing value of the pool
        let pool: BakerTarget
        if let newPool = newPool?.pool {
            pool = newPool
        } else if let existingPool = existingPool?.pool {
            pool = existingPool
        } else {
            pool = .passive
        }
        
        if case .passive = pool {
            showsPoolLimits = false
        } else {
            showsPoolLimits = true
        }
        
        let currentPool: GTU?
        let poolLimit: GTU?
        if let poolResponse = bakerPoolResponse {
            currentPool = GTU(intValue: Int(poolResponse.delegatedCapital))
            poolLimit = GTU(intValue: Int(poolResponse.delegatedCapitalCap))
        } else {
            currentPool = nil
            poolLimit = nil
        }
        
        let minValue: GTU
        if dataHandler.hasCurrentData() {
            minValue = GTU(intValue: 0)
        } else {
            minValue = GTU(intValue: 1)
        }
        
        validator = StakeAmountInputValidator(
            minimumValue: minValue,
            maximumValue: nil,
            balance: GTU(intValue: account.forecastBalance),
            atDisposal: GTU(intValue: account.forecastAtDisposalBalance),
            releaseSchedule: GTU(intValue: account.releaseSchedule?.total ?? 0),
            currentPool: currentPool,
            poolLimit: poolLimit,
            previouslyStakedInPool: previouslyStakedInPool,
            isInCooldown: isInCooldown,
            oldPool: existingPool?.pool,
            newPool: newPool?.pool ?? existingPool?.pool
        )
        let amountData: DelegationAmountData? = dataHandler.getCurrentEntry()
        let restakeData: RestakeDelegationData? = dataHandler.getCurrentEntry()
        self.restake = restakeData?.restake ?? true
        
        viewModel.setup(account: account,
                        currentAmount: amountData?.amount,
                        currentRestakeValue: self.restake,
                        isInCooldown: isInCooldown,
                        validator: validator,
                        showsPoolLimits: showsPoolLimits)
    }
    
    private lazy var transferCostResult: AnyPublisher<Result<TransferCost, Error>, Never> = {
        let currentAmount = dataHandler.getCurrentEntry(DelegationAmountData.self)?.amount
        let isOnCooldown = account.delegation?.pendingChange?.change != .NoChange
        
        return viewModel.$isRestakeSelected
            .combineLatest(viewModel.gtuAmount(currentAmount: currentAmount, isOnCooldown: isOnCooldown))
            .compactMap { [weak self] (restake, amount) -> [TransferCostParameter]? in
                guard let self = self else {
                    return nil
                }
                
                self.dataHandler.add(entry: DelegationAmountData(amount: amount))
                self.dataHandler.add(entry: RestakeDelegationData(restake: restake))
                
                return self.dataHandler.getCostParameters()
            }
            .removeDuplicates()
            .flatMap { [weak self] costParameters -> AnyPublisher<Result<TransferCost, Error>, Never> in
                guard let self = self else {
                    return .just(.failure(StakeError.internalError))
                }
                
                self.viewModel.isContinueEnabled = false
                
                return self.transactionService
                    .getTransferCost(
                        transferType: self.dataHandler.transferType.toWalletProxyTransferType(),
                        costParameters: costParameters
                    )
                    .showLoadingIndicator(in: self.view)
                    .asResult()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }()
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        
        transferCostResult
            .onlySuccess()
            .sink { [weak self] transferCost in
                guard let self = self else { return }
                
                let cost = transferCost.gtuCost
                self.cost = cost
                self.energy = transferCost.energy
                self.viewModel.transactionFee = String(format: "stake.inputamount.transactionfee".localized, cost.displayValueWithGStroke())
            }
            .store(in: &cancellables)
        
        stakeService.getChainParameters()
            .showLoadingIndicator(in: nil)
            .sink { [weak self] error in
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            } receiveValue: { [weak self] chainParametersResponse in
                let params = ChainParametersEntity(delegatorCooldown: chainParametersResponse.delegatorCooldown,
                                                   poolOwnerCooldown: chainParametersResponse.poolOwnerCooldown)
                do {
                    _ = try self?.storageManager.updateChainParms(params)
                } catch let error {
                    self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                }
            }.store(in: &cancellables)
        
        viewModel.gtuAmount(
            currentAmount: dataHandler.getCurrentEntry(DelegationAmountData.self)?.amount,
            isOnCooldown: isInCooldown
        ).combineLatest(transferCostResult)
            .map { [weak self] (amount, transferCostResult) -> Result<GTU, StakeError> in
                guard let self = self else {
                    return .failure(.internalError)
                }
                
                return transferCostResult
                    .mapError { _ in .internalError }
                    .flatMap { costRange in
                        self.validator.validate(amount: amount, fee: costRange.gtuCost)
                    }
            }
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.viewModel.amountErrorMessage = nil
                    self?.viewModel.poolLimit?.highlighted = false
                    self?.viewModel.isContinueEnabled = true
                case let .failure(error):
                    self?.handleTransferCostError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleTransferCostError(_ error: StakeError) {
        self.viewModel.amountErrorMessage = error.localizedDescription
        if case .poolLimitReached = error {
            self.viewModel.poolLimit?.highlighted = true
        } else {
            self.viewModel.poolLimit?.highlighted = false
        }
        self.viewModel.isContinueEnabled = false
    }
    
    func pressedContinue() {
        checkForWarnings { [weak self] in
            guard let self = self else { return }
            guard let cost = self.cost else {
                return
            }
            guard let energy = self.energy else {
                return
            }
            if self.dataHandler.isNewAmountZero() {
                self.transactionService.getTransferCost(transferType: WalletProxyTransferType.removeDelegation, costParameters: [])
                    .showLoadingIndicator(in: self.view).sink { [weak self] error in
                        self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                    } receiveValue: {[weak self] transferCost in
                        let cost = GTU(intValue: Int(transferCost.cost) ?? 0)
                        self?.delegate?.switchToRemoveDelegator(cost: cost, energy: energy)
                    }.store(in: &self.cancellables)
            } else {
                self.delegate?.finishedAmountInput(dataHandler: self.dataHandler, cost: cost, energy: energy)
            }
            
        }
    }
    
    func checkForWarnings(completion: (() -> Void)?) {
        switch self.dataHandler.getCurrentWarning(atDisposal: account.forecastAtDisposalBalance + (account.releaseSchedule?.total ?? 0)) {
        case .noChanges:
            let okAction = AlertAction(name: "delegation.nochanges.ok".localized, completion: nil, style: .default)
            
            let alertOptions = AlertOptions(title: "delegation.nochanges.title".localized,
                                            message: "delegation.nochanges.message".localized,
                                            actions: [okAction])
            self.view?.showAlert(with: alertOptions)
        case .amountZero:
            let continueAction = AlertAction(name: "delegation.amountzero.continue".localized, completion: completion, style: .default)
            let cancelAction = AlertAction(name: "delegation.amountzero.newstake".localized,
                                           completion: nil,
                                           style: .default)
            let alertOptions = AlertOptions(title: "delegation.amountzero.title".localized,
                                            message: "delegation.amountzero.message".localized,
                                            actions: [cancelAction, continueAction])
            self.view?.showAlert(with: alertOptions)
        case .loweringStake:
            let changeAction = AlertAction(name: "delegation.loweringamountwarning.change".localized, completion: nil, style: .default)
            let fineAction = AlertAction(name: "delegation.loweringamountwarning.fine".localized,
                                         completion: completion, style: .default)
            let alertOptions = AlertOptions(title: "delegation.loweringamountwarning.title".localized,
                                            message: "delegation.loweringamountwarning.message".localized,
                                            actions: [changeAction, fineAction])
            self.view?.showAlert(with: alertOptions)
        case .moreThan95:
            let continueAction = AlertAction(name: "delegation.morethan95.continue".localized, completion: completion, style: .default)
            let newStakeAction = AlertAction(name: "delegation.morethan95.newstake".localized,
                                             completion: nil,
                                             style: .default)
            let alertOptions = AlertOptions(title: "delegation.morethan95.title".localized,
                                            message: "delegation.morethan95.message".localized,
                                            actions: [continueAction, newStakeAction])
            self.view?.showAlert(with: alertOptions)
        case nil:
            completion?()
        }
    }
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
}

private extension TransferCost {
    var gtuCost: GTU {
        GTU(intValue: Int(cost) ?? 0)
    }
}

private extension DelegationDataType {
    var isInCooldown: Bool {
        if let pendingChange = pendingChange, pendingChange.change != .NoChange {
            return true
        } else {
            return false
        }
    }
}

fileprivate extension StakeAmountInputViewModel {
    func setup (
        account: AccountDataType,
        currentAmount: GTU?,
        currentRestakeValue: Bool?,
        isInCooldown: Bool,
        validator: StakeAmountInputValidator,
        showsPoolLimits: Bool
    ) {
        let balance = GTU(intValue: account.forecastBalance)
        let staked = GTU(intValue: account.delegation?.stakedAmount ?? 0)
        self.firstBalance = BalanceViewModel(label: "delegation.inputamount.balance" .localized,
                                             value: balance.displayValueWithGStroke(), highlighted: false)
        self.secondBalance = BalanceViewModel(label: "delegation.inputamount.delegationstake".localized,
                                              value: staked.displayValueWithGStroke(), highlighted: false)
        self.currentPoolLimit = BalanceViewModel(
            label: "delegation.inputamount.currentpool".localized,
            value: validator.currentPool?.displayValueWithGStroke() ?? GTU(intValue: 0).displayValueWithGStroke(),
            highlighted: false
        )
        self.poolLimit = BalanceViewModel(
            label: "delegation.inputamount.poollimit".localized,
            value: validator.poolLimit?.displayValueWithGStroke() ?? GTU(intValue: 0).displayValueWithGStroke(),
            highlighted: false
        )
        
        self.bottomMessage = "delegation.inputamount.bottommessage".localized
        
        self.isAmountLocked = isInCooldown
        
        self.isRestakeSelected = currentRestakeValue ?? true
        self.showsPoolLimits = showsPoolLimits
        // having a current amount means we are editing
        if let currentAmount = currentAmount {
            if !isInCooldown {
                // we don't set the value if it is in cooldown
                self.amount = currentAmount.displayValue()
                self.amountMessage = "delegation.inputamount.optionalamount".localized
                self.isContinueEnabled = true
            } else {
                self.amountMessage = "delegation.inputamount.lockedamountmessage".localized
                
                if let poolLimit = validator.poolLimit, let currentPool = validator.currentPool,
                   currentAmount.intValue + currentPool.intValue > poolLimit.intValue {
                    self.secondBalance.highlighted = true
                    self.poolLimit?.highlighted = true
                    self.amountErrorMessage = "stake.inputAmount.error.amountTooLarge".localized
                    self.isContinueEnabled = false
                } else {
                    self.isContinueEnabled = true
                }
            }
            self.title = "delegation.inputamount.title.update".localized
            
        } else {
            self.title = "delegation.inputamount.title.create".localized
            self.amountMessage = "delegation.inputamount.createamount".localized
        }
    }
}
