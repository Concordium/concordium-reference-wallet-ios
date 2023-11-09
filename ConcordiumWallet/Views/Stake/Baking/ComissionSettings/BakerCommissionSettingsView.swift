//
//  BakerComissionSettingsView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 31/10/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
import SwiftUI

struct BakerCommissionSettingsView: View {
    static var sliderStep = 0.00001
    @ObservedObject var viewModel: BakerCommissionSettingsViewModel
    private let formatter = NumberFormatter.comissionFormatter
    var body: some View {
        VStack {
            if
                let _ = viewModel.bakingCommissionRange,
                let _ = viewModel.transactionCommissionRange,
                let _ = viewModel.finalizationCommissionRange {
                Text("When you open your baker as a pool, you earn\ncommissions of stake delegated to your pool from another accounts")
                    .padding(.bottom, 16)

                Text("Transaction fee comission")
                    .padding(8)
                Text("\(formatter.string(from: NSNumber(value: viewModel.transactionFeeComission)) ?? " - ")")
                    .padding(.horizontal)
                Text("Baking reward comission")
                    .padding(8)
                Text("\(formatter.string(from: NSNumber(value: viewModel.bakingRewardComission)) ?? " - ")")
                    .padding(.horizontal)
                Spacer()
                Button(action: viewModel.continueButtonTapped) {
                    Text("Continue")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(UIColor.whiteText))
                        .background(Color(UIColor.primary))
                }

                .background(Color(UIColor.primary))
                .cornerRadius(10)
            } else {
                Spacer()
                ActivityIndicator(isAnimating: true)
                Spacer()
            }
        }
        .onAppear { viewModel.fetchData() }
        .padding()
    }
}

struct ActivityIndicator: UIViewRepresentable {
    typealias UIView = UIActivityIndicatorView
    var isAnimating: Bool
    fileprivate var configuration = { (_: UIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BakerCommissionSettingsView(
            viewModel: BakerCommissionSettingsViewModel(
                service: ServicesProvider.defaultProvider().stakeService(),
                handler: .init(transferType: .configureBaker),
                numberFormatter: NumberFormatter.comissionFormatter,
                continueAction: {}))
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("Default preview")
    }
}
