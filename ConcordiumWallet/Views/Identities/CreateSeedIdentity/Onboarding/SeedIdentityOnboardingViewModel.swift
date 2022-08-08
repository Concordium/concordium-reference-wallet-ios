//
//  SeedIdentityOnboardingViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum SeedIdentityOnboardingEvent {
    case finish
}

class SeedIdentityOnboardingViewModel: PageViewModel<SeedIdentityOnboardingEvent> {
    let pages: [(String, String)]
    
    init(pages: [(String, String)]) {
        self.pages = pages
    
        super.init()
    }
}
