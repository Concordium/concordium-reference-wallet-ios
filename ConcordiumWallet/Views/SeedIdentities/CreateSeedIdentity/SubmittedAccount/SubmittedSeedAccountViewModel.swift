//
//  SubmittedSeedAccountViewModel.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 7.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum SubmittedSeedAccountEvent {
    case finishAccount
}

class SubmittedSeedAccountViewModel: PageViewModel<SubmittedSeedAccountEvent> {
    @Published var title: String
    @Published var body: String
    @Published var finishAccount: String
    let identityViewModel: IdentityCard.ViewModel
    let accountViewModel: SubmittedAccountCardViewModel
    
    init(
        title: String,
        body: String,
        finishAccount: String,
        identityViewModel: IdentityCard.ViewModel,
        accountViewModel: SubmittedAccountCardViewModel
    ) {
        self.title = title
        self.body = body
        self.finishAccount = finishAccount
        self.identityViewModel = identityViewModel
        self.accountViewModel = accountViewModel
    }
}

class SubmittedAccountCardViewModel: ObservableObject {
    enum State {
        case notAvailable, available, pending
    }
    
    @Published var state: State
    @Published var accountIndex: Int
    @Published var identityNickname: String
    @Published var totalLabel: String
    @Published var totalAmount: GTU
    @Published var atDisposalLabel: String
    @Published var atDisposalAmount: GTU
    @Published var makeNewIdentityRequest: String
    
    init(
        state: State = .notAvailable,
        accountIndex: Int = 0,
        identityNickname: String = "",
        totalLabel: String = "",
        totalAmount: GTU = .zero,
        atDisposalLabel: String = "",
        atDisposalAmount: GTU = .zero,
        makeNewIdentityRequest: String = ""
    ) {
        self.state = state
        self.accountIndex = accountIndex
        self.identityNickname = identityNickname
        self.totalLabel = totalLabel
        self.totalAmount = totalAmount
        self.atDisposalLabel = atDisposalLabel
        self.atDisposalAmount = atDisposalAmount
        self.makeNewIdentityRequest = makeNewIdentityRequest
    }
    
    var accountTitle = "4WHF...eNu8"
    
    func update(with account: AccountDataType) {
        state = .pending
        accountIndex = account.accountIndex
        totalAmount = GTU(intValue: account.totalForecastBalance)
        atDisposalAmount = GTU(intValue: account.forecastAtDisposalBalance)
    }
}
