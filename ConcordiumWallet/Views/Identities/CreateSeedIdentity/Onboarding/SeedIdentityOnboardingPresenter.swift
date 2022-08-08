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
                    ("identities.seed.onboarding.concepts".localized, "seed_identity_onboarding_en_1"),
                    ("identities.seed.onboarding.youareread".localized, "seed_identity_onboarding_en_2")
                ]
            )
        )
    }
    
    override func receive(event: SeedIdentityOnboardingEvent) {
        switch event {
        case .finish:
            delegate?.onboardingDidFinish()
        }
    }
}
