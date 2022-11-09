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
    case finishNewIdentityAfterSettingUpTheWallet
    case makeNewIdentityRequest
    case makeNewAccountRequest
}

class SeedIdentityStatusViewModel: PageViewModel<SeedIdentityStatusEvent> {
    @Published var title: String
    @Published var body: String
    let identityViewModel: IdentityCard.ViewModel
    @Published var continueLabel: String
    @Published var identityRejectionError: IdentityRejectionError?
    @Published var isIdentityConfirmed: Bool
    @Published var isNewIdentityAfterSettingUpTheWallet: Bool
    
    init(
        title: String,
        body: String,
        identityViewModel: IdentityCard.ViewModel,
        continueLabel: String,
        isNewIdentityAfterSettingUpTheWallet: Bool
    ) {
        self.title = title
        self.body = body
        self.identityViewModel = identityViewModel
        self.continueLabel = continueLabel
        self.identityRejectionError = nil
        self.isIdentityConfirmed = false
        self.isNewIdentityAfterSettingUpTheWallet = isNewIdentityAfterSettingUpTheWallet
    }
}
