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
}

struct StakeAmountInputValidator {
    var minimumValue: GTU
    var maximumValue: GTU?
    var atDisposal: GTU
    var currentPool: GTU?
    var poolLimit: GTU?
    var previouslyStakedInPool: GTU
    
    func validate(amount: GTU) -> AnyPublisher<GTU, StakeError> {
        .just(amount).flatMap {
            checkMaximum(amount: $0)
        }.flatMap {
            checkMinimum(amount: $0)
        }.flatMap {
            checkAtDisposal(amount: $0)
        }.flatMap {
            checkPoolLimit(amount: $0)
        }.eraseToAnyPublisher()
    }
    
    func checkMaximum(amount: GTU) -> AnyPublisher<GTU, StakeError> {
        if let maximumValue = maximumValue {
            if amount.intValue > maximumValue.intValue {
                return .fail(.maximumAmount(maximumValue))
            }
        }
        return .just(amount)
    }
    func checkMinimum(amount: GTU) -> AnyPublisher<GTU, StakeError> {
        if amount.intValue < minimumValue.intValue {
            return .fail(.minimumAmount(minimumValue))
        }
        return .just(amount)
    }
    func checkAtDisposal(amount:GTU) -> AnyPublisher<GTU, StakeError> {
        if amount.intValue > atDisposal.intValue {
            return .fail(.notEnoughFund(atDisposal))
        }
        return .just(amount)
    }
    func checkPoolLimit(amount: GTU) -> AnyPublisher<GTU, StakeError> {
        guard let currentPool = currentPool, let poolLimit = poolLimit else {
            return .just(amount)
        }
        if amount.intValue + currentPool.intValue - previouslyStakedInPool.intValue > poolLimit.intValue {
            return .fail(.poolLimitReached(currentPool, poolLimit))
        }
        return .just(amount)
    }
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
    
    private var isInCooldown:Bool = false //TODO: calculate this based on the account state
    var restake: Bool = true
    
    private var dataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    private var stakeService: StakeServiceProtocol
    private var transactionService: TransactionsServiceProtocol
    let validator: StakeAmountInputValidator
    
