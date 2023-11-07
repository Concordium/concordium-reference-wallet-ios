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
        formatter.numberStyle = .decimal
        formatter.multiplier = 100
        formatter.maximumFractionDigits = 3
        return formatter
    }
}

class BakerCommissionSettingsViewModel: ObservableObject {
    enum BakerCommissionSettingError: LocalizedError {
        case transactionFeeOutOfRange
        case bakingRewardOutOfRange
        case finalizationRewardOutOfRange
        case networkError(Error)

        var errorMessage: String? {
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

    @Published var transactionFeeCommission: Double = 0
    @Published var finalizationRewardCommission: Double = 0
    @Published var bakingRewardCommission: Double = 0

    @Published var finalizationCommissionRange: CommissionRange?
    @Published var transactionCommissionRange: CommissionRange?
    @Published var bakingCommissionRange: CommissionRange?

    @Published var error: BakerCommissionSettingError?

    private var cancellables = Set<AnyCancellable>()
    private var didTapContinue: () -> Void
    private var service: StakeServiceProtocol
    private var handler: StakeDataHandler
    
    private static let commisionMultiplier = 100
    init(
        service: StakeServiceProtocol,
        handler: StakeDataHandler,
        didTapContinue: @escaping (() -> Void)
    ) {
        self.service = service
        self.didTapContinue = didTapContinue
        self.handler = handler
    }

    func fetchData() {
        service.getChainParameters().asResult().sink { result in
            switch result {
            case let .success(response):
                self.bakingCommissionRange = response.bakingCommissionRange
                self.transactionCommissionRange = response.transactionCommissionRange
                self.finalizationCommissionRange = response.finalizationCommissionRange

                if let data = self.handler.getCurrentEntry(BakerComissionData.self) {
                    self.updateCommisionValues(
                        baking: data.bakingRewardComission,
                        transaction: data.transactionComission,
                        finalization: data.finalizationRewardComission
                    )
                } else if let data = self.handler.getNewEntry(BakerComissionData.self) {
                    self.updateCommisionValues(
                        baking: data.bakingRewardComission,
                        transaction: data.transactionComission,
                        finalization: data.finalizationRewardComission
                    )
                } else {
                    self.updateCommisionValues(
                        baking: response.bakingCommissionRange.max,
                        transaction: response.transactionCommissionRange.max,
                        finalization: response.finalizationCommissionRange.max
                    )
                }
            case let .failure(error):
                self.error = .networkError(error)
            }
        }
        .store(in: &cancellables)
    }

    func continueButtonTapped() {
        do {
            try validate()
            handler.add(entry: BakerComissionData(bakingRewardComission: bakingRewardCommission, finalizationRewardComission: finalizationRewardCommission, transactionComission: transactionFeeCommission))
            didTapContinue()
        } catch let error {
            self.error = error as? BakerCommissionSettingError
        }
    }

    func validate() throws {
        guard
            let bakingCommissionRange = bakingCommissionRange,
            let finalizationCommissionRange = finalizationCommissionRange,
            let transactionCommissionRange = transactionCommissionRange else {
            throw BakerCommissionSettingError.bakingRewardOutOfRange
        }

        guard bakingCommissionRange.min ... bakingCommissionRange.max ~= bakingRewardCommission else {
            throw BakerCommissionSettingError.bakingRewardOutOfRange
        }

        guard finalizationCommissionRange.min ... finalizationCommissionRange.max ~= finalizationRewardCommission else {
            throw BakerCommissionSettingError.finalizationRewardOutOfRange
        }

        guard transactionCommissionRange.min ... transactionCommissionRange.max ~= transactionFeeCommission else {
            throw BakerCommissionSettingError.transactionFeeOutOfRange
        }
    }

    private func updateCommisionValues(baking: Double, transaction: Double, finalization: Double) {
        transactionFeeCommission = transaction
        bakingRewardCommission = baking
        finalizationRewardCommission = finalization
    }
}
