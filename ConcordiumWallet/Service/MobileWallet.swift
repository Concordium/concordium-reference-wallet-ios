//
// Created by Concordium on 13/02/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine
// sourcery: AutoMockable
protocol MobileWalletProtocol {
    func check(accountAddress: String) -> Bool
    func createIdRequestAndPrivateData(initialAccountName: String,
                                       identityName: String,
                                       identityProvider: IdentityProviderDataType,
                                       global: GlobalWrapper,
                                       requestPasswordDelegate: RequestPasswordDelegate)
                    -> AnyPublisher<(IDObjectRequestWrapper, IdentityCreation), Error>
    func createCredential(global: GlobalWrapper, account: AccountDataType, pwHash: String, expiry: Date)
                    -> AnyPublisher<CreateCredentialRequest, Error>
    func createTransfer(from fromAccount: AccountDataType,
                        to toAccount: String?,
                        amount: String?,
                        nonce: Int,
                        memo: String?,
                        capital: String?,
                        restakeEarnings: Bool?,
                        delegationTarget: DelegationTarget?,
                        openStatus: String?,
                        metadataURL: String?,
                        transactionFeeCommission: Double?,
                        bakingRewardCommission: Double?,
                        finalizationRewardCommission: Double?,
                        bakerKeys: GeneratedBakerKeys?,
                        expiry: Date, energy: Int,
                        transferType: TransferType,
                        requestPasswordDelegate: RequestPasswordDelegate,
                        global: GlobalWrapper?, inputEncryptedAmount: InputEncryptedAmount?,
                        receiverPublicKey: String?,
                        payload: Payload?
    ) -> AnyPublisher<CreateTransferRequest, Error>
    func parameterToJson(with contractParams: ContractUpdateParameterToJsonInput) throws -> String
    func decryptEncryptedAmounts(from fromAccount: AccountDataType,
                                 _ encryptedAmounts: [String],
                                 requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<[(String, Int)], Error>
    
    func combineEncryptedAmount(_ encryptedAmount1: String, _ encryptedAmount2: String) -> Result<String, Error>
    func createAccountTransfer(input: String) throws -> String 
    func getAccountAddressesForIdentity(global: GlobalWrapper,
                                        identityObject: IdentityObject,
                                        privateIDObjectData: PrivateIDObjectData,
                                        startingFrom: Int,
                                        pwHash: String) throws -> Result<[MakeGenerateAccountsResponseElement], Error>
    func generateBakerKeys() -> Result<GeneratedBakerKeys, Error>
    
    func updatePasscode(for account: AccountDataType, oldPwHash: String, newPwHash: String) -> Result<Void, Error>
    func verifyPasscode(for account: AccountDataType, pwHash: String) -> Result<Void, Error>
    func verifyIdentitiesAndAccounts(pwHash: String) -> [(IdentityDataType?, [AccountDataType])]
    func signMessage(for account: AccountDataType, message: String, requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<StringMessageSignatures, Error>
}

enum MobileWalletError: Error {
    case invalidArgument
}

// swiftlint:disable type_body_length
class MobileWallet: MobileWalletProtocol {
    private let walletFacade = MobileWalletFacade()

    private let storageManager: StorageManagerProtocol
    private let keychain: KeychainWrapperProtocol

    init(storageManager: StorageManagerProtocol, keychain: KeychainWrapperProtocol) {
        self.storageManager = storageManager
        self.keychain = keychain
    }

    func getAccountAddressesForIdentity(global: GlobalWrapper,
                                        identityObject: IdentityObject,
                                        privateIDObjectData: PrivateIDObjectData,
                                        startingFrom: Int,
                                        pwHash: String) throws -> Result<[MakeGenerateAccountsResponseElement], Error> {
        let generateAccountsRequest = MakeGenerateAaccountsRequest(identityObject: identityObject,
                                                                   privateIDObjectData: privateIDObjectData,
                                                                   global: global.value)
        guard let input = try generateAccountsRequest.jsonString(),
            let responseData = try walletFacade.generateAccounts(input: input).data(using: .utf8)
            else {
            return .failure(GeneralError.unexpectedNullValue)
        }

        let response = try JSONDecoder().decode([MakeGenerateAccountsResponseElement].self, from: responseData)
        return .success(response)
    }
    
    func check(accountAddress: String) -> Bool {
        walletFacade.checkAccountAddress(input: accountAddress)
    }

    /// Creates an identity request and the associated private data.
    /// The private data is stored securely.
    func createIdRequestAndPrivateData(initialAccountName: String,
                                       identityName: String,
                                       identityProvider: IdentityProviderDataType,
                                       global: GlobalWrapper,
                                       requestPasswordDelegate: RequestPasswordDelegate)
                    -> AnyPublisher<(IDObjectRequestWrapper, IdentityCreation), Error> {
        do {
            guard let ipInfo = identityProvider.ipInfo, let arsInfo = identityProvider.arsInfos,
                let input = try CreateIDRequest(ipInfo: ipInfo, arsInfos: arsInfo, global: global.value).jsonString() else {
                return .fail(MobileWalletError.invalidArgument)
            }

            let idRequestString = try walletFacade.createIdRequestAndPrivateData(input: input)
            
            Logger.debug(idRequestString)
            
            let data = try IDRequestAndPrivateData(idRequestString)
            return requestPasswordDelegate.requestUserPassword(keychain: keychain)
                .tryMap { [unowned self] (pwHash) in
                    let identityCreation = try IdentityCreation(initialAccountName: initialAccountName,
                                                            identityName: identityName,
                                                            identityProvider: identityProvider,
                                                            data: data,
                                                            pwHash: pwHash,
                                                            storageManager: self.storageManager)
                    return (data.idObjectRequest, identityCreation)
                }.eraseToAnyPublisher()
        } catch {
            return .fail(error)
        }
    }

    func createCredential(global: GlobalWrapper, account: AccountDataType, pwHash: String, expiry: Date)
        -> AnyPublisher<CreateCredentialRequest, Error> {
            let revealedAttributes = account.revealedAttributes.map({
                $0.key
            })

            return self.createCredential(global: global,
                                          account: account,
                                          revealedAttributes: revealedAttributes,
                                          pwHash: pwHash,
                                          expiry: expiry).publisher.eraseToAnyPublisher()
           
    }

    private func createCredential(global: GlobalWrapper, account: AccountDataType, revealedAttributes: [String], pwHash: String, expiry: Date)
                    -> Result<CreateCredentialRequest, Error> {
        guard let identityData = account.identity,
              let privateIdObjectDataKey = identityData.encryptedPrivateIdObjectData,
              let identityObject = identityData.identityObject,
              let ipInfo = identityData.identityProvider?.ipInfo,
              let arsInfo = identityData.identityProvider?.arsInfos
                else {
            return .failure(GeneralError.unexpectedNullValue)
        }
        do {
            let privateIdObjectData = try self.getPrivateIdObjectData(privateIdObjectDataKey: privateIdObjectDataKey, pwHash: pwHash).get()
            let accountNumber = try self.storageManager.getNextAccountNumber(for: identityData).get()
            
            return self.createCredential(for: account,
                                         input: MakeCreateCredentialRequest(ipInfo: ipInfo,
                                                                            arsInfos: arsInfo,
                                                                            global: global.value,
                                                                            identityObject: identityObject,
                                                                            privateIDObjectData: privateIdObjectData,
                                                                            revealedAttributes: revealedAttributes,
                                                                            accountNumber: accountNumber,
                                                                            expiry: Int(expiry.timeIntervalSince1970)),
                                         pwHash: pwHash)
        } catch {
            return .failure(error)
        }
    }
    
    func createAccountTransfer(input: String) throws -> String {
        try walletFacade.createAccountTransaction(input: input)
    }

    func createTransfer(from fromAccount: AccountDataType,
                        to toAccount: String?,
                        amount: String?,
                        nonce: Int,
                        memo: String?,
                        capital: String?,
                        restakeEarnings: Bool?,
                        delegationTarget: DelegationTarget?,
                        openStatus: String?,
                        metadataURL: String?,
                        transactionFeeCommission: Double?,
                        bakingRewardCommission: Double?,
                        finalizationRewardCommission: Double?,
                        bakerKeys: GeneratedBakerKeys?,
                        expiry: Date,
                        energy: Int,
                        transferType: TransferType,
                        requestPasswordDelegate: RequestPasswordDelegate,
                        global: GlobalWrapper?,
                        inputEncryptedAmount: InputEncryptedAmount? = nil,
                        receiverPublicKey: String? = nil,
                        payload: Payload? = nil
    )
                    -> AnyPublisher<CreateTransferRequest, Error> {
        requestPasswordDelegate.requestUserPassword(keychain: keychain).tryMap { (pwHash: String) in
            try self.createTransfer(fromAccount: fromAccount,
                                    toAccount: toAccount,
                                    expiry: expiry,
                                    amount: amount,
                                    nonce: nonce,
                                    memo: memo,
                                    capital: capital,
                                    restakeEarnings: restakeEarnings,
                                    delegationTarget: delegationTarget,
                                    openStatus: openStatus,
                                    metadataURL: metadataURL,
                                    transactionFeeCommission: transactionFeeCommission,
                                    bakingRewardCommission: bakingRewardCommission,
                                    finalizationRewardCommission: finalizationRewardCommission,
                                    bakerKeys: bakerKeys,
                                    energy: energy,
                                    transferType: transferType,
                                    pwHash: pwHash,
                                    global: global,
                                    inputEncryptedAmount: inputEncryptedAmount,
                                    receiverPublicKey: receiverPublicKey,
                                    payload: payload
            )
        }.eraseToAnyPublisher()
    }

    private func createTransfer(fromAccount: AccountDataType,
                                toAccount: String?,
                                expiry: Date,
                                amount: String?,
                                nonce: Int,
                                memo: String?,
                                capital: String?,
                                restakeEarnings: Bool?,
                                delegationTarget: DelegationTarget?,
                                openStatus: String?,
                                metadataURL: String?,
                                transactionFeeCommission: Double?,
                                bakingRewardCommission: Double?,
                                finalizationRewardCommission: Double?,
                                bakerKeys: GeneratedBakerKeys?,
                                energy: Int,
                                transferType: TransferType,
                                pwHash: String,
                                global: GlobalWrapper? = nil,
                                inputEncryptedAmount: InputEncryptedAmount? = nil,
                                receiverPublicKey: String? = nil,
                                payload: Payload? = nil
    ) throws -> CreateTransferRequest {
        let privateAccountKeys = try getPrivateAccountKeys(for: fromAccount, pwHash: pwHash).get()
        
        var secretEncryptionKey: String?
        var type: String? = nil
        if transferType == .transferToPublic || transferType == .encryptedTransfer {
            secretEncryptionKey = try getSecretEncryptionKey(for: fromAccount, pwHash: pwHash).get()
        }
        if transferType == .contractUpdate {
            type = "Update"
        }

        let makeCreateTransferRequest = MakeCreateTransferRequest(
            from: fromAccount.address,
            to: toAccount,
            expiry: Int(expiry.timeIntervalSince1970),
            nonce: nonce,
            memo: memo,
            capital: capital,
            restakeEarnings: restakeEarnings,
            delegationTarget: delegationTarget,
            openStatus: openStatus,
            metadataURL: metadataURL,
            transactionFeeCommission: transactionFeeCommission?.string,
            bakingRewardCommission: bakingRewardCommission?.string,
            finalizationRewardCommission: finalizationRewardCommission?.string,
            bakerKeys: bakerKeys,
            keys: privateAccountKeys,
            energy: energy,
            amount: amount,
            global: global?.value,
            senderSecretKey: secretEncryptionKey,
            inputEncryptedAmount: inputEncryptedAmount,
            receiverPublicKey: receiverPublicKey,
            type: type,
            payload: payload
        )

        guard let input = try makeCreateTransferRequest.jsonString() else {
            throw MobileWalletError.invalidArgument
        }
        
        switch transferType {
        case .simpleTransfer:
            return try CreateTransferRequest(walletFacade.createTransfer(input: input))
        case .transferToSecret:
            return try CreateTransferRequest(walletFacade.createShielding(input: input))
        case .transferToPublic:
             return try CreateTransferRequest(walletFacade.createUnshielding(input: input))
        case .encryptedTransfer:
             return try CreateTransferRequest(walletFacade.createEncrypted(input: input))
        case .registerDelegation, .removeDelegation, .updateDelegation:
            return try CreateTransferRequest(walletFacade.createConfigureDelegation(input: input))
        case .registerBaker, .updateBakerKeys, .updateBakerPool, .updateBakerStake, .removeBaker, .configureBaker:
            return try CreateTransferRequest(walletFacade.createConfigureBaker(input: input))
        case .contractUpdate:
            return try CreateTransferRequest(walletFacade.createAccountTransaction(input: input))
        }
    }

    private func createCredential(for pAccount: AccountDataType, input: MakeCreateCredentialRequest, pwHash: String)
                    -> Result<CreateCredentialRequest, Error> {
        var account = pAccount
        do {
            guard let input = try input.jsonString() else {
                fatalError("Cannot create json string from model")
            }

            let credentialResponse = try walletFacade.createCredential(input: input)
            let data = try CreateCredentialRequest(credentialResponse)
            
            // swiftlint:disable line_length
            account.encryptedCommitmentsRandomness = try self.storageManager.storeCommitmentsRandomness(data.commitmentsRandomness, pwHash: pwHash).get()
            account.encryptedAccountData = try self.storageManager.storePrivateAccountKeys(data.accountKeys, pwHash: pwHash).get()
            account.encryptedPrivateKey = try self.storageManager.storePrivateEncryptionKey(data.encryptionSecretKey, pwHash: pwHash).get()
            
            return .success(data.with())
        } catch {
            return .failure(error)
        }
    }
    
    func signMessage(for account: AccountDataType, message: String, requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<StringMessageSignatures, Error> {
        return requestPasswordDelegate.requestUserPassword(keychain: keychain).tryMap { (pwHash: String) in
            let privateAccountKeys = try self.getPrivateAccountKeys(for: account, pwHash: pwHash).get()
            let res = try self.walletFacade.signMessage(input: SignMessagePayloadToJsonInput(message: message, address: account.address, keys: privateAccountKeys))
            return try JSONDecoder().decode(StringMessageSignatures.self, from: Data(res.utf8))
        }
        .eraseToAnyPublisher()
    }
    
    func generateBakerKeys() -> Result<GeneratedBakerKeys, Error> {
        return Result { try GeneratedBakerKeys(try walletFacade.generateBakerKeys()) }
    }
    
    private func getCommitmentsRandomness(for account: AccountDataType, pwHash: String) -> Result<CommitmentsRandomness, Error> {
        guard let key = account.encryptedCommitmentsRandomness else { return .failure(MobileWalletError.invalidArgument) }
        return storageManager.getCommitmentsRandomness(key: key, pwHash: pwHash)
            .mapError { $0 as Error }
    }

    private func getPrivateAccountKeys(for account: AccountDataType, pwHash: String) -> Result<AccountKeys, Error> {
        guard let key = account.encryptedAccountData else { return .failure(MobileWalletError.invalidArgument) }
        return storageManager.getPrivateAccountKeys(key: key, pwHash: pwHash)
                .mapError { $0 as Error }
    }

    private func getSecretEncryptionKey(for account: AccountDataType, pwHash: String) -> Result<String, Error> {
        guard let key = account.encryptedPrivateKey else { return .failure(MobileWalletError.invalidArgument) }
        return storageManager.getPrivateEncryptionKey(key: key, pwHash: pwHash)
            .mapError { $0 as Error }
    }
    
    private func getPrivateIdObjectData(privateIdObjectDataKey: String, pwHash: String) -> Result<PrivateIDObjectData, Error> {
        storageManager.getPrivateIdObjectData(key: privateIdObjectDataKey, pwHash: pwHash)
                .mapError { $0 as Error }
    }
    
    func decryptEncryptedAmounts(from fromAccount: AccountDataType, _ encryptedAmounts: [String],
                                 requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<[(String, Int)], Error> {
        requestPasswordDelegate.requestUserPassword(keychain: keychain)
            .flatMap { (pwHash) -> AnyPublisher<[(String, Int)], Error> in
                self.performDecryption(from: fromAccount, encryptedAmounts, pwHash: pwHash)
        }.eraseToAnyPublisher()
    }
    
    private func performDecryption(from fromAccount: AccountDataType, _ encryptedAmounts: [String],
                                   pwHash: String) ->  AnyPublisher<[(String, Int)], Error> {
        do {
            let secretEncryptionKey = try self.getSecretEncryptionKey(for: fromAccount, pwHash: pwHash).get()
            
            let decryptedValues = try encryptedAmounts.map { (encryptedAmount) -> (String, Int) in
                let makeDecryptionRequest = MakeDecryptAmountRequest(encryptedAmount: encryptedAmount, encryptionSecretKey: secretEncryptionKey)
                guard let input = try makeDecryptionRequest.jsonString() else {
                    throw MobileWalletError.invalidArgument
                }
                let decryptedValue = try self.walletFacade.decryptEncryptedAmount(input: input)
                return (encryptedAmount, decryptedValue)
            }
            return .just(decryptedValues)
        } catch {
            return .fail(error)
        }
    }

    func combineEncryptedAmount(_ encryptedAmount1: String, _ encryptedAmount2: String) -> Result<String, Error> {
        do {
            let encodedEncryptedAmount1 = "\"\(encryptedAmount1)\""
            let encodedEncryptedAmount2 = "\"\(encryptedAmount2)\""
            let sumEncrypted = try self.walletFacade.combineEncryptedAmounts(input1: encodedEncryptedAmount1, input2: encodedEncryptedAmount2)
            
            let startIndex = sumEncrypted.index(sumEncrypted.startIndex, offsetBy: 1)
            let endIndex = sumEncrypted.index(sumEncrypted.startIndex, offsetBy: sumEncrypted.count - 1)
            let decodedSumEncrypted = String(sumEncrypted[startIndex..<endIndex])
            return Result.success(decodedSumEncrypted)
        } catch {
            return Result.failure(error)
        }
    }
    
    func updatePasscode(for account: AccountDataType, oldPwHash: String, newPwHash: String) -> Result<Void, Error> {
        do {
            let secretEncryptionKeyValue = try getSecretEncryptionKey(for: account, pwHash: oldPwHash).get()
            try storageManager.updatePrivateEncryptionKeyPasscode(for: account, privateKey: secretEncryptionKeyValue, pwHash: newPwHash).get()
            
            let privateAccountKeys = try getPrivateAccountKeys(for: account, pwHash: oldPwHash).get()
            try storageManager.updatePrivateAccountDataPasscode(for: account, accountData: privateAccountKeys, pwHash: newPwHash).get()
            
            if let commitmentsRandomness = try? getCommitmentsRandomness(for: account, pwHash: oldPwHash).get() {
                try? storageManager.updateCommitmentsRandomnessPasscode(for: account, commitmentsRandomness: commitmentsRandomness, pwHash: oldPwHash).get()
            }

            if let privateIdKey = account.identity?.encryptedPrivateIdObjectData {
                self.getPrivateIdObjectData(privateIdObjectDataKey: privateIdKey, pwHash: oldPwHash)
                    .onSuccess({ (privateIDObjectData) in
                        self.storageManager.storePrivateIdObjectData(privateIDObjectData, pwHash: newPwHash).onSuccess {
                            _ = account.identity?.withUpdated(encryptedPrivateIdObjectData: $0)
                        }
                    })
            }
            
            return Result.success(Void())
        } catch {
            return Result.failure(error)
        }
    }

    func verifyPasscode(for account: AccountDataType, pwHash: String) -> Result<Void, Error> {
        do {
            _ = try getSecretEncryptionKey(for: account, pwHash: pwHash).get()
            _ = try getPrivateAccountKeys(for: account, pwHash: pwHash).get()
            _ = try? getCommitmentsRandomness(for: account, pwHash: pwHash).get()
            return Result.success(Void())
        } catch {
            return Result.failure(error)
        }
    }
    
    func verifyIdentitiesAndAccounts(pwHash: String) -> [(IdentityDataType?, [AccountDataType])] {
        
        var report: [(IdentityDataType?, [AccountDataType])] = []
        
        // the identity is invalid if the privateIdObjectData cannot be retrieved from storage
        let allIdentities = storageManager.getIdentities()
        let invalidIdentities = allIdentities.filter { identity in
            isInvalidIdentity(identity, pwHash: pwHash)
        }
        for identity in allIdentities {
            let identityAccounts = storageManager.getAccounts(for: identity)
            let invalidAccountNames = identityAccounts.filter {
                let result = verifyPasscode(for: $0, pwHash: pwHash)
                if case Result.success(_) = result {
                    return false
                } else {
                    return true
                }
            }
            // we add to the report invalid identities (even if their accounts are valid) and valid identities with invalid accounts
            if(invalidIdentities.contains(where: { $0.identityObject?.preIdentityObject.pubInfoForIP.idCredPub  == identity.identityObject?.preIdentityObject.pubInfoForIP.idCredPub }) || invalidAccountNames.count > 0) {
                report.append((identity, invalidAccountNames))
            }
        }
        
        // we add to the report any dangling accounts
        let allAccounts = storageManager.getAccounts()
        let invalidAccounts = allAccounts.filter {
            return (try? verifyPasscode(for: $0, pwHash: pwHash).get()) == nil
        }
        for account in invalidAccounts where account.identity == nil {
            report.append((nil, [account]))
        }

        return report
    }
    
    private func isInvalidIdentity(_ identity: IdentityDataType, pwHash: String) -> Bool {
        if identity.seedIdentityObject != nil {
            return false
        } else {
            if let key = identity.encryptedPrivateIdObjectData,
                (try? storageManager.getPrivateIdObjectData(key: key, pwHash: pwHash).get()) != nil {
                return false // it is not invalid because we have privateIdObjectData
            }
            return true // invalid becaut privateIdObjectData could not be retrieved
        }
    }
    
    func parameterToJson(with contractParams: ContractUpdateParameterToJsonInput) throws -> String {
        try walletFacade.parameterToJson(input: contractParams)
    }
}
