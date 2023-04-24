//
//  SeedIdentityOnboardingPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol SeedIdentityOnboardingPresenterDelegate: AnyObject {
    func onboardingDidFinish()
}

class SeedIdentityOnboardingPresenter: SwiftUIPresenter<SeedIdentityOnboardingViewModel> {
    private weak var delegate: SeedIdentityOnboardingPresenterDelegate?
    
    init(delegate: SeedIdentityOnboardingPresenterDelegate) {
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                pages: [
                    ("onboardingcarousel.seedflow.page1.title".localized, "seed_identity_onboarding_en_1"),
                    ("onboardingcarousel.seedflow.page2.title".localized, "seed_identity_onboarding_en_2"),
                    ("onboardingcarousel.seedflow.page3.title".localized, "seed_identity_onboarding_en_3"),
                    ("onboardingcarousel.seedflow.page4.title".localized, "seed_identity_onboarding_en_4")
                ]
            )
        )
        
        viewModel.navigationTitle = "onboardingcarousel.seedflow.title".localized
    }
    
    override func receive(event: SeedIdentityOnboardingEvent) {
        switch event {
        case .finish:
            delegate?.onboardingDidFinish()
        }
    }
}
