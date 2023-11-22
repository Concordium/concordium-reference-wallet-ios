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
    private var cancellables = Set<AnyCancellable>()
    private var didTapContinue: () -> Void
    private var service: StakeServiceProtocol
    private var handler: StakeDataHandler

    init(
        service: StakeServiceProtocol,
        handler: StakeDataHandler,
        didTapContinue: @escaping (() -> Void)
    ) {
        self.service = service
        self.didTapContinue = didTapContinue
        self.handler = handler
    }

    func loadData() {
        // This covers a scenario when updating pool settings.
        // The values are not editable but, we have to diffrentiate between the flow setting up new validator and editing the current one.
        if let data = handler.getCurrentEntry(BakerCommissionData.self) {
            transactionFeeCommission = data.transactionComission
            bakingRewardCommission = data.bakingRewardComission
            finalizationRewardCommission = data.finalizationRewardComission
        } else if let data = handler.getNewEntry(BakerCommissionData.self) {
            // This covers a scenario when setting up new validator account.
            transactionFeeCommission = data.transactionComission
            bakingRewardCommission = data.bakingRewardComission
            finalizationRewardCommission = data.finalizationRewardComission
        }
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
}
