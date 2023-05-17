//
//  TermsAndConditionsView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 12/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @StateObject var viewModel: TermsAndConditionsViewModel

    private var termsAndConditionsLink: AttributedString {
        var result = AttributedString("welcomeScreen.tos.checkbox.link".localized)
        result.font = UIFont.WorkSans(size: 14, .semibold)
        result.foregroundColor = Pallette.primary
        result.link = viewModel.termsAndConditions.url
        return result
    }

    private static var termsAndConditionsURL = "https://developer.concordium.software/en/mainnet/net/resources/terms-and-conditions.html"

    var body: some View {
        VStack {
            ZStack {
                Image("Background_squares")
                Image("padlock")
            }
            Text("welcomeScreen.subtitle".localized)
                .font(Font(UIFont.WorkSans(size: 25, .semibold)))
                .padding(8)
            Text("welcomeScreen.details".localized)
                .font(Font(UIFont.WorkSans(size: 15, .light)))
                .multilineTextAlignment(.center)
                .padding(8)

            Spacer()
            Toggle(isOn: $viewModel.termsAndConditionsAccepted) {
                Text("welcomeScreen.tos.checkbox.regular".localized).font(Font(UIFont.WorkSans(size: 14, .light))) +
                    Text(termsAndConditionsLink)
            }
            .toggleStyle(SwitchToggleStyle(tint: Pallette.primary))
            .padding(8)

            Button {
                viewModel.continueButtonTapped()
            } label: {
                Text(viewModel.buttonTitle).frame(maxWidth: .infinity)
            }
            .applyStandardButtonStyle(disabled: !viewModel.termsAndConditionsAccepted)
            .padding(8)
        }
        .padding()
    }
}
