//
// Created by Concordium on 13/02/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

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
                        to toAccount: String,
                        amount: Int, nonce: AccNonce,
                        expiry: Date, energy: Int,
                        transferType: TransferType,
                        requestPasswordDelegate: RequestPasswordDelegate,
                        global: GlobalWrapper?, inputEncryptedAmount: InputEncryptedAmount?,
                        receiverPublicKey: String?) -> AnyPublisher<CreateTransferRequest, Error>

    func decryptEncryptedAmounts(from fromAccount: AccountDataType,
                                 _ encryptedAmounts: [String],
                                 requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<[(String, Int)], Error>
    
    func combineEncryptedAmount(_ encryptedAmount1: String, _ encryptedAmount2: String) -> Result<String, Error>
    
    func getAccountAddressesForIdentity(global: GlobalWrapper,
                                        identityObject: IdentityObject,
                                        privateIDObjectData: PrivateIDObjectData,
                                        startingFrom: Int,
                                        pwHash: String) throws -> Result<[MakeGenerateAccountsResponseElement], Error>
    
    func updatePasscode(for account: AccountDataType, oldPwHash: String, newPwHash: String) -> Result<Void, Error>
    func verifyPasscode(for account: AccountDataType, pwHash: String) -> Result<Void, Error>
}

enum MobileWalletError: Error {
    case invalidArgument
}

final class IdentityCreation {
    /// Identifier used in the callback to identify this identity creation
    let id = NSUUID().uuidString
    /// Name of the initial account
    let initialAccountName: String
    /// Address of the initial account
    let initialAccountAddress: String
    /// Name of the identity
    let identityName: String
    /// Key for the stored account data object
    let encryptedAccountData: String
    /// Key for the stored private key
    let encryptedPrivateKey: String
    /// Key for the stored private ID object data
    let encryptedPrivateIdObjectData: String
    /// The identity provider used in creating the identity
    let identityProvider: IdentityProviderDataType
    
    private let storageManager: StorageManagerProtocol
    
    init (initialAccountName: String,
          initialAccountAddress: String,
          identityName: String,
          encryptedAccountData: String,
          encryptedPrivateKey: String,
          encryptedPrivateIdObjectData: String,
          identityProvider: IdentityProviderDataType,
          storageManager: StorageManagerProtocol) {
        self.initialAccountName = initialAccountName
        self.initialAccountAddress = initialAccountAddress
        self.identityName = identityName
        self.encryptedAccountData = encryptedAccountData
        self.encryptedPrivateKey = encryptedPrivateKey
        self.encryptedPrivateIdObjectData = encryptedPrivateIdObjectData
        self.identityProvider = identityProvider
        self.storageManager = storageManager
    }
    convenience init (initialAccountName: String,
                      identityName: String,
                      identityProvider: IdentityProviderDataType,
                      data: IDRequestAndPrivateData,
                      pwHash: String,
                      storageManager: StorageManagerProtocol) throws {
        let encryptedAccountData = try storageManager.storePrivateAccountKeys(data.initialAccountData.accountKeys,
                                                                              pwHash: pwHash).get()
        let encryptedPrivateKey = try storageManager.storePrivateEncryptionKey(data.initialAccountData.encryptionSecretKey,
                                                                               pwHash: pwHash).get()
        let encryptedPrivateIdObjectData =
            try storageManager.storePrivateIdObjectData(data.privateIDObjectData.value, pwHash: pwHash).get()
        
        self.init(initialAccountName: initialAccountName,
                  initialAccountAddress: data.initialAccountData.accountAddress,
                  identityName: identityName,
                  encryptedAccountData: encryptedAccountData,
                  encryptedPrivateKey: encryptedPrivateKey,
                  encryptedPrivateIdObjectData: encryptedPrivateIdObjectData,
                  identityProvider: identityProvider,
                  storageManager: storageManager)

    }
    deinit {
        // Clean up the encrypted data from the keyring, but only if the associated account
        // and identity were not created.
        guard storageManager.getAccount(withAddress: self.initialAccountAddress) == nil else { return }
        let matchingIdentity = storageManager.getIdentities().first {
            $0.encryptedPrivateIdObjectData == self.encryptedPrivateIdObjectData
        }
        guard matchingIdentity == nil else { return }
        storageManager.removePrivateAccountKeys(key: encryptedAccountData)
        storageManager.removePrivateEncryptionKey(key: encryptedPrivateKey)
        storageManager.removePrivateIdObjectData(key: encryptedPrivateIdObjectData)
    }
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
                .tryMap { (pwHash) in
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
    
//            return requestPasswordDelegate.requestUserPassword(keychain: keychain)
//            .flatMap { (pwHash) -> AnyPublisher<CreateCredentialRequest, Error> in
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

    func createTransfer(from fromAccount: AccountDataType,
                        to toAccount: String,
                        amount: Int,
                        nonce: AccNonce,
                        expiry: Date,
                        energy: Int,
                        transferType: TransferType,
                        requestPasswordDelegate: RequestPasswordDelegate,
                        global: GlobalWrapper?,
                        inputEncryptedAmount: InputEncryptedAmount? = nil,
                        receiverPublicKey: String? = nil)
                    -> AnyPublisher<CreateTransferRequest, Error> {
        requestPasswordDelegate.requestUserPassword(keychain: keychain).tryMap { (pwHash: String) in
            try self.createTransfer(fromAccount: fromAccount,
                                    toAccount: toAccount,
                                    expiry: expiry,
                                    amount: amount,
                                    nonce: nonce,
                                    energy: energy,
                                    transferType: transferType,
                                    pwHash: pwHash,
                                    global: global,
                                    inputEncryptedAmount: inputEncryptedAmount,
                                    receiverPublicKey: receiverPublicKey)
        }.eraseToAnyPublisher()
    }

    private func createTransfer(fromAccount: AccountDataType,
                                toAccount: String,
                                expiry: Date,
                                amount: Int,
                                nonce: AccNonce,
                                energy: Int,
                                transferType: TransferType,
                                pwHash: String,
                                global: GlobalWrapper? = nil,
                                inputEncryptedAmount: InputEncryptedAmount? = nil,
                                receiverPublicKey: String? = nil
                                
    ) throws -> CreateTransferRequest {
        let privateAccountKeys = try getPrivateAccountKeys(for: fromAccount, pwHash: pwHash).get()
        
        var secretEncryptionKey: String?
        if transferType == .transferToPublic || transferType == .encryptedTransfer {
            secretEncryptionKey = try getSecretEncryptionKey(for: fromAccount, pwHash: pwHash).get()
        }
        let makeCreateTransferRequest = MakeCreateTransferRequest(from: fromAccount.address,
                                                                  to: toAccount,
                                                                  expiry: Int(expiry.timeIntervalSince1970),
                                                                  nonce: nonce.nonce,
                                                                  keys: privateAccountKeys,
                                                                  energy: energy,
                                                                  amount: String(amount),
                                                                  global: global?.value,
                                                                  senderSecretKey: secretEncryptionKey,
                                                                  inputEncryptedAmount: inputEncryptedAmount,
                                                                  receiverPublicKey: receiverPublicKey)
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
            
            let commitmentsRandomness = try getCommitmentsRandomness(for: account, pwHash: oldPwHash).get()
            try storageManager.updateCommitmentsRandomnessPasscode(for: account, commitmentsRandomness: commitmentsRandomness, pwHash: oldPwHash).get()

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
            _ = try getCommitmentsRandomness(for: account, pwHash: pwHash).get()
            return Result.success(Void())
        } catch {
            return Result.failure(error)
        }
    }
}
