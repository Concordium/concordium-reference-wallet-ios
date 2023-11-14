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
    static var sliderStep = 1e-3
    @StateObject var viewModel: BakerCommissionSettingsViewModel

    var body: some View {
        VStack {
            if let ranges = viewModel.commissionRanges {
                Text("When you open your baker as a pool, you earn commissions of stake delegated to your pool from another accounts")
                    .padding(.bottom, 16)

                Text("Transaction fee commission")
                BakerCommissionSliderView(
                    range: ranges.transactionCommissionRange,
                    commission: $viewModel.transactionFeeCommission
                )

                Text("Baking reward commission")
                BakerCommissionSliderView(
                    range: ranges.bakingCommissionRange,
                    commission: $viewModel.bakingRewardCommission
                )

                Text("Finalization reward commission")
                BakerCommissionSliderView(
                    range: ranges.finalizationCommissionRange,
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
            actions: { error in
                Button {
                    switch error {
                    case .networkError:
                        viewModel.dismissView()
                    default: break
                    }
                    viewModel.error = nil
                } label: {
                    Text("OK")
                }
            },
            message: { error in
                Text(error.errorMessage)
            }
        )
        .onAppear { viewModel.fetchData() }
        .padding()
    }
}

struct BakerCommissionSliderView: View {
    var range: CommissionRange
    @Binding var commission: Double
    let formatter: NumberFormatter = .commissionFormatter

    var body: some View {
        let commissionBinding = Binding<Double>(get: {
            self.commission
        }, set: {
            var commission = $0
            // Snap to the range limits to prevent odd floating point roundoff.
            if commission > range.max - BakerCommissionSettingsView.sliderStep {
                commission = range.max
            }
            if commission < range.min + BakerCommissionSettingsView.sliderStep {
                commission = range.min
            }
            self.commission = commission
        })
        HStack {
            VStack {
                Text("Min:")
                Text("\(formatter.string(from: NSNumber(value: range.min)) ?? " - ")%")
            }
            VStack {
                HStack(alignment: .center, spacing: 1) {
                    Spacer()
                    TextField("", value: $commission, formatter: NumberFormatter.commissionFormatter)
                        .disabled(range.min == range.max)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(width: 72)
                    Text(" %")
                    Spacer()
                }
                if range.min < range.max {
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
