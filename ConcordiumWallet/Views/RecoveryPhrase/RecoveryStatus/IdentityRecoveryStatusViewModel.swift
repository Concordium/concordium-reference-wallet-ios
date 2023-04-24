//
//  IdentityRecoveryStatusViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Combine

enum IdentityRecoveryStatusEvent {
    case fetchIdentities
//    case changeRecoveryPhrase
    case finish
}

enum IdentityRecoveryStatus: Equatable {
    case fetching
//    case failed
    case emptyResponse
    case success([IdentityDataType], [AccountDataType])
    case partial([IdentityDataType], [AccountDataType], [String])
    
    var isFecthing: Bool {
        switch self {
        case .fetching:
            return true
        default:
            return false
        }
    }
    
    static func == (lhs: IdentityRecoveryStatus, rhs: IdentityRecoveryStatus) -> Bool {
        switch (lhs, rhs) {
        case (.fetching, .fetching):
            return true
//        case (.failed, .failed):
//            return true
        case (.emptyResponse, .emptyResponse):
            return true
        case let (.success(lhsIdentities, lhsAccounts), .success(rhsIdentities, rhsAccounts)):
            return lhsIdentities.elementsEqual(rhsIdentities) { lhsIdentity, rhsIdentity in
                lhsIdentity.nickname == rhsIdentity.nickname
            } && lhsAccounts.elementsEqual(rhsAccounts, by: { lhsAccount, rhsAccount in
                lhsAccount.address == rhsAccount.address
            })
        case let (.partial(lhsIdentities, lhsAccounts, lhsFailedIdentityProviders), .partial(rhsIdentities, rhsAccounts, rhsFailedIdentityProviders)):
            return lhsIdentities.elementsEqual(rhsIdentities) { lhsIdentity, rhsIdentity in
                lhsIdentity.nickname == rhsIdentity.nickname
            } && lhsAccounts.elementsEqual(rhsAccounts, by: { lhsAccount, rhsAccount in
                lhsAccount.address == rhsAccount.address
            }) && lhsFailedIdentityProviders == rhsFailedIdentityProviders
        default:
            return false
        }
    }
}

class IdentityRecoveryStatusViewModel: PageViewModel<IdentityRecoveryStatusEvent> {
    @Published var status: IdentityRecoveryStatus
    @Published var title: String
    @Published var message: String
    @Published var continueLongLabel: String
    @Published var continueLabel: String
    @Published var tryAgain: String
//    @Published var changeRecoveryPhrase: String
    
    init(
        status: IdentityRecoveryStatus,
        title: String,
        message: String,
        continueLongLabel: String,
        continueLabel: String,
        tryAgain: String
//        changeRecoveryPhrase: String
    ) {
        self.status = status
        self.title = title
        self.message = message
        self.continueLongLabel = continueLongLabel
        self.continueLabel = continueLabel
        self.tryAgain = tryAgain
//        self.changeRecoveryPhrase = changeRecoveryPhrase
    }
}
