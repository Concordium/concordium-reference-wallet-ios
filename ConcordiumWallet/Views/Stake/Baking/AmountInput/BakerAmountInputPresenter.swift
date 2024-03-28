//
//  BakerAmountInputPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 19/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

protocol BakerAmountInputPresenterDelegate: AnyObject {
    func finishedAmountInput(dataHandler: StakeDataHandler)
    func switchToRemoveBaker()
    func pressedClose()
}

private enum TransferCostOption {
    case cost(TransferCost)
    case range(TransferCostRange)
    
    var formattedTransactionFee: String {
        switch self {
            case .cost(let transferCost):
                let gtuCost = GTU(intValue: Int(transferCost.cost) ?? 0)
                return String(format: "stake.inputamount.transactionfee".localized, gtuCost.displayValueWithGStroke())
            case .range(let transferCostRange):
                return transferCostRange.formattedTransactionFee
        }
    }
    
    var maxCost: GTU {
        switch self {
            case .cost(let transferCost):
                return GTU(intValue: Int(transferCost.cost) ?? 0)
            case .range(let transferCostRange):
                return transferCostRange.maxCost
        }
    }
}

class BakerAmountInputPresenter: StakeAmountInputPresenterProtocol {
    weak var view: StakeAmountInputViewProtocol?
    weak var delegate: BakerAmountInputPresenterDelegate?
    
    private let account: AccountDataType
    private let viewModel = StakeAmountInputViewModel()
    
    private let dataHandler: StakeDataHandler
    private var validator: StakeAmountInputValidator
    
