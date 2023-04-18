//
//  TermsAndConditionsView.swift
//  ConcordiumWallet
//
//  Created by Milan Wykop on 12/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.colorScheme) var colorScheme
    private static var termsAndConditionsURL = "https://developer.concordium.software/en/mainnet/net/resources/terms-and-conditions.html"
    @State var termsAndConditionsAccepted = false
    var body: some View {
        ZStack {
            colorScheme == .dark ? Color.black : Color.white
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
                Toggle(isOn: $termsAndConditionsAccepted) {
                    Text("welcomeScreen.toc.checkbox".localized)
                        .font(Font(UIFont.WorkSans(size: 14, .light)))
                }
                .toggleStyle(SwitchToggleStyle(tint: Pallette.primary))
                .padding(8)
                Button {
                } label: {
                    Text("welcomeScreen.create.password".localized)
                        .frame(maxWidth: .infinity)
                }
                .applyStandardButtonStyle(disabled: !termsAndConditionsAccepted)
                .padding(8)
            }
            .padding()
        }
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
}
