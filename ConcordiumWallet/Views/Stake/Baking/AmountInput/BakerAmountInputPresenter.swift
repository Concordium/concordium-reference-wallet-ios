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
    func finishedAmountInput(range: TransferCostRange)
    func switchToRemoveBaker(cost: GTU, energy: Int)
    func pressedClose()
}

class BakerAmountInputPresenter: StakeAmountInputPresenterProtocol {
    weak var view: StakeAmountInputViewProtocol?
    weak var delegate: BakerAmountInputPresenterDelegate?
    
    private let account: AccountDataType
    private let viewModel = StakeAmountInputViewModel()
    
    private var isInCooldown = false
    
    private let dataHandler: StakeDataHandler
    private let validator: StakeAmountInputValidator
    
    private let transactionService: TransactionsServiceProtocol
    private var transferCostRange: TransferCostRange?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var validatedAmount: AnyPublisher<Result<GTU, StakeError>, Never> {
        view?.amountPublisher
            .map { [weak self] amount in
                self?.validator.validate(amount: GTU(displayValue: amount)) ?? .failure(.internalError)
            }
            .eraseToAnyPublisher() ?? .empty()
    }
    
    init(
        account: AccountDataType,
        delegate: BakerAmountInputPresenterDelegate? = nil,
        dependencyProvider: StakeCoordinatorDependencyProvider,
        dataHandler: StakeDataHandler,
        poolParameters: PoolParametersResponse
    ) {
        self.account = account
        self.delegate = delegate
        self.dataHandler = dataHandler
        self.transactionService = dependencyProvider.transactionsService()
        
        if let baker = self.account.baker, baker.pendingChange?.change != .NoChange {
            isInCooldown = true
        }
        
        let previosulyStakedInPool = GTU(intValue: self.account.baker?.stakedAmount ?? 0)
        
        validator = StakeAmountInputValidator(
            minimumValue: GTU(intValue: Int(poolParameters.bakingCommissionRange.min)),
            maximumValue: GTU(intValue: Int(poolParameters.bakingCommissionRange.max)),
            atDisposal: GTU(intValue: account.forecastAtDisposalBalance),
            previouslyStakedInPool: previosulyStakedInPool
        )
        
        viewModel.setup(
            account: account,
            currentAmount: dataHandler.getCurrentEntry(AmountData.self)?.amount,
            currentRestakeValue: dataHandler.getCurrentEntry(RestakeBakerData.self)?.restake,
            isInCooldown: isInCooldown
        )
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        
        self.view?.restakeOptionPublisher.send(viewModel.isRestakeSelected)
        
        validatedAmount
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.viewModel.amountErrorMessage = nil
                case let .failure(error):
                    self?.viewModel.isContinueEnabled = false
                    self?.viewModel.amountErrorMessage = error.localizedDescription
                }
            }
            .store(in: &cancellables)
        
        view?.restakeOptionPublisher
            .combineLatest(validatedAmount.onlySuccess())
            .flatMap { [weak self] (restake, amount) -> AnyPublisher<Result<TransferCostRange, Error>, Never> in
                guard let self = self else {
                    return .just(.failure(StakeError.internalError))
                }
                self.dataHandler.add(entry: AmountData(amount: amount))
                self.dataHandler.add(entry: RestakeBakerData(restake: restake))
                
                let costParams = self.dataHandler.getCostParameters()
                return self.transactionService
                    .getBakingTransferCostRange(parameters: costParams)
                    .showLoadingIndicator(in: self.view)
                    .asResult()
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                case let .success(range):
                    self?.transferCostRange = range
                    self?.viewModel.isContinueEnabled = true
                    self?.viewModel.transactionFee = range.formattedTransactionFee
                }
            }
            .store(in: &cancellables)
        
    }
    
    func pressedContinue() {
        checkForWarnings { [weak self] in
            guard let self = self else { return }
            guard let costRange = self.transferCostRange else {
                return
            }
            
            if self.dataHandler.isNewAmountZero() {
                self.transactionService.getTransferCost(transferType: .removeBaker, costParameters: [])
                    .showLoadingIndicator(in: self.view)
                    .sink { [weak self] error in
                        self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                    } receiveValue: { [weak self] transferCost in
                        let cost = GTU(intValue: Int(transferCost.cost) ?? 0)
                        self?.delegate?.switchToRemoveBaker(cost: cost, energy: transferCost.energy)
                    }
                    .store(in: &self.cancellables)
            } else {
                self.delegate?.finishedAmountInput(range: costRange)
            }
        }
    }
    
    private func checkForWarnings(completion: @escaping () -> Void) {
        if let alert = dataHandler.getCurrentWarning(atDisposal: account.forecastAtDisposalBalance).asAlert(completion: completion) {
            self.view?.showAlert(with: alert)
        } else {
            completion()
        }
    }
    
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
}

private extension StakeWarning {
    func asAlert(completion: @escaping () -> Void) -> AlertOptions? {
        switch self {
        case .noChanges:
            let okAction = AlertAction(name: "baking.nochanges.ok".localized, completion: nil, style: .default)
            
            return AlertOptions(title: "baking.nochanges.title".localized,
                                            message: "baking.nochanges.message".localized,
                                            actions: [okAction])
        case .loweringStake:
            let changeAction = AlertAction(name: "baking.loweringamountwarning.change".localized, completion: nil, style: .default)
            let fineAction = AlertAction(name: "baking.loweringamountwarning.fine".localized,
                                         completion: completion, style: .default)
            return AlertOptions(title: "baking.loweringamountwarning.title".localized,
                                            message: "baking.loweringamountwarning.message".localized,
                                            actions: [changeAction, fineAction])
        case .moreThan95:
            let continueAction = AlertAction(name: "baking.morethan95.continue".localized, completion: completion, style: .default)
            let newStakeAction = AlertAction(name: "baking.morethan95.newstake".localized,
                                             completion: nil,
                                             style: .default)
            return AlertOptions(title: "baking.morethan95.title".localized,
                                            message: "baking.morethan95.message".localized,
                                            actions: [continueAction, newStakeAction])
        case .amountZero:
            let continueAction = AlertAction(name: "baking.amountzero.continue".localized, completion: completion, style: .default)
            let cancelAction = AlertAction(name: "baking.amountzero.newstake".localized,
                                           completion: nil,
                                           style: .default)
            return AlertOptions(title: "baking.amountzero.title".localized,
                                            message: "baking.amountzero.message".localized,
                                            actions: [cancelAction, continueAction])
        case .none:
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

fileprivate extension StakeAmountInputViewModel {
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
            value: balance.displayValueWithGStroke()
        )
        self.secondBalance = BalanceViewModel(
            label: "baking.inputamount.bakerstake".localized,
            value: staked.displayValueWithGStroke()
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
        }
    }
}