    private let transactionService: TransactionsServiceProtocol
    private let stakeService: StakeServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        account: AccountDataType,
        delegate: BakerAmountInputPresenterDelegate? = nil,
        dependencyProvider: StakeCoordinatorDependencyProvider,
        dataHandler: StakeDataHandler
    ) {
        self.account = account
        self.delegate = delegate
        self.dataHandler = dataHandler
        self.transactionService = dependencyProvider.transactionsService()
        self.stakeService = dependencyProvider.stakeService()
        
        let previouslyStakedInPool = GTU(intValue: self.account.baker?.stakedAmount ?? 0)
        
        validator = StakeAmountInputValidator(
            minimumValue: GTU(intValue: 0),
            balance: GTU(intValue: account.forecastBalance),
            atDisposal: GTU(intValue: account.forecastAtDisposalBalance),
            releaseSchedule: GTU(intValue: account.releaseSchedule?.total ?? 0),
            previouslyStakedInPool: previouslyStakedInPool,
            isInCooldown: account.baker?.isInCooldown ?? false
        )
        
        viewModel.setup(
            account: account,
            currentAmount: dataHandler.getCurrentEntry(BakerAmountData.self)?.amount,
            currentRestakeValue: dataHandler.getCurrentEntry(RestakeBakerData.self)?.restake,
            isInCooldown: account.baker?.isInCooldown ?? false
        )
    }
    
    private lazy var costRangeResult: AnyPublisher<Result<TransferCostOption, Error>, Never> = {
        let currentAmount = dataHandler.getCurrentEntry(BakerAmountData.self)?.amount
        let isOnCooldown = account.baker?.isInCooldown ?? false
        let fetchRange = dataHandler.transferType == .registerBaker
        
        return viewModel.$isRestakeSelected
            .combineLatest(viewModel.gtuAmount(currentAmount: currentAmount, isOnCooldown: isOnCooldown))
            .compactMap { [weak self] (restake, amount) -> [TransferCostParameter]? in
                guard let self = self else {
                    return nil
                }
                
                self.dataHandler.add(entry: BakerAmountData(amount: amount))
                self.dataHandler.add(entry: RestakeBakerData(restake: restake))
                
                return self.dataHandler.getCostParameters()
            }
            .removeDuplicates()
            .flatMap { [weak self] (costParameters) -> AnyPublisher<Result<TransferCostOption, Error>, Never> in
                guard let self = self else {
                    return .just(.failure(StakeError.internalError))
                }
                
                self.viewModel.isContinueEnabled = false
                
                if fetchRange {
                    return self.transactionService
                        .getBakingTransferCostRange(parameters: costParameters)
                        .map { TransferCostOption.range($0) }
                        .showLoadingIndicator(in: self.view)
                        .asResult()
                        .eraseToAnyPublisher()
                } else {
                    return self.transactionService
                        .getTransferCost(transferType: self.dataHandler.transferType.toWalletProxyTransferType(), costParameters: costParameters)
                        .map { TransferCostOption.cost($0) }
                        .showLoadingIndicator(in: self.view)
                        .asResult()
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }()
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        
        loadPoolParameters()
        
        costRangeResult
            .onlySuccess()
            .map { $0.formattedTransactionFee }
            .assignNoRetain(to: \.transactionFee, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.gtuAmount(
            currentAmount: dataHandler.getCurrentEntry(BakerAmountData.self)?.amount,
            isOnCooldown: account.baker?.isInCooldown ?? false
        )
        .combineLatest(costRangeResult)
        .map { [weak self] (amount, rangeResult) -> Result<GTU, StakeError> in
            guard let self = self else {
                return .failure(StakeError.internalError)
            }
            
            // in case when validators want to change their restaking preference
            // we allow to modify validator options in case when amount not changed
            if let baker = account.baker, baker.stakedAmount == amount.intValue {
                return .success(amount)
            }
            
            return rangeResult
                .mapError { _ in StakeError.internalError }
                .flatMap { costRange in
                    self.validator.validate(amount: amount, fee: costRange.maxCost)
                }
        }
        .sink { [weak self] result in
            switch result {
                case let .failure(error):
                    self?.viewModel.isContinueEnabled = false
                    self?.viewModel.amountErrorMessage = error.localizedDescription
                case .success:
                    self?.viewModel.isContinueEnabled = true
                    self?.viewModel.amountErrorMessage = nil
            }
        }
        .store(in: &cancellables)
    }
    
    private struct RemoteParameters {
        let minimumValue: GTU
        let maximumValue: GTU
        let comissionData: BakerCommissionData
    }
    
    ///
    /// `ValidatorPoolData` contained needed data to show on tx approve UI current  pool commisions state
    /// - `rates`commisiotn rate for validator pool, to update commision data
    /// - `delegatedCapital` - is for baker pool delegated capital
    ///
    typealias ValidatorPoolData = (rates: CommissionRates?, delegatedCapital: Int)
    
    private func loadPoolParameters() {
        let passiveDelegationRequest = stakeService.getPassiveDelegation()
        let chainParametersRequest = stakeService.getChainParameters()
        let validatorData = Just(account.baker?.bakerID)
            .setFailureType(to: Error.self)
            .flatMap { [weak self] bakerId -> AnyPublisher<ValidatorPoolData, Error> in
                guard let self = self, let bakerId = bakerId else {
                    return .just((nil, 0))
                }
                
                return self.stakeService.getBakerPool(bakerId: bakerId)
                    .map { bakerPool in
                        (bakerPool.poolInfo.commissionRates,  Int(bakerPool.delegatedCapital) ?? 0)
                    }
                    .eraseToAnyPublisher()
            }
        
        passiveDelegationRequest
            .zip(chainParametersRequest, validatorData)
            .asResult()
            .showLoadingIndicator(in: self.view)
            .sink { [weak self] (result) in
                self?.handleParametersResult(result.map { (passiveDelegation, chainParameters, validatorData) in
                    let (commissionRates, delegatedCapital) = validatorData
                    let totalCapital = Int(passiveDelegation.allPoolTotalCapital) ?? 0
                    // We make sure to first convert capitalBound to an Int so we don't have to do floating point arithmetic
                    let availableCapital = (totalCapital * Int(chainParameters.capitalBound * 100) / 100) - delegatedCapital
                    
                    return RemoteParameters(
                        minimumValue: GTU(intValue: Int(chainParameters.minimumEquityCapital) ?? 0),
                        maximumValue: GTU(intValue: availableCapital),
                        comissionData: BakerCommissionData(
                            // In case when account is a `baker/validator`, we use baker commission data for this pool.
                            // Else, we take chain parameters as `commissionData`.
                            bakingRewardComission: commissionRates?.bakingCommission ?? chainParameters.bakingCommissionRange.max,
                            finalizationRewardComission: commissionRates?.finalizationCommission ?? chainParameters.finalizationCommissionRange.max,
                            transactionComission: commissionRates?.transactionCommission ?? chainParameters.transactionCommissionRange.max
                        )
                    )
                })
            }
            .store(in: &cancellables)
    }
    
    private func handleParametersResult(_ result: Result<RemoteParameters, Error>) {
        switch result {
            case let .failure(error):
                self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            case let .success(parameters):
                self.validator.minimumValue = parameters.minimumValue
                self.validator.maximumValue = parameters.maximumValue
                self.dataHandler.add(entry: parameters.comissionData)
        }
    }
    
    func pressedContinue() {
        checkForWarnings { [weak self] in
            guard let self = self else { return }
            
            if self.dataHandler.isNewAmountZero() {
                self.delegate?.switchToRemoveBaker()
            } else {
                self.delegate?.finishedAmountInput(dataHandler: self.dataHandler)
            }
        }
    }
    
    private func checkForWarnings(completion: @escaping () -> Void) {
        if let alert = dataHandler.getCurrentWarning(
            atDisposal: account.forecastAtDisposalBalance + (account.releaseSchedule?.total ?? 0)
        )?.asAlert(completion: completion) {
            self.view?.showAlert(with: alert)
        } else {
            completion()
        }
    }
    
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
}

private extension BakerDataType {
    var isInCooldown: Bool {
        if let pendingChange = pendingChange, pendingChange.change != .NoChange {
            return true
        } else {
            return false
        }
    }
}

private extension StakeWarning {
    func asAlert(completion: @escaping () -> Void) -> AlertOptions? {
        switch self {
            case .noChanges:
                return BakingAlerts.noChanges
            case .loweringStake:
                return nil
            case .moreThan95:
                let continueAction = AlertAction(name: "baking.morethan95.continue".localized, completion: completion, style: .default)
                let newStakeAction = AlertAction(name: "baking.morethan95.newstake".localized,
                                                 completion: nil,
                                                 style: .default)
                return AlertOptions(title: "baking.morethan95.title".localized,
                                    message: "baking.morethan95.message".localized,
                                    actions: [continueAction, newStakeAction])
            case .amountZero:
                return nil
        }
    }
}

private extension TransferCostRange {
    var formattedTransactionFee: String {
        String(
            format: "baking.inputamount.transactionfee".localized,
            minCost.displayValueWithGStroke(),
            maxCost.displayValueWithGStroke()
        )
    }
}

private extension StakeAmountInputViewModel {
    func setup(
        account: AccountDataType,
        currentAmount: GTU?,
        currentRestakeValue: Bool?,
        isInCooldown: Bool
    ) {
        let balance = GTU(intValue: account.forecastBalance)
        let staked = GTU(intValue: account.baker?.stakedAmount ?? 0)
        self.firstBalance = BalanceViewModel(
            label: "baking.inputamount.balance".localized,
            value: balance.displayValueWithGStroke(),
            highlighted: false
        )
        self.secondBalance = BalanceViewModel(
            label: "baking.inputamount.bakerstake".localized,
            value: staked.displayValueWithGStroke(),
            highlighted: false
        )
        self.showsPoolLimits = false
        self.isAmountLocked = isInCooldown
        self.bottomMessage = "baking.inputamount.bottommessage".localized
        self.isRestakeSelected = currentRestakeValue ?? true
        
        if let currentAmount = currentAmount {
            if !isInCooldown {
                self.amount = currentAmount.displayValue()
                self.amountMessage = "baking.inputamount.newamount".localized
            } else {
                self.amountMessage = "baking.inputamount.lockedamountmessage".localized
            }
            
            self.title = "baking.inputamount.title.update".localized
        } else {
            self.title = "baking.inputamount.title.create".localized
            self.amountMessage = "baking.inputamount.createamount".localized
        }
    }
}
