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
    case changeRecoveryPhrase
    case finish
}

enum IdentityRecoveryStatus: Equatable {
    case fetching
    case failed
    case emptyResponse
    case success([IdentityDataType])
    
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
        case (.failed, .failed):
            return true
        case (.emptyResponse, .emptyResponse):
            return true
        case let (.success(lhsIdentities), .success(rhsIdentities)):
            return lhsIdentities.elementsEqual(rhsIdentities) { lhsIdentity, rhsIdentity in
                lhsIdentity.nickname == rhsIdentity.nickname
            }
        default:
            return false
        }
    }
}

class IdentityRecoveryStatusViewModel: PageViewModel<IdentityRecoveryStatusEvent> {
    @Published var status: IdentityRecoveryStatus
    @Published var title: String
    @Published var message: String
    @Published var continueLabel: String
    @Published var tryAgain: String
    @Published var changeRecoveryPhrase: String
    
    init(
        status: IdentityRecoveryStatus,
        title: String,
        message: String,
        continueLabel: String,
        tryAgain: String,
        changeRecoveryPhrase: String
    ) {
        self.status = status
        self.title = title
        self.message = message
        self.continueLabel = continueLabel
        self.tryAgain = tryAgain
        self.changeRecoveryPhrase = changeRecoveryPhrase
    }
}
