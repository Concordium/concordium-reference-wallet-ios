//
//  SubmitSeedAccountViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 09/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum SubmitSeedAccountEvent {
    case submitAccount
    case makeNewIdentityRequest
}

struct IdentityRejectionError: Identifiable {
    var id: String { description }
    let description: String
}

class SubmitSeedAccountViewModel: PageViewModel<SubmitSeedAccountEvent> {
    @Published var title: String
    @Published var body: String
    let identityViewModel: IdentityCard.ViewModel
    let accountViewModel: AccountCardViewModel
    @Published var identityRejectionError: IdentityRejectionError?
    @Published var isNewAccountAfterSettingUpTheWallet: Bool
    
    init(
        title: String,
        body: String,
        identityViewModel: IdentityCard.ViewModel,
        accountViewModel: AccountCardViewModel,
        isNewAccountAfterSettingUpTheWallet: Bool
    ) {
        self.title = title
        self.body = body
        self.identityViewModel = identityViewModel
        self.accountViewModel = accountViewModel
        self.identityRejectionError = nil
        self.isNewAccountAfterSettingUpTheWallet = isNewAccountAfterSettingUpTheWallet
    }
}

class AccountCardViewModel: ObservableObject {
    enum State {
        case notAvailable, available, pending
    }
    
    @Published var state: State
    @Published var accountIndex: Int
    @Published var identityIndex: Int
    @Published var totalLabel: String
    @Published var totalAmount: GTU
    @Published var atDisposalLabel: String
    @Published var atDisposalAmount: GTU
    @Published var submitAccount: String
    @Published var makeNewIdentityRequest: String
    
    init(
        state: State = .notAvailable,
        accountIndex: Int = 0,
        identityIndex: Int = 0,
        totalLabel: String = "",
        totalAmount: GTU = .zero,
        atDisposalLabel: String = "",
        atDisposalAmount: GTU = .zero,
        submitAccount: String = "",
        makeNewIdentityRequest: String = ""
    ) {
        self.state = state
        self.accountIndex = accountIndex
        self.identityIndex = identityIndex
        self.totalLabel = totalLabel
        self.totalAmount = totalAmount
        self.atDisposalLabel = atDisposalLabel
        self.atDisposalAmount = atDisposalAmount
        self.submitAccount = submitAccount
        self.makeNewIdentityRequest = makeNewIdentityRequest
    }
    
    var accountTitle = "4WHF...eNu8"
    
    var identityTitle: String {
        var counter = 1
        let identities = ServicesProvider.defaultProvider().storageManager().getIdentities()
        for identity in identities {
            if identity.nickname == String(format: "identities.seed.shared.identitytitle".localized, counter) {
                counter += 1
            }
        }
        
        return String(format: "identities.seed.shared.identitytitle".localized, counter - 1)
    }
    
    func update(with account: AccountDataType) {
        state = .pending
        accountIndex = account.accountIndex
        totalAmount = GTU(intValue: account.totalForecastBalance)
        atDisposalAmount = GTU(intValue: account.forecastAtDisposalBalance)
    }
}
