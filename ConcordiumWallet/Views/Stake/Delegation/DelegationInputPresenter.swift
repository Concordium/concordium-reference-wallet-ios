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
    
}

enum RestakeOption {
    case yes
    case no
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
    var validAmount: GTU?
    var restake: RestakeOption = .yes
    
    private var cancellables = Set<AnyCancellable>()
    
    let validator: StakeAmountInputValidator
    
    init(account: AccountDataType, delegate: DelegationAmountInputPresenterDelegate? = nil) {
        self.account = account
        self.delegate = delegate
        viewModel.setup(account: account, amount: validAmount)
        
        //TODO: add limits to the validator
        validator = StakeAmountInputValidator(minimumValue: GTU(intValue: 1),
                                              maximumValue: GTU(intValue: 100000),
                                              atDisposal: GTU(intValue: 200000),
                                              currentPool: GTU(intValue: 200000),
                                              poolLimit: GTU(intValue: 250000))
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        
        self.view?.restakeOptionPublisher.sink(receiveCompletion: { _ in
        }, receiveValue: { [weak self] isRestaking in
            self?.restake = isRestaking ? .yes : .no
        }).store(in: &cancellables)
        
        self.view?.amountPublisher.map { amount -> GTU in
            let intVal = Int(amount) ?? 0
            return GTU(intValue: intVal)
        }
        .flatMap { [weak self] amount -> AnyPublisher<Result<GTU, StakeError>, Never> in
            guard let self = self else { return .just(Result.failure(StakeError.internalError))}
            return self.validator.validate(amount: amount)
                .mapError { [weak self] error -> StakeError in
                    self?.viewModel.amountErrorMessage = error.localizedDescription
                    return error
                }.map { amount in
                    return Result<GTU, StakeError>.success(amount)
                }.replaceError(with: Result.failure(StakeError.internalError))
                .eraseToAnyPublisher()
        }
        .sink(receiveCompletion: { completion in
        }, receiveValue: { [weak self]  result in
            if case Result.success(let amount) = result {
                self?.validAmount = amount
                self?.viewModel.amountErrorMessage = nil
            }
        })
        .store(in: &cancellables)
    }
}

fileprivate extension StakeAmountInputViewModel {
    func setup (account: AccountDataType, amount: GTU?) {
        let atDisposal = GTU(intValue: account.forecastAtDisposalBalance)
        self.firstBalance = BalanceViewModel(label: "delegation.inputamount.balance" .localized,
                                             value: atDisposal.displayValueWithGStroke())
        // TODO: update values
        self.secondBalance = BalanceViewModel(label: "delegation.inputamount.delegationstake".localized,
                                              value: "TBD")
        self.currentPoolLimit = BalanceViewModel(label: "delegation.inputamount.currentpool".localized,
                                                 value: "TBD")
        self.poolLimit = BalanceViewModel(label: "delegation.inputamount.poollimit".localized,
                                          value: "TBD")
        self.transactionFee = String(format: "stake.inputamount.transactionfee".localized, "TBD")
        self.bottomMessage = "delegation.inputamount.bottommessage".localized
        self.amount = amount?.displayValue() ?? ""
    }
}
