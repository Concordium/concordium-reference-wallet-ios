//
//  BakerCommissionSettingsView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 31/10/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
import SwiftUI

struct BakerCommissionSettingsView: View {
    static var sliderStep = 1e-5
    @StateObject var viewModel: BakerCommissionSettingsViewModel
    var isShowingError: Binding<Bool> {
        Binding {
            viewModel.error != nil
        } set: { _ in
            viewModel.error = nil
        }
    }

    var body: some View {
        VStack {
            if
                let bakingCommissionRange = viewModel.bakingCommissionRange,
                let transactionCommissionRange = viewModel.transactionCommissionRange,
                let finalizationCommissionRange = viewModel.finalizationCommissionRange {
                Text("When you open your baker as a pool, you earn\ncommissions of stake delegated to your pool from another accounts")
                    .padding(.bottom, 16)

                Text("Transaction fee commission")
                BakerCommissionSliderView(
                    range: transactionCommissionRange,
                    commission: $viewModel.transactionFeeCommission
                )

                Text("Baking reward commission")
                BakerCommissionSliderView(
                    range: bakingCommissionRange,
                    commission: $viewModel.bakingRewardCommission
                )

                Text("Finalization reward commission")
                BakerCommissionSliderView(
                    range: finalizationCommissionRange,
                    commission: $viewModel.finalizationRewardCommission
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
        .alert(
            "Error",
            isPresented: $viewModel.error.isNotNil(),
            presenting: viewModel.error,
            actions: { _ in },
            message: { error in
                Text(error.errorMessage ?? "Unspecified error")
            })
        .onAppear { viewModel.fetchData() }
        .padding()
    }
}

struct BakerCommissionSliderView: View {
    var range: CommissionRange
    @Binding var commission: Double
    let formatter: NumberFormatter = .comissionFormatter
    private let allowCustomCommissionRates = UserDefaults.standard.bool(forKey: "ALLOW_CUSTOM_COMMISSION_RATES")
    var body: some View {
        let commissionBinding = Binding<Double>(get: {
            self.commission
        }, set: {
            // Rounding for edge cases of sliders to prevent odd values caused by floating point errors.
            if $0 + BakerCommissionSettingsView.sliderStep > range.max || $0 - BakerCommissionSettingsView.sliderStep < range.min {
                commission = round($0 * 100) / 100
            } else {
                self.commission = $0
            }
        })
        HStack {
            VStack {
                Text("Min:")
                Text("\(formatter.string(from: NSNumber(value: range.min)) ?? " - ")%")
            }
            VStack {
                HStack(alignment: .center, spacing: 1) {
                    Spacer()
                    TextField("", value: $commission, formatter: NumberFormatter.comissionFormatter)
                        .disabled(range.min == range.max && allowCustomCommissionRates)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(width: 72)
                    Text(" %")
                    Spacer()
                }
                // `ALLOW_CUSTOM_COMMISSION_RATES` flag can be added in arguments passed on launch in scheme settings.
                // Used for toggling on/off slider feature.
                if range.min < range.max && allowCustomCommissionRates {
                    Slider(value: commissionBinding, in: range.min ... range.max, step: BakerCommissionSettingsView.sliderStep)
                }
            }
            VStack {
                Text("Max:")
                Text("\(formatter.string(from: NSNumber(value: range.max)) ?? " - ")%")
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

struct BakerCommissionSettingsViewPreview: PreviewProvider {
    static var previews: some View {
        BakerCommissionSettingsView(
            viewModel: .init(
                service: StakeServiceMock(),
                handler: StakeDataHandler(transferType: .configureBaker),
                didTapContinue: { }
            )
        )
    }
}
#endif