    init(account: AccountDataType, delegate: DelegationAmountInputPresenterDelegate? = nil, dependencyProvider: StakeCoordinatorDependencyProvider, dataHandler: StakeDataHandler, bakerPoolResponse: BakerPoolResponse?) {
        self.account = account
        self.delegate = delegate
        self.dataHandler = dataHandler
        self.bakerPoolResponse = bakerPoolResponse
        self.stakeService = dependencyProvider.stakeService()
        self.transactionService = dependencyProvider.transactionsService()
        
        let previouslyStakedInSelectedPool: Int
        let newPool: PoolDelegationData? = dataHandler.getNewEntry()
        let existingPool: PoolDelegationData? = dataHandler.getCurrentEntry()
        let showsPoolLimits: Bool!
        //If we are updating delegation and we dont't change the pool,
        // we need to check the existing value of the pool
        let pool:BakerPool!
        if let newPool = newPool?.pool {
            pool = newPool
            previouslyStakedInSelectedPool = Int((self.account.delegation?.stakedAmount) ?? "0") ?? 0
        } else if let existingPool = existingPool?.pool {
            pool = existingPool
            previouslyStakedInSelectedPool = 0
        } else {
            pool = .lpool
            previouslyStakedInSelectedPool = 0
        }
        
        if case .lpool = pool {
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
        
        validator = StakeAmountInputValidator(minimumValue: GTU(intValue: 1),
                                              maximumValue: nil,
                                              atDisposal: GTU(intValue: account.forecastAtDisposalBalance),
                                              currentPool:currentPool,
                                              poolLimit: poolLimit,
                                              previouslyStakedInPool: GTU(intValue: previouslyStakedInSelectedPool) )
        let amountData: AmountData? = dataHandler.getCurrentEntry()
        self.validAmount = amountData?.amount
        let restakeData: RestakeDelegationData? = dataHandler.getCurrentEntry()
        self.restake = restakeData?.restake ?? true
        
        viewModel.setup(account: account, currentAmount: amountData?.amount, currentRestakeValue: self.restake, isInCooldown: isInCooldown, validator: validator, showsPoolLimits: showsPoolLimits)
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
       
        self.view?.restakeOptionPublisher.sink(receiveCompletion: { _ in
        }, receiveValue: { [weak self] isRestaking in
            self?.restake = isRestaking
            self?.dataHandler.add(entry: RestakeDelegationData(restake: isRestaking))
        }).store(in: &cancellables)
        
        self.view?.amountPublisher.map { amount -> GTU in
            GTU(displayValue: amount)
        }
        .flatMap { [weak self] amount -> AnyPublisher<Result<GTU, StakeError>, Never> in
            guard let self = self else { return .just(Result.failure(StakeError.internalError))}
            var stakeError: StakeError? = nil
            return self.validator.validate(amount: amount)
                .mapError { [weak self] error -> StakeError in
                    self?.viewModel.amountErrorMessage = error.localizedDescription
                    stakeError = error
                    return error
                }.map { amount in
                    return Result<GTU, StakeError>.success(amount)
                }.replaceError(with: {
                    if let error = stakeError {
                        return Result<GTU, StakeError>.failure(error)
                    }
                    return Result<GTU, StakeError>.failure(StakeError.internalError)
                }())
                .eraseToAnyPublisher()
        }
        .sink(receiveCompletion: { completion in
        }, receiveValue: { [weak self]  result in
            if case Result.success(let amount) = result {
                self?.validAmount = amount
                self?.viewModel.amountErrorMessage = nil
            } else {
                self?.validAmount = nil
                self?.viewModel.isContinueEnabled = false
            }
        })
        .store(in: &cancellables)
        
       
        let validAmountPublisher = self.$validAmount
            .compactMap { $0 }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        //calculate transaction fee
        self.view?.restakeOptionPublisher
            .combineLatest(validAmountPublisher)
            .flatMap({ [weak self] (restake, amount) -> AnyPublisher<TransferCost, Error> in
                guard let self = self else {
                    return .fail(StakeError.internalError)
                }
                self.viewModel.isContinueEnabled = false//we wait until we get the updated cost
                let costParams = self.dataHandler.getCostParameters()
                return self.transactionService.getTransferCost(transferType: self.dataHandler.transferType,
                                                               costParameters: costParams)
                    .showLoadingIndicator(in: self.view)
                    .eraseToAnyPublisher()
            })
            .sink(receiveError: {[weak self] error in
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }, receiveValue: { [weak self] fee in
                self?.cost =  GTU(intValue: Int(fee.cost) ?? 0)
                self?.energy = fee.energy
                self?.viewModel.isContinueEnabled = true
                self?.viewModel.transactionFee = String(format: "stake.inputamount.transactionfee".localized, fee.cost)
            }).store(in: &cancellables)
        

        self.view?.restakeOptionPublisher.send(viewModel.isRestakeSelected)
    }
    
    func pressedContinue() {
        if let validAmount = self.validAmount {
            self.dataHandler.add(entry: AmountData(amount: validAmount))
        }
        checkForWarnings { [weak self] in
            guard let self = self else { return }
            guard let cost = self.cost else {
                return
            }
            guard let energy = self.energy else {
                return
            }
            self.delegate?.finishedAmountInput(cost: cost, energy: energy)
        }
    }
    
    func checkForWarnings(completion: (() -> Void)?) {
        //blocking warning if there are no changes
        if !dataHandler.containsChanges() {
            let okAction = AlertAction(name: "delegation.nochanges.ok".localized, completion: nil, style: .default)
            
            let alertOptions = AlertOptions(title: "delegation.nochanges.title".localized, message: "delegation.nochanges.message".localized, actions: [okAction])
            self.view?.showAlert(with: alertOptions)
    } else if self.dataHandler.isLoweringStake() {
        //warning for lowering stake
            let changeAction = AlertAction(name: "delegation.loweringamountwarning.change".localized, completion: nil, style: .default)
            let fineAction = AlertAction(name: "delegation.loweringamountwarning.fine".localized, completion:completion, style: .default)
            let alertOptions = AlertOptions(title: "delegation.loweringamountwarning.title".localized, message: "delegation.loweringamountwarning.message".localized, actions: [changeAction, fineAction])
            self.view?.showAlert(with: alertOptions)
        } else {
            //warning for more than 95% of funds used
            if dataHandler.moreThan95(atDisposal: account.forecastAtDisposalBalance) {
                let continueAction = AlertAction(name: "delegation.morethan95.continue".localized, completion: completion, style: .default)
                let newStakeAction = AlertAction(name: "delegation.morethan95.newstake".localized, completion:nil, style: .default)
                let alertOptions = AlertOptions(title: "delegation.morethan95.title".localized, message: "delegation.morethan95.message".localized, actions: [continueAction, newStakeAction])
                self.view?.showAlert(with: alertOptions)
            } else {
                completion?()
            }
        }
    }
    
}

fileprivate extension StakeAmountInputViewModel {
    func setup (account: AccountDataType, currentAmount: GTU?, currentRestakeValue: Bool?, isInCooldown: Bool, validator: StakeAmountInputValidator, showsPoolLimits: Bool) {
        let atDisposal = GTU(intValue: account.forecastAtDisposalBalance)
        let staked = GTU(intValue: Int(account.delegation?.stakedAmount ?? "0") ?? 0)
        self.firstBalance = BalanceViewModel(label: "delegation.inputamount.balance" .localized,
                                             value: atDisposal.displayValueWithGStroke())
        self.secondBalance = BalanceViewModel(label: "delegation.inputamount.delegationstake".localized,
                                              value: staked.displayValueWithGStroke())
        self.currentPoolLimit = BalanceViewModel(label: "delegation.inputamount.currentpool".localized,
                                                 value: validator.currentPool?.displayValueWithGStroke() ?? GTU(intValue: 0).displayValueWithGStroke())
        self.poolLimit = BalanceViewModel(label: "delegation.inputamount.poollimit".localized,
                                          value: validator.poolLimit?.displayValueWithGStroke() ?? GTU(intValue: 0).displayValueWithGStroke())
        
        self.bottomMessage = "delegation.inputamount.bottommessage".localized
        
        self.isAmountLocked = isInCooldown
        
        self.isRestakeSelected = currentRestakeValue ?? true
        self.showsPoolLimits = showsPoolLimits
        //having a current amount means we are editing
        if let currentAmount = currentAmount {
            if !isInCooldown {
                //we don't set the value if it is in cooldown
                self.amount = currentAmount.displayValue()
                self.amountMessage = "delegation.inputamount.optionalamount".localized
            } else {
                self.amountMessage = "delegation.inputamount.lockedamountmessage".localized
            }
            self.title = "delegation.inputamount.title.update".localized
            
        } else {
            self.title = "delegation.inputamount.title.create".localized
        }
    }
}
