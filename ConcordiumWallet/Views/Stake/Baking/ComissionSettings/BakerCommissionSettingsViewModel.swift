//
//  BakerCommissionSettingsViewModel.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 06/11/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
import Foundation

extension NumberFormatter {
    static var commissionFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.multiplier = 100
        formatter.maximumFractionDigits = 3
        return formatter
    }
}

enum BakerCommissionSettingError: LocalizedError {
    case networkError(Error)

    var errorMessage: String {
        switch self {
        case .bakingRewardOutOfRange:
            return "Baking reward is out of specified range"
        case .finalizationRewardOutOfRange:
            return "Finalization reward is out of specified range"
        case .transactionFeeOutOfRange:
            return "Transaction fee is out of specified range"
        case let .networkError(error):
            return error.localizedDescription
        }
    }
}

class BakerCommissionSettingsViewModel: ObservableObject {
    @Published var transactionFeeCommission: Double = 0
    @Published var finalizationRewardCommission: Double = 0
    @Published var bakingRewardCommission: Double = 0

    @Published var error: BakerCommissionSettingError?
    var dismissView: () -> Void
    private var cancellables = Set<AnyCancellable>()
    private var didTapContinue: () -> Void
    private var service: StakeServiceProtocol
    private var handler: StakeDataHandler

    init(
        service: StakeServiceProtocol,
        handler: StakeDataHandler,
        didTapContinue: @escaping (() -> Void),
        dismissView: @escaping (() -> Void)
    ) {
        self.service = service
        self.didTapContinue = didTapContinue
        self.handler = handler
        self.dismissView = dismissView
    }

    func fetchData() {
        service.getChainParameters()
            .asResult().sink { result in
                switch result {
                case let .success(response):
                    self.updateCommissionValues(
                        baking: response.bakingCommissionRange.min + (response.bakingCommissionRange.max - response.bakingCommissionRange.min) * 0.1,
                        transaction: response.transactionCommissionRange.min + (response.transactionCommissionRange.max - response.transactionCommissionRange.min) * 0.1,
                        finalization: response.finalizationCommissionRange.min + (response.finalizationCommissionRange.max - response.finalizationCommissionRange.min) * 0.1
                    )
                    return
                case let .failure(error):
                    self.error = .networkError(error)
                }
            }
            .store(in: &cancellables)
    }

    func continueButtonTapped() {
        handler.add(
            entry: BakerCommissionData(
                bakingRewardComission: bakingRewardCommission,
                finalizationRewardComission: finalizationRewardCommission,
                transactionComission: transactionFeeCommission
            )
        )
        didTapContinue()
    }

    private func updateCommissionValues(baking: Double, transaction: Double, finalization: Double) {
        transactionFeeCommission = transaction
        bakingRewardCommission = baking
        finalizationRewardCommission = finalization
    }
}
