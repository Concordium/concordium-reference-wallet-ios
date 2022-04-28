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
    func switchToRemoveBaker(cost: GTU, energy: Int)
    func pressedClose()
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
            previouslyStakedInPool: previouslyStakedInPool,
            isInCooldown: account.baker?.isInCooldown ?? false
        )
        
        viewModel.setup(
            account: account,
            currentAmount: dataHandler.getCurrentEntry(AmountData.self)?.amount,
            currentRestakeValue: dataHandler.getCurrentEntry(RestakeBakerData.self)?.restake,
            isInCooldown: account.baker?.isInCooldown ?? false
        )
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        
        loadPoolParameters()
        
        let costRangeResult = viewModel.$isRestakeSelected
            .combineLatest(viewModel.gtuAmount)
            .compactMap { [weak self] (restake, amount) -> [TransferCostParameter]? in
                guard let self = self else {
                    return nil
                }
                
                self.dataHandler.add(entry: AmountData(amount: amount))
                self.dataHandler.add(entry: RestakeBakerData(restake: restake))
                
                return self.dataHandler.getCostParameters()
            }
            .removeDuplicates()
            .flatMap { [weak self] (costParameters) -> AnyPublisher<Result<TransferCostRange, Error>, Never> in
                guard let self = self else {
                    return .just(.failure(StakeError.internalError))
                }
                
                self.viewModel.isContinueEnabled = false
                
                return self.transactionService
                    .getBakingTransferCostRange(parameters: costParameters)
                    .showLoadingIndicator(in: self.view)
                    .asResult()
                    .eraseToAnyPublisher()
            }
        
        costRangeResult
            .onlySuccess()
            .map { $0.formattedTransactionFee }
            .assignNoRetain(to: \.transactionFee, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.gtuAmount
            .combineLatest(costRangeResult)
            .map { [weak self] (amount, rangeResult) -> Result<GTU, StakeError> in
                guard let self = self else {
                    return .failure(StakeError.internalError)
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
    
    private func loadPoolParameters() {
        stakeService.getChainParameters()
            .first()
            .showLoadingIndicator(in: self.view)
            .sink { [weak self] error in
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            } receiveValue: { [weak self] chainParameters in
                self?.validator.minimumValue = GTU(intValue: Int(chainParameters.minimumEquityCapital) ?? 0)
            }
            .store(in: &cancellables)
    }
    
    func pressedContinue() {
        checkForWarnings { [weak self] in
            guard let self = self else { return }
            
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
                self.delegate?.finishedAmountInput(dataHandler: self.dataHandler)
            }
        }
    }
    
    private func checkForWarnings(completion: @escaping () -> Void) {
        if let alert = dataHandler.getCurrentWarning(atDisposal: account.forecastAtDisposalBalance)?.asAlert(completion: completion) {
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
        pendingChange?.change != .NoChange
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
    var gtuAmount: Publishers.Map<Published<String>.Publisher, GTU> {
        $amount.map { GTU(displayValue: $0) }
    }
    
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
            hightlighted: false
        )
        self.secondBalance = BalanceViewModel(
            label: "baking.inputamount.bakerstake".localized,
            value: staked.displayValueWithGStroke(),
            hightlighted: false
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
