//
// Created by Concordium on 19/02/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

class IdentitiesService {
    private var networkManager: NetworkManagerProtocol
    private var storageManager: StorageManagerProtocol

    init(networkManager: NetworkManagerProtocol, storageManager: StorageManagerProtocol) {
        self.networkManager = networkManager
        self.storageManager = storageManager
    }

    func getIpInfo() -> AnyPublisher<[IPInfoResponseElement], Error> {
        networkManager.load(ResourceRequest(url: ApiConstants.ipInfo))
    }

    func getGlobal() -> AnyPublisher<GlobalWrapper, Error> {
        networkManager.load(ResourceRequest(url: ApiConstants.global))
    }
    
    func createIdentityObjectRequest(on url: String, with idRequest: IDRequest) throws -> ResourceRequest {
        let issuanceStartURL = URL(string: url)!

        let originalParameters = issuanceStartURL.queryParameters
        guard let idRequestString = try idRequest.jsonString() else {
            throw GeneralError.unexpectedNullValue
        }
        var parameters: [String: String] = [
            "response_type": "code",
            "redirect_uri": idRequest.redirectURI,
            "scope": "identity",
            "state": idRequestString
        ]
        // To handle any present parameters in the original url
        if let originalParameters = originalParameters {
            parameters = parameters.merging(originalParameters) { $1 }
        }
        return ResourceRequest(url: issuanceStartURL.urlWithoutParameters!, parameters: parameters)
    }
    
    func getInitialAccountStatus(for account: AccountDataType) -> AnyPublisher<AccountSubmissionStatus, Error> {
        guard let identity = account.identity else {
            return .just(AccountSubmissionStatus(status: account.transactionStatus ?? .committed, account: account))
        }
        if account.transactionStatus == SubmissionStatusEnum.finalized {
            return .just(AccountSubmissionStatus(status: .finalized, account: account))
        }
        if account.transactionStatus == SubmissionStatusEnum.absent {
            return .just(AccountSubmissionStatus(status: .absent, account: account))
        }
        return updateIdentity(identity: identity)
            .map { (identity) -> AccountSubmissionStatus in
                
                switch identity.state {
                case .confirmed:
                    _ = account.write {
                        var account = $0
                        account.transactionStatus = .finalized
                    }
                    return AccountSubmissionStatus(status: .finalized, account: account)
                default:
                    return AccountSubmissionStatus(status: .committed, account: account)
                }
        }.eraseToAnyPublisher()
    }

    func updatePendingIdentities() -> AnyPublisher<[IdentityDataType], Error> {
        let updatedIdentities = storageManager
                .getPendingIdentities()
                .map { identity in
                    updateIdentity(identity: identity)
                }

        // convert [Publisher<IdentityDataType>] to Publisher<[IdentityDataType]>
        return Publishers.Sequence<[AnyPublisher<IdentityDataType, Error>], Error>(sequence: updatedIdentities)
                .flatMap { $0 }
                .collect()
                .eraseToAnyPublisher()
    }

    private func updateIdentity(identity: IdentityDataType) -> AnyPublisher<IdentityDataType, Error> {
        guard let url = URL(string: identity.ipStatusUrl) else {
            do {
                let updatedIdentity = try addErrorMessage("identityCreation.dataCorrupted".localized, to: identity)
                return .just(updatedIdentity)
            } catch {
                return .fail(error)
            }
        }
        return networkManager.load(URLRequest(url: url))
                .tryMap { (status: IdentityCreationStatus) in
                    try self.parse(status: status, for: identity)
                }
                .eraseToAnyPublisher()
    }

    private func parse(status: IdentityCreationStatus, for identity: IdentityDataType) throws -> IdentityDataType {
        if status.status == .done, let identityObjectWrapper = status.token {
//             return try addErrorMessage("ERROR", to: identity)
            return try self.addIdentityObject(identityObjectWrapper, to: identity)
        } else if status.status == .error, let errorMessage = status.detail {
            return try addErrorMessage(errorMessage, to: identity)
        } else  if status.status == .pending {
            return identity
        }
        throw NetworkError.invalidResponse
    }

    private func addErrorMessage(_ error: String, to identity: IdentityDataType) throws -> IdentityDataType {
        if let account = storageManager.getAccounts(for: identity).first {
            _ = account.withUpdatedStatus(status: .absent)
        }
        return identity.withUpdated(identityCreationError: error)
    }

    private func addIdentityObject(_ identityObjectWrapper: IdentityWrapperShell, to identity: IdentityDataType) throws -> IdentityDataType {
        let updatedIdentity = identity.withUpdated(identityObject: identityObjectWrapper.identityObject.value)
        if let account = storageManager.getAccounts(for: updatedIdentity).first {
            _ = try account.write {
                var account = $0
                account.credential = identityObjectWrapper.credential.toCredential()
                account.transactionStatus = .finalized
            }.get()
            self.addAccountToRecipientList(account: account)
            let shieldedAmount = ShieldedAmountTypeFactory.create().withInitialValue(for: account)
            _ = try? self.storageManager.storeShieldedAmount(amount: shieldedAmount)
        }
        return updatedIdentity
    }
    
    private func addAccountToRecipientList(account: AccountDataType) {
        var recipient = RecipientDataTypeFactory.create()
        recipient.address = account.address
        recipient.name = account.displayName
        _ = try? self.storageManager.storeRecipient(recipient)
    }
}
