//
//  BakerComissionSettingsView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 31/10/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
import SwiftUI

struct BakerComissionSettingsView: View {
    static var sliderStep = 0.00001
    @StateObject var viewModel: BakerComissionSettingsViewModel

    var body: some View {
        VStack {
            if
                let bakingCommissionRange = viewModel.bakingCommissionRange,
                let transactionCommissionRange = viewModel.transactionCommissionRange,
                let finalizationCommissionRange = viewModel.finalizationCommissionRange {
                Text("When you open your baker as a pool, you earn\ncommissions of stake delegated to your pool from another accounts")
                    .padding(.bottom, 16)

                Text("Transaction fee comission")
                BakerComissionSliderView(
                    range: transactionCommissionRange,
                    comission: $viewModel.transactionFeeComission
                )

                Text("Baking reward comission")
                BakerComissionSliderView(
                    range: bakingCommissionRange,
                    comission: $viewModel.bakingRewardComission
                )

                Text("Finalization reward comission")
                BakerComissionSliderView(
                    range: finalizationCommissionRange,
                    comission: $viewModel.finalizationRewardComission
                )
                Spacer()
                Button(action: viewModel.continueButtonTapped) {
                    Text("Continue")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Pallette.whiteText)
                        .background(Pallette.primary)
                }

                .background(Pallette.primary)
                .cornerRadius(10)
            } else {
                Spacer()
                LoadingIndicator()
                Spacer()
            }
        }
        .onAppear { viewModel.fetchData() }
        .padding()
    }
}

struct BakerComissionSliderView: View {
    var range: CommissionRange
    @Binding var comission: Double
    let formatter: NumberFormatter = .comissionFormatter
    var body: some View {
        HStack {
            VStack {
                Text("Min:")
                Text("\(formatter.string(from: NSNumber(value: range.min)) ?? " - ")")
            }
            VStack {
                TextField("", value: $comission, formatter: formatter)
                    .disabled(range.min == range.max)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)

                if range.min < range.max {
                    Slider(value: $comission, in: range.min ... range.max, step: BakerComissionSettingsView.sliderStep)
                }
            }
            VStack {
                Text("Max:")
                Text("\(formatter.string(from: NSNumber(value: range.max)) ?? " - ")")
            }
        }
        .padding(.bottom, 16)
    }
}

#if DEBUG
fileprivate class StakeServiceMock: StakeServiceProtocol {
    func getBakerPool(bakerId: Int) -> AnyPublisher<BakerPoolResponse, Error> {
        .empty()
    }

    func getPassiveDelegation() -> AnyPublisher<PassiveDelegation, Error> {
        .empty()
    }

    func getChainParameters() -> AnyPublisher<ChainParametersResponse, Error> {
        .just(
            try! ChainParametersResponse("""
                {
                    "accountCreationLimit": 10,
                    "bakingCommissionRange": {
                        "max": 0.2,
                        "min": 0.2
                    },
                    "blockEnergyLimit": 5000000,
                    "capitalBound": 0.1,
                    "delegatorCooldown": 900,
                    "euroPerEnergy": {
                        "denominator": 1100000,
                        "numerator": 1
                    },
                    "finalizationCommissionRange": {
                        "max": 0.95,
                        "min": 5.0e-2
                    },
                    "finalizerRelativeStakeThreshold": 0.11,
                    "foundationAccountIndex": 5,
                    "leverageBound": {
                        "denominator": 1,
                        "numerator": 3
                    },
                    "maximumFinalizers": 6,
                    "microGTUPerEuro": {
                        "denominator": 44819431759,
                        "numerator": 7776407313978818560
                    },
                    "minBlockTime": 2800,
                    "minimumEquityCapital": "100000000",
                    "minimumFinalizers": 3,
                    "mintPerPayday": 1.582e-5,
                    "passiveBakingCommission": 0.12,
                    "passiveFinalizationCommission": 1.0,
                    "passiveTransactionCommission": 0.12,
                    "poolOwnerCooldown": 1800,
                    "rewardParameters": {
                        "gASRewards": {
                            "accountCreation": 2.0e-2,
                            "baker": 0.25,
                            "chainUpdate": 5.0e-3
                        },
                        "mintDistribution": {
                            "bakingReward": 0.6,
                            "finalizationReward": 0.3
                        },
                        "transactionFeeDistribution": {
                            "baker": 0.45,
                            "gasAccount": 0.45
                        }
                    },
                    "rewardPeriodLength": 4,
                    "timeoutBase": 10000,
                    "timeoutDecrease": {
                        "denominator": 2,
                        "numerator": 1
                    },
                    "timeoutIncrease": {
                        "denominator": 2,
                        "numerator": 3
                    },
                    "transactionCommissionRange": {
                        "max": 0.8,
                        "min": 0.2
                    }
                }
                """
            )
        )
    }

    func generateBakerKeys() -> Result<GeneratedBakerKeys, Error> {
        fatalError()
    }
}

#Preview {
    BakerComissionSettingsView(
        viewModel: .init(
            service: StakeServiceMock(),
            handler: StakeDataHandler(transferType: .configureBaker),
            numberFormatter: .comissionFormatter,
            continueAction: { }
        )
    )
}
#endif
