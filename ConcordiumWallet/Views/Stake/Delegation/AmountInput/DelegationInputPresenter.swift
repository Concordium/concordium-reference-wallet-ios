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
    func finishedAmountInput(cost: GTU, energy: Int)
    func switchToRemoveDelegator(cost: GTU, energy: Int)
    func pressedClose()
}

class DelegationAmountInputPresenter: StakeAmountInputPresenterProtocol {

    weak var view: StakeAmountInputViewProtocol?
    weak var delegate: DelegationAmountInputPresenterDelegate?
    
    var account: AccountDataType
    var viewModel = StakeAmountInputViewModel()
    
    @Published private var bakerPoolResponse: BakerPoolResponse?
    @Published private var validAmount: GTU?
    @Published private var cost: GTU?
    @Published private var energy: Int?
    
    private var isInCooldown: Bool = false
    var restake: Bool = true
    
    private var dataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    private var stakeService: StakeServiceProtocol
    private var transactionService: TransactionsServiceProtocol
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
    
        if let delegation = self.account.delegation, delegation.pendingChange?.change != .NoChange {
            isInCooldown = true
        } else {
            isInCooldown = false
        }
        let previouslyStakedInSelectedPool: Int
        let newPool: PoolDelegationData? = dataHandler.getNewEntry()
        let existingPool: PoolDelegationData? = dataHandler.getCurrentEntry()
        let showsPoolLimits: Bool!
        // If we are updating delegation and we dont't change the pool,
        // we need to check the existing value of the pool
        let pool: BakerTarget
        if let newPool = newPool?.pool {
            pool = newPool
            // if pool is changed, then the previously staked is incorrect
            previouslyStakedInSelectedPool = 0
        } else if let existingPool = existingPool?.pool {
            pool = existingPool
            previouslyStakedInSelectedPool = self.account.delegation?.stakedAmount ?? 0
        } else {
            pool = .passive
            previouslyStakedInSelectedPool = self.account.delegation?.stakedAmount ?? 0
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
        
        validator = StakeAmountInputValidator(minimumValue: minValue,
                                              maximumValue: nil,
                                              balance: GTU(intValue: account.forecastBalance),
                                              atDisposal: GTU(intValue: account.forecastAtDisposalBalance + (account.releaseSchedule?.total ?? 0)),
                                              currentPool: currentPool,
                                              poolLimit: poolLimit,
                                              previouslyStakedInPool: GTU(intValue: previouslyStakedInSelectedPool))
        let amountData: DelegationAmountData? = dataHandler.getCurrentEntry()
        self.validAmount = amountData?.amount
        let restakeData: RestakeDelegationData? = dataHandler.getCurrentEntry()
        self.restake = restakeData?.restake ?? true
        
        viewModel.setup(account: account,
                        currentAmount: amountData?.amount,
                        currentRestakeValue: self.restake,
                        isInCooldown: isInCooldown,
                        validator: validator,
                        showsPoolLimits: showsPoolLimits)
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
       
        self.view?.restakeOptionPublisher.sink(receiveCompletion: { _ in
        }, receiveValue: { [weak self] isRestaking in
            self?.restake = isRestaking
            
        }).store(in: &cancellables)
        
        guard let view = self.view else { return }
        
        view.amountPublisher.map { [weak self] amount -> GTU in
            self?.viewModel.isContinueEnabled = false
            return GTU(displayValue: amount)
        }
        .combineLatest(view.restakeOptionPublisher)
        .flatMap { [weak self] (amount, restake) -> AnyPublisher<Result<GTU, StakeError>, Never> in
            guard let self = self else { return .just(Result.failure(StakeError.internalError))}
            
            self.dataHandler.add(entry: DelegationAmountData(amount: amount))
            self.dataHandler.add(entry: RestakeDelegationData(restake: restake))
            
            self.viewModel.isContinueEnabled = false// we wait until we get the updated cost
            let costParams = self.dataHandler.getCostParameters()
            return self.transactionService
                .getTransferCost(
                    transferType: self.dataHandler.transferType,
                    costParameters: costParams
                )
                .showLoadingIndicator(in: self.view)
                .mapError { _ in StakeError.internalError }
                .asResult()
                .map { [weak self] feeResult -> Result<GTU, StakeError> in
                    guard let self = self else { return .failure(.internalError) }
                    return feeResult.flatMap { fee in
                        let cost = GTU(intValue: Int(fee.cost) ?? 0)
                        self.cost = cost
                        self.energy = fee.energy
                        self.viewModel.transactionFee = String(format: "stake.inputamount.transactionfee".localized, cost.displayValueWithGStroke())
                        return self.validator.validate(amount: amount, fee: cost)
                    }
                }
                .eraseToAnyPublisher()
        }
        .sink(receiveCompletion: { _ in
        }, receiveValue: { [weak self]  result in
            switch result {
            case let .success(amount):
                self?.validAmount = amount
                self?.viewModel.amountErrorMessage = nil
                self?.viewModel.poolLimit?.hightlighted = false
                self?.viewModel.isContinueEnabled = true
            case let .failure(error):
                self?.validAmount = nil
                self?.viewModel.amountErrorMessage = error.localizedDescription
                if case .poolLimitReached = error {
                    self?.viewModel.poolLimit?.hightlighted = true
                } else {
                    self?.viewModel.poolLimit?.hightlighted = false
                }
                self?.viewModel.isContinueEnabled = false
            }
        }).store(in: &cancellables)
        
        view.restakeOptionPublisher.send(viewModel.isRestakeSelected)
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
                self.transactionService.getTransferCost(transferType: .removeDelegation, costParameters: [])
                    .showLoadingIndicator(in: self.view).sink { [weak self] error in
                        self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                    } receiveValue: {[weak self] transferCost in
                        let cost = GTU(intValue: Int(transferCost.cost) ?? 0)
                        self?.delegate?.switchToRemoveDelegator(cost: cost, energy: energy)
                    }.store(in: &self.cancellables)
            } else {
                self.delegate?.finishedAmountInput(cost: cost, energy: energy)
            }
            
        }
    }
    
    func checkForWarnings(completion: (() -> Void)?) {
        // blocking warning if there are no changes
        if !dataHandler.containsChanges() {
            let okAction = AlertAction(name: "delegation.nochanges.ok".localized, completion: nil, style: .default)
            
            let alertOptions = AlertOptions(title: "delegation.nochanges.title".localized,
                                            message: "delegation.nochanges.message".localized,
                                            actions: [okAction])
            self.view?.showAlert(with: alertOptions)
        } else if dataHandler.isNewAmountZero() {
            // warning for more zero amount = removeDelegation
            let continueAction = AlertAction(name: "delegation.amountzero.continue".localized, completion: completion, style: .default)
            let cancelAction = AlertAction(name: "delegation.amountzero.newstake".localized,
                                           completion: nil,
                                           style: .default)
            let alertOptions = AlertOptions(title: "delegation.amountzero.title".localized,
                                            message: "delegation.amountzero.message".localized,
                                            actions: [cancelAction, continueAction])
            self.view?.showAlert(with: alertOptions)
        } else if self.dataHandler.isLoweringStake() {
            // warning for lowering stake
            let changeAction = AlertAction(name: "delegation.loweringamountwarning.change".localized, completion: nil, style: .default)
            let fineAction = AlertAction(name: "delegation.loweringamountwarning.fine".localized,
                                         completion: completion, style: .default)
            let alertOptions = AlertOptions(title: "delegation.loweringamountwarning.title".localized,
                                            message: "delegation.loweringamountwarning.message".localized,
                                            actions: [changeAction, fineAction])
            self.view?.showAlert(with: alertOptions)
        } else if dataHandler.moreThan95(atDisposal: account.forecastAtDisposalBalance) {
            // warning for more than 95% of funds used
            let continueAction = AlertAction(name: "delegation.morethan95.continue".localized, completion: completion, style: .default)
            let newStakeAction = AlertAction(name: "delegation.morethan95.newstake".localized,
                                             completion: nil,
                                             style: .default)
            let alertOptions = AlertOptions(title: "delegation.morethan95.title".localized,
                                            message: "delegation.morethan95.message".localized,
                                            actions: [continueAction, newStakeAction])
            self.view?.showAlert(with: alertOptions)
        } else {
            completion?()
        }
    }
    func closeButtonTapped() {
        self.delegate?.pressedClose()
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
                                             value: balance.displayValueWithGStroke(), hightlighted: false)
        self.secondBalance = BalanceViewModel(label: "delegation.inputamount.delegationstake".localized,
                                              value: staked.displayValueWithGStroke(), hightlighted: false)
        self.currentPoolLimit = BalanceViewModel(
            label: "delegation.inputamount.currentpool".localized,
            value: validator.currentPool?.displayValueWithGStroke() ?? GTU(intValue: 0).displayValueWithGStroke(),
            hightlighted: false
        )
        self.poolLimit = BalanceViewModel(
            label: "delegation.inputamount.poollimit".localized,
            value: validator.poolLimit?.displayValueWithGStroke() ?? GTU(intValue: 0).displayValueWithGStroke(),
            hightlighted: false
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
            } else {
                self.amountMessage = "delegation.inputamount.lockedamountmessage".localized
                
                if let poolLimit = validator.poolLimit, let currentPool = validator.currentPool,
                   currentAmount.intValue + currentPool.intValue > poolLimit.intValue {
                    self.secondBalance.hightlighted = true
                    self.poolLimit?.hightlighted = true
                    self.amountErrorMessage = "stake.inputAmount.error.amountTooLarge".localized
                    self.isContinueEnabled = false
                }
            }
            self.title = "delegation.inputamount.title.update".localized
            
        } else {
            self.title = "delegation.inputamount.title.create".localized
            self.amountMessage = "delegation.inputamount.createamount".localized
        }
    }
}
