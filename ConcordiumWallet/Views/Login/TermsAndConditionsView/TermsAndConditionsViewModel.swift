//
//  TermsAndConditionsViewModel.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 28/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

class TermsAndConditionsViewModel: ObservableObject {
    var didAcceptTermsAndConditions: (() -> Void)?
    var storageManager: StorageManagerProtocol
    var termsAndConditions: TermsAndConditionsResponse
    @Published var termsAndConditionsAccepted = false
    @Published var buttonTitle: String
    init(
        storageManager: StorageManagerProtocol,
        termsAndConditions: TermsAndConditionsResponse
    ) {
        self.storageManager = storageManager
        self.termsAndConditions = termsAndConditions
        if self.storageManager.getLastAcceptedTermsAndConditionsVersion().isEmpty {
            buttonTitle = "welcomeScreen.create.password".localized
        } else {
            buttonTitle = "welcomeScreen.button".localized
        }
    }

    func continueButtonTapped() {
        guard termsAndConditionsAccepted else { return }
        storageManager.storeLastAcceptedTermsAndConditionsVersion(termsAndConditions.version)
        didAcceptTermsAndConditions?()
    }
}
