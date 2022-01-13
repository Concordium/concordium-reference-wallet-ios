//
// Created by Concordium on 24/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

enum ViewError: Error {
    case simpleError(localizedReason: String)
    case genericError(reason: Error)
    case serverError(serverError: String)
    case invalidAccountName
    case invalidIdentityName
    case wrongPassword
    case userCancelled
    case networkCommunicationError
    case duplicateRecipient(name: String)
    case exportUnfinalizedAccounts(unfinalizedAccountsNames: [String])
    case cameraAccessDeniedError
    case identityMissingKeys
}

extension ViewError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .simpleError(let reason):
            return reason
        case .genericError(let error):
            #if DEBUG
            return "viewError.genericError".localized + String(describing: error)
            #else
            return "viewError.genericError".localized
            #endif
        case .invalidAccountName:
            return "viewError.invalidName".localized
        case .invalidIdentityName:
            return "viewError.invalidName".localized
        case .wrongPassword:
            return "viewError.wrongPassword".localized
        case .userCancelled:
            return "viewError.userCancelled".localized
        case .networkCommunicationError:
            return "viewError.networkCommunicationError".localized
        case .serverError:
            return "viewError.internalServerError".localized
        case .duplicateRecipient(let name):
            return "viewError.duplicateRecipient".localized + name
        case .exportUnfinalizedAccounts(let unfinalizedAccountsNames):
            return "export.unfinalizedAccounts".localized + unfinalizedAccountsNames.joined(separator: ", ")
        case .cameraAccessDeniedError:
            return "view.error.cameraAccessDenied".localized
        case .identityMissingKeys:
            return "identitymissingkeyserror.details".localized
        }
    }
}

struct ErrorMapper {
    static func toViewError(error: Error) -> ViewError {
        if case NetworkError.communicationError = error {
            return ViewError.networkCommunicationError
        }
        if case NetworkError.serverError(let error) = error {
            return ViewError.serverError(serverError: error.errorMessage)
        }
        if case KeychainError.wrongPassword = error {
            return ViewError.wrongPassword
        }
        if case GeneralError.userCancelled = error {
            return ViewError.userCancelled
        }
        return ViewError.genericError(reason: error)
    }
}
