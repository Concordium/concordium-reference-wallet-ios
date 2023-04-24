//
// Created by Concordium on 19/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

protocol AccountsServiceProtocol {
    func getGlobal() -> AnyPublisher<GlobalWrapper, Error>
    func submitCredential(_ credential: Credential) -> AnyPublisher<SubmissionResponse, Error>
    func getState(for account: AccountDataType) -> AnyPublisher<AccountSubmissionStatus, Error>
    func createAccount(account pAccount: AccountDataType, requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<AccountDataType, Error>
    func updateAccountsBalances(accounts: [AccountDataType]) -> AnyPublisher<[AccountDataType], Error>
    func updateAccountBalancesAndDecryptIfNeeded(account: AccountDataType,
                                                 balanceType: AccountBalanceTypeEnum,
                                                 requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<AccountDataType, Error>
    func recalculateAccountBalance(account: AccountDataType, balanceType: AccountBalanceTypeEnum) -> AnyPublisher<AccountDataType, Error>
    func gtuDrop(for accountAddress: String) -> AnyPublisher<TransferDataType, Error>
    func checkAccountExistance(accounts: [String]) -> AnyPublisher<[String], Error>
    func getLocalTransferWithUpdatedStatus(transfer: TransferDataType, for account: AccountDataType) -> AnyPublisher<TransferDataType, Error>
}

// swiftlint:disable type_body_length
class AccountsService: AccountsServiceProtocol, SubmissionStatusService {
    
    var networkManager: NetworkManagerProtocol
    private let mobileWallet: MobileWalletProtocol
    private var storageManager: StorageManagerProtocol
    private var keychain: KeychainWrapperProtocol
    
    var cancelables: [AnyCancellable] = []
    
    init(networkManager: NetworkManagerProtocol,
         mobileWallet: MobileWalletProtocol,
         storageManager: StorageManagerProtocol,
         keychain: KeychainWrapperProtocol) {
        self.networkManager = networkManager
        self.mobileWallet = mobileWallet
        self.storageManager = storageManager
        self.keychain = keychain
    }
    
    func getGlobal() -> AnyPublisher<GlobalWrapper, Error> {
        networkManager.load(ResourceRequest(url: ApiConstants.global))
    }
    
    func submitCredential(_ credential: Credential) -> AnyPublisher<SubmissionResponse, Error> {
        
        let data: Data? = try? credential.jsonData()
        return networkManager.load(ResourceRequest(url: ApiConstants.submitCredential, httpMethod: .put, body: data))
    }
    
    func getState(for account: AccountDataType) -> AnyPublisher<AccountSubmissionStatus, Error> {
        if let transactionStatus = account.transactionStatus,
            case SubmissionStatusEnum.finalized = transactionStatus {
            return .just(AccountSubmissionStatus(status: .finalized, account: account))
        }
        if let transactionStatus = account.transactionStatus,
            case SubmissionStatusEnum.absent = transactionStatus {
            return .just(AccountSubmissionStatus(status: .absent, account: account))
        }
        
        guard let submissionId = account.submissionId else {
            return .empty()
        }
        
        return submissionStatus(submissionId: submissionId)
            .map { AccountSubmissionStatus(status: $0.status, account: account) }
            .handleEvents(receiveOutput: { data in
                _ = account.write {
                    var account = $0
                    account.transactionStatus = data.status
                }
                if data.status == .finalized {
                    let recipientEntity = RecipientEntity(name: account.displayName, address: account.address)
                    do {
                        try self.storageManager.storeRecipient(recipientEntity)
                    } catch {}
                }
            })
            .eraseToAnyPublisher()
    }

    // swiftlint:disable function_body_length
    func createAccount(account pAccount: AccountDataType, requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<AccountDataType, Error> {
        
        var account = pAccount
        guard let identityObject = account.identity?.identityObject,
            let privateIdKey = account.identity?.encryptedPrivateIdObjectData else {
                return .fail(GeneralError.unexpectedNullValue)
        }
        
        let globalAndPasswordPublisher = Publishers.Zip(getGlobal(), requestPasswordDelegate.requestUserPassword(keychain: keychain)).map({ tuple  in
            return tuple
        }).eraseToAnyPublisher()
        
        let noncePublisher = globalAndPasswordPublisher.flatMap { (global, pwHash) -> AnyPublisher<[String], Error> in
            do {
                let privateIDObjectData = try self.storageManager.getPrivateIdObjectData(key: privateIdKey, pwHash: pwHash).get()
                let addresses = try self.mobileWallet.getAccountAddressesForIdentity(global: global,
                                                                                     identityObject: identityObject,
                                                                                     privateIDObjectData: privateIDObjectData,
                                                                                     startingFrom: pAccount.accountNonce,
                                                                                     pwHash: pwHash).get().map { $0.accountAddress }
                return self.checkAccountExistance(accounts: addresses)
                
            } catch {
                return .fail(error)
            }
        }.map { (addresses) -> Int in
            let newNonce = addresses.count
            return newNonce
        }.eraseToAnyPublisher()
        
        return
            Publishers.Zip(globalAndPasswordPublisher, noncePublisher)
                .flatMap { (arg0, nonce) -> AnyPublisher<CreateCredentialRequest, Error> in
                    let (global, pwHash) = arg0
                    _ = account.identity?.withUpdated(accountsCreated: nonce)
                    if nonce > account.identity?.identityObject?.attributeList.maxAccounts ?? 200 {
                        return .fail(ViewError.simpleError(localizedReason: "createAccount.tooManyAccounts".localized))
                    }
                    let timeout: TimeInterval = 60 * 10
                    let expiry = Date(timeIntervalSinceNow: timeout)
                    return self.mobileWallet.createCredential(global: global, account: account, pwHash: pwHash, expiry: expiry)
            }.flatMap { (createCredential: CreateCredentialRequest) -> AnyPublisher<SubmissionResponse, Error> in
                account.address = createCredential.accountAddress
                account.credential = createCredential.credential
                return self.submitCredential(createCredential.credential)
            }.flatMap { (submissionId: SubmissionResponse) -> AnyPublisher<SubmissionStatus, Error> in
                account.submissionId = submissionId.submissionID
                return self.submissionStatus(submissionId: submissionId.submissionID)
            }.map { (submissionStatus: SubmissionStatus) -> AccountDataType in
                account.transactionStatus = submissionStatus.status
                let shieldedAmount = ShieldedAmountTypeFactory.create().withInitialValue(for: account)
                _ = try? self.storageManager.storeShieldedAmount(amount: shieldedAmount)
                return account
            }
            .eraseToAnyPublisher()
    }
    
    func updateAccountBalancesAndDecryptIfNeeded(account: AccountDataType,
                                                 balanceType: AccountBalanceTypeEnum,
                                                 requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<AccountDataType, Error> {
        getAccountWithUpdatedFinalizedBalance(account: account,
                                              balanceType: balanceType,
                                              withDecryption: true,
                                              requestPasswordDelegate: requestPasswordDelegate)
            .flatMap(self.addingBalanceEffectFromTransfers)
            .eraseToAnyPublisher()
        
    }
    
    func updateAccountsBalances(accounts: [AccountDataType]) -> AnyPublisher<[AccountDataType], Error> {
        let updatedAccounts = accounts
            .map { (account: AccountDataType) -> AnyPublisher<AccountDataType, Error> in
                getAccountWithUpdatedFinalizedBalance(account: account)
                    .flatMap(self.addingBalanceEffectFromTransfers)
                    .eraseToAnyPublisher()
        }
        
        // convert [Publisher<Account>] to Publisher<[Account]>
        return Publishers.Sequence<[AnyPublisher<AccountDataType, Error>], Error>(sequence: updatedAccounts)
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func checkAccountExistance(accounts accountAddresses: [String]) -> AnyPublisher<[String], Error> {
        let publishers = accountAddresses.map { (address) -> AnyPublisher<String, Error> in
            if let account = storageManager.getAccount(withAddress: address) {
                if account.transactionStatus != SubmissionStatusEnum.absent {
                    return .just(address)
                } else {
                    // cleanup locally
                    storageManager.removeAccount(account: account)
                }
            }
            
            return getAccountBalance(for: address).tryMap { (accountBalance) -> String in
                if accountBalance.currentBalance == nil && accountBalance.finalizedBalance == nil {
                    return ""
                }
                return address
            }.eraseToAnyPublisher()
        }
        return chain(accounts: [], publishers: publishers)
    }
    
    func chain(accounts: [String], publishers: [AnyPublisher<String, Error>]) -> AnyPublisher<[String], Error> {
        if publishers.count == 0 {
            return .just(accounts)
        }
        var mutablePublishers = publishers
        let firstPublisher = mutablePublishers.removeFirst()
        return firstPublisher.flatMap { (account) -> AnyPublisher<[String], Error> in
            if account == "" {
                return .just(accounts)
            }
            var newAccounts = accounts
            newAccounts.append(account)
            return self.chain(accounts: newAccounts, publishers: mutablePublishers)
        }.eraseToAnyPublisher()
    }
    
    func recalculateAccountBalance(account: AccountDataType, balanceType: AccountBalanceTypeEnum) -> AnyPublisher<AccountDataType, Error> {
        getAccountWithUpdatedFinalizedBalance(account: account, balanceType: balanceType)
            .flatMap(self.addingBalanceEffectFromTransfersNoRefresh)
            .eraseToAnyPublisher()
        
    }
    
    func gtuDrop(for accountAddress: String) -> AnyPublisher<TransferDataType, Error> {
        var transfer = TransferDataTypeFactory.create()
        let expectedGTUDropAmount = "-2000"
        transfer.amount = String(GTU(displayValue: expectedGTUDropAmount).intValue)
        transfer.toAddress = accountAddress
        transfer.transferType = .simpleTransfer
        
        return networkManager
            .load(ResourceRequest(url: ApiConstants.gtuDrop.appendingPathComponent(accountAddress), httpMethod: .put))
            .flatMap { (submissionResponse: SubmissionResponse) -> AnyPublisher<SubmissionStatus, Error> in
                transfer.submissionId = submissionResponse.submissionID
                return self.submissionStatus(submissionId: submissionResponse.submissionID)
        }.map { (submissionStatus: SubmissionStatus) -> TransferDataType in
            transfer.transactionStatus = submissionStatus.status
            transfer.outcome = submissionStatus.outcome
            return transfer
        }.tryMap { transfer in
            try self.storageManager.storeTransfer(transfer)
        }
        .eraseToAnyPublisher()
    }
    
    private func addingBalanceEffectFromTransfersNoRefresh(for account: AccountDataType) -> AnyPublisher<AccountDataType, Error> {
        let transfers: [TransferDataType] = self.storageManager.getTransfers(for: account.address).filter { (transfer) -> Bool in
            if transfer.nonce >= account.accountNonce {
                return true
            } else {
                return false
            }
        }
        let balanceChangeArray: [AnyPublisher<(Int, Int), Error>] = transfers.map { transfer -> AnyPublisher<(Int, Int), Error> in
            return .just((transfer.getPublicBalanceChange(), transfer.getShieldedBalanceChange()))
        }
        return Publishers.Sequence(sequence: balanceChangeArray)
            .flatMap { $0 }
            .reduce((0, 0)) { (acc, arg1) -> (Int, Int) in
                let (pub, shielded) = arg1
                return ((acc.0 + pub), (acc.1 + shielded))}
            .map { transferBalanceChange in
                return account.withUpdatedForecastBalance((account.finalizedBalance + transferBalanceChange.0),
                                                          forecastShieldedBalance: (account.finalizedEncryptedBalance + transferBalanceChange.1)) }
            .eraseToAnyPublisher()
    }
    
    private func addingBalanceEffectFromTransfers(for account: AccountDataType) -> AnyPublisher<AccountDataType, Error> {
        let transfers: [TransferDataType] = self.storageManager.getTransfers(for: account.address)
        let balanceChangeArray: [AnyPublisher<(Int, Int), Error>] = transfers.map { transfer in
            self.getLocalTransferWithUpdatedStatus(transfer: transfer, for: account)
                .map { ($0.getPublicBalanceChange(), $0.getShieldedBalanceChange()) }
                .eraseToAnyPublisher()
        }
        return Publishers.Sequence(sequence: balanceChangeArray)
            .flatMap { $0 }
            .reduce((0, 0)) { (acc, arg1) -> (Int, Int) in
                let (pub, shielded) = arg1
                return ((acc.0 + pub), (acc.1 + shielded))}
            .map { transferBalanceChange in
                return account.withUpdatedForecastBalance((account.finalizedBalance + transferBalanceChange.0),
                                                          forecastShieldedBalance: (account.finalizedEncryptedBalance + transferBalanceChange.1)) }
            .eraseToAnyPublisher()
    }
    
    private func decryptingIfNeeded(for account: AccountDataType) -> AnyPublisher<AccountDataType, Error> {
        if account.encryptedBalanceStatus != ShieldedAccountEncryptionStatus.decrypted {
            
        }
        return Result.Publisher(account).eraseToAnyPublisher()// Just(account)
    }
    
    private func getUnDecryptedValues(for account: AccountDataType, balance: AccountBalance) -> [String] {
        let shieldedAmounts = self.storageManager.getShieldedAmountsForAccount(account)
        
        var encryptedValues: [String] = []
        if let selfAmount = balance.finalizedBalance?.accountEncryptedAmount?.selfAmount {
            encryptedValues.append(selfAmount)
        }
        if let incomingAmounts = balance.finalizedBalance?.accountEncryptedAmount?.incomingAmounts {
            encryptedValues.append(contentsOf: incomingAmounts)
        }
        return encryptedValues.filter { (encryptedValue) -> Bool in
            !shieldedAmounts.contains { (shieldedAmount) -> Bool in
                shieldedAmount.encryptedValue == encryptedValue
            }
        }
    }
    
    func getLocalTransferWithUpdatedStatus(transfer: TransferDataType, for account: AccountDataType) -> AnyPublisher<TransferDataType, Error> {
        guard let id = transfer.submissionId else { return .just(transfer) }
        return submissionStatus(submissionId: id).compactMap { (submissionStatus) -> TransferDataType? in
            if let encryptedAmount = submissionStatus.encryptedAmount {
                let shieldedAmount = ShieldedAmountTypeFactory.create().with(account: account,
                                                                             encryptedValue: encryptedAmount,
                                                                             decryptedValue: transfer.amount,
                                                                             incomingAmountIndex: -1)
                _ = try? self.storageManager.storeShieldedAmount(amount: shieldedAmount)
            }
            if submissionStatus.status == .finalized {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.storageManager.removeTransfer(transfer)
                }
                
                return nil
            } else {
                return transfer.withUpdated(cost: submissionStatus.cost,
                                            status: submissionStatus.status,
                                            outcome: submissionStatus.outcome)
                
            }
        }.eraseToAnyPublisher()
    }
    
    private func getFinalizedShieldedAmount(balance: AccountBalance, account: AccountDataType) -> (Int, ShieldedAccountEncryptionStatus) {
        let shieldedAmounts = self.storageManager.getShieldedAmountsForAccount(account)
        
        guard let selfAmount = balance.finalizedBalance?.accountEncryptedAmount?.selfAmount else {
            // if we have no balance we assume 0
            return (0, .decrypted)
        }
        guard let firstDecryptedAmount = lookupEcryptedAmount(encryptedAmounts: [selfAmount], shieldedAmounts: shieldedAmounts).first,
            let selfAmountDecrypted = firstDecryptedAmount else {
                return (0, .encrypted)
        }
        
        // if we don't have incoming amounts, we just return the self amount and we know its value
        guard let incomingAmounts = balance.finalizedBalance?.accountEncryptedAmount?.incomingAmounts else {
            return (selfAmountDecrypted, .decrypted)
        }
        
        let decryptedIncomingAmounts = lookupEcryptedAmount(encryptedAmounts: incomingAmounts, shieldedAmounts: shieldedAmounts)
        let sum = decryptedIncomingAmounts.reduce(0, {acc, elem in
            return acc + (elem ?? 0)
        }) + selfAmountDecrypted
        let containsNil = decryptedIncomingAmounts.contains { $0 == nil }
        
        return (sum, containsNil ? .partiallyDecrypted : .decrypted )
    }
    
    private func getHasShieldedTransactions(balance: AccountBalance, account: AccountDataType ) -> Bool {
        // if we don't have incoming amounts, we just return the self amount and we know its value
        guard let incomingAmounts = balance.finalizedBalance?.accountEncryptedAmount?.incomingAmounts else {
            return false
        }
        return incomingAmounts.count > 0 ? true : false
    }
    
    private func lookupEcryptedAmount(encryptedAmounts: [String], shieldedAmounts: [ShieldedAmountType]) -> [Int?] {
        encryptedAmounts.map { (encryptedAmount) -> Int? in
            let value = shieldedAmounts.filter { $0.encryptedValue == encryptedAmount }.first
            if let value = value {
                return Int(value.decryptedValue)
            }
            return nil
        }
    }

    // swiftlint:disable line_length
    private func getAccountWithUpdatedFinalizedBalance(account: AccountDataType,
                                                       balanceType: AccountBalanceTypeEnum = .balance,
                                                       withDecryption: Bool = false, requestPasswordDelegate: RequestPasswordDelegate? = nil) -> AnyPublisher<AccountDataType, Error> {
        
        // if the account is created as an initial account in an identity
        if account.address == "" {
            return .just(account)
        }
        
        var savedBalance: AccountBalance?
        return getAccountBalance(for: account.address)
            .flatMap({ (balance: AccountBalance) -> AnyPublisher<[(String, Int)], Error> in
                savedBalance = balance
                if let passwordDelegate = requestPasswordDelegate, withDecryption, balanceType == .shielded {
                    let undecryptedValues = self.getUnDecryptedValues(for: account, balance: balance)
                    if undecryptedValues.count > 0 {
                        return self.mobileWallet.decryptEncryptedAmounts(from: account, undecryptedValues, requestPasswordDelegate: passwordDelegate)
                    }
                    
                }
                return .just([])

            }) .map({ (values) -> (AccountDataType) in
                values.map { (encryptedValue, decryptedValue) -> ShieldedAmountType in
                    ShieldedAmountTypeFactory.create().with(account: account,
                                                            encryptedValue: encryptedValue,
                                                            decryptedValue: String(decryptedValue),
                                                            incomingAmountIndex: -1)
                }.forEach { (shieldedAmount) in
                    _ = try? self.storageManager.storeShieldedAmount(amount: shieldedAmount)
                }
                
                guard let balance = savedBalance else { return account }
                let (finalizedShieldedAmount, shieldedEncryptionStatus) = self.getFinalizedShieldedAmount(balance: balance, account: account)
                let hasShieldedTransactions = self.getHasShieldedTransactions(balance: balance, account: account)
                let releaseSchedule = ReleaseScheduleEntity(from: balance.finalizedBalance?.accountReleaseSchedule)
                let delegation: DelegationDataType?
                if let accountDelegation = balance.finalizedBalance?.accountDelegation {
                    delegation = DelegationEntity(accountDelegationModel: accountDelegation)
                } else {
                    delegation = nil
                }
                let baker: BakerDataType?
                if let accountBaker = balance.finalizedBalance?.accountBaker {
                    baker = BakerEntity(accountBakerModel: accountBaker)
                } else {
                    baker = nil
                }
                
                return account.withUpdatedFinalizedBalance((Int(balance.finalizedBalance?.accountAmount ?? "0") ?? 0),
                                                           finalizedShieldedAmount,
                                                           shieldedEncryptionStatus,
                                                           EncryptedBalanceEntity(accountEncryptedAmount: balance.finalizedBalance?.accountEncryptedAmount),
                                                           hasShieldedTransactions: hasShieldedTransactions,
                                                           accountNonce: balance.finalizedBalance?.accountNonce ?? 0,
                                                           accountIndex: balance.finalizedBalance?.accountIndex ?? 0,
                                                           delegation:
                                                            delegation,
                                                           baker: baker,
                                                           releaseSchedule: releaseSchedule)
            }).eraseToAnyPublisher()
    }
    
    private func getAccountBalance(for accountAddress: String) -> AnyPublisher<AccountBalance, Error> {
        networkManager.load(ResourceRequest(url: ApiConstants.accountBalance.appendingPathComponent(accountAddress)))
    }
}
