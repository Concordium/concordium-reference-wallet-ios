//
//  BakerComissionSettingsViewModel.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 06/11/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
import Foundation

extension NumberFormatter {
    static var comissionFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 5
        formatter.numberStyle = .percent
        return formatter
    }
}

class BakerCommissionSettingsViewModel: ObservableObject {
    @Published var transactionFeeComission: Double = 0
    @Published var finalizationRewardComission: Double = 0
    @Published var bakingRewardComission: Double = 0

    @Published var finalizationCommissionRange: CommissionRange?
    @Published var transactionCommissionRange: CommissionRange?
    @Published var bakingCommissionRange: CommissionRange?

    @Published var error: Error?

    private var cancellables = Set<AnyCancellable>()
    private var didTapContinue: () -> Void
    private var service: StakeServiceProtocol
    private var handler: StakeDataHandler
    let formatter: NumberFormatter
    init(
        service: StakeServiceProtocol,
        handler: StakeDataHandler,
        numberFormatter: NumberFormatter,
        continueAction: @escaping (() -> Void)
    ) {
        self.service = service
        didTapContinue = continueAction
        self.handler = handler
        formatter = numberFormatter
    }

    func fetchData() {
        service.getChainParameters().asResult().sink { result in
            switch result {
            case let .success(response):
                self.bakingCommissionRange = response.bakingCommissionRange
                self.transactionCommissionRange = response.transactionCommissionRange
                self.finalizationCommissionRange = response.finalizationCommissionRange
                self.updateCommisionValues(
                    baking: response.bakingCommissionRange.min + (response.bakingCommissionRange.max - response.bakingCommissionRange.min) * 0.1,
                    transaction: response.transactionCommissionRange.min + (response.transactionCommissionRange.max - response.transactionCommissionRange.min) * 0.1,
                    finalization: response.finalizationCommissionRange.max
                )
            case let .failure(error):
                self.error = error
            }
        }
        .store(in: &cancellables)
    }

    func continueButtonTapped() {
        handler.add(
            entry: BakerComissionData(
                bakingRewardComission: bakingRewardComission,
                finalizationRewardComission: finalizationRewardComission,
                transactionComission: transactionFeeComission
            )
        )
        didTapContinue()
    }

    private func updateCommisionValues(baking: Double, transaction: Double, finalization: Double) {
        transactionFeeComission = transaction
        bakingRewardComission = baking
        finalizationRewardComission = finalization
    }
}
