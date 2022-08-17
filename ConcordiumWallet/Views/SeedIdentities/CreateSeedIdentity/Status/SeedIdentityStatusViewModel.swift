//
//  SeedIdentityStatusViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum SeedIdentityStatusEvent {
    case finish
}

class SeedIdentityStatusViewModel: PageViewModel<SeedIdentityStatusEvent> {
    @Published var title: String
    @Published var body: String
    let identityViewModel: IdentityCard.ViewModel
    @Published var continueLabel: String
    
    init(
        title: String,
        body: String,
        identityViewModel: IdentityCard.ViewModel,
        continueLabel: String
    ) {
        self.title = title
        self.body = body
        self.identityViewModel = identityViewModel
        self.continueLabel = continueLabel
    }
}
