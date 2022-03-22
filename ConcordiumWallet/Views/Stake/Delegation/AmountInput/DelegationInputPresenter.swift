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
    func finishedAmountInput()
}

struct StakeAmountInputValidator {
    var minimumValue: GTU
    var maximumValue: GTU
    var atDisposal: GTU
    var currentPool: GTU?
    var poolLimit: GTU?
    
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
        if amount.intValue > maximumValue.intValue {
            return .fail(.maximumAmount(maximumValue))
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
        if amount.intValue + currentPool.intValue > poolLimit.intValue {
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
    
    
    @Published private var validAmount: GTU?
    private var isInCooldown:Bool = false //TODO: calculate this based on the account state
    var restake: Bool = true
    
    private var dataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    private var stakeService: StakeServiceProtocol
    private var transactionService: TransactionsServiceProtocol
    let validator: StakeAmountInputValidator
    
    init(account: AccountDataType, delegate: DelegationAmountInputPresenterDelegate? = nil, dependencyProvider: StakeCoordinatorDependencyProvider, dataHandler: StakeDataHandler) {
        self.account = account
        self.delegate = delegate
        self.dataHandler = dataHandler
        self.stakeService = dependencyProvider.stakeService()
        self.transactionService = dependencyProvider.transactionsService()
        //TODO: add limits to the validator
        validator = StakeAmountInputValidator(minimumValue: GTU(intValue: 1),
                                              maximumValue: GTU(intValue: 10000000),
                                              atDisposal: GTU(intValue: 20000000),
                                              currentPool: GTU(intValue: 20000000),
                                              poolLimit: GTU(intValue: 25000000))
        let amountData: AmountData? = dataHandler.getCurrentEntry()
        self.validAmount = amountData?.amount
        let restakeData: RestakeDelegationData? = dataHandler.getCurrentEntry()
        self.restake = restakeData?.restake ?? true
        let newPool: PoolDelegationData? = dataHandler.getNewEntry()
        let existingPool: PoolDelegationData? = dataHandler.getCurrentEntry()
        let showsPoolLimits: Bool!
        
        //If we are updating delegation and we dont't change the pool,
        // we need to check the existing value of the pool
        let pool:BakerPool!
        if let newPool = newPool?.pool {
            pool = newPool
        } else if let existingPool = existingPool?.pool {
            pool = existingPool
        } else {
            pool = .lpool
        }
        
        if case .lpool = pool {
            showsPoolLimits = false
        } else {
            showsPoolLimits = true
        }

        viewModel.setup(account: account, currentAmount: amountData?.amount, currentRestakeValue: self.restake, isInCooldown: isInCooldown, validator: validator, showsPoolLimits: showsPoolLimits)
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)

        self.view?.restakeOptionPublisher.sink(receiveCompletion: { _ in
        }, receiveValue: { [weak self] isRestaking in
            self?.restake = isRestaking
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
            }
        })
        .store(in: &cancellables)
        
        self.$validAmount.sink { [weak self] amount in
            guard let self = self else { return }
            self.viewModel.isAmountValid = (amount != nil) || self.viewModel.isAmountLocked
        }.store(in: &cancellables)
        
        //calculate transaction fee
        if let restakePublisher = self.view?.restakeOptionPublisher.eraseToAnyPublisher() {
            let validAmountPublisher = self.$validAmount.setFailureType(to: Error.self).eraseToAnyPublisher()
            let feePublisher = transactionService.getTransferCost(transferType: dataHandler.transferType, costParameters: dataHandler.getCostParameters())
            Publishers.CombineLatest3(validAmountPublisher, restakePublisher, feePublisher)
                .sink(receiveError: { error in
                    self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                    self.viewModel.transactionFee = nil
                }, receiveValue: { (_, _, fee) in
                    self.viewModel.transactionFee = String(format: "stake.inputamount.transactionfee".localized, fee.cost)
                    
                }).store(in: &cancellables)
            }
    }
    
    func pressedContinue() {
        self.dataHandler.add(entry: RestakeDelegationData(restake: self.restake))
        self.dataHandler.add(entry: DelegatioonAccountData(accountAddress: self.account.address))
        if let validAmount = self.validAmount {
            self.dataHandler.add(entry: AmountData(amount: validAmount))
        }
        checkForWarnings { [weak self] in
            guard let self = self else { return }
            self.delegate?.finishedAmountInput()
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
        self.firstBalance = BalanceViewModel(label: "delegation.inputamount.balance" .localized,
                                             value: atDisposal.displayValueWithGStroke())
        // TODO: update values
        self.secondBalance = BalanceViewModel(label: "delegation.inputamount.delegationstake".localized,
                                              value: "TBD DELEGATION STAKE")
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
