//
//  SeedIdentityOnboardingView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import SwiftUI

struct SeedIdentityOnboardingView: Page {
    @ObservedObject var viewModel: SeedIdentityOnboardingViewModel
    
    var pageBody: some View {
        VStack {
            OnboardingCarouselView(
                title: nil,
                pages: viewModel.pages.map {
                    OnboardingCarouselView.Page(
                        title: $0.0,
                        htmlFile: $0.1
                    )
                }) {
                    viewModel.send(.finish)
                }
            
        }.padding([.top], 10)
    }
}

struct SeedIdentityOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        SeedIdentityOnboardingView(
            viewModel: .init(
                pages: [
                    ("The Concordium Concepts", "seed_identity_onboarding_en_1"),
                    ("You are ready!", "seed_identity_onboarding_en_2"),
                    ("You are ready!", "seed_identity_onboarding_en_3"),
                    ("You are ready!", "seed_identity_onboarding_en_4")
                ]
            )
        )
        .previewDevice("iPhone SE (3rd generation)")
    }
}
