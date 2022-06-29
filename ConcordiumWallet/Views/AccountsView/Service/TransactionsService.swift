//
// Created by Concordium on 04/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

protocol TransactionsServiceProtocol {
    func performTransfer(_ pTransfer: TransferDataType,
                         from account: AccountDataType,
                         bakerKeys: GeneratedBakerKeys?,
                         requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<TransferDataType, Error>
    func getTransactions(for account: AccountDataType, startingFrom: Transaction?) -> AnyPublisher<RemoteTransactions, Error>
    func getTransferCost(transferType: TransferType, costParameters: [TransferCostParameter]) -> AnyPublisher<TransferCost, Error>
    func decryptEncryptedTransferAmounts(transactions: [Transaction],
                                         from account: AccountDataType,
                                         requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<[(String, Int)], Error>
}

extension TransactionsServiceProtocol {
    func performTransfer(_ pTransfer: TransferDataType,
                         from account: AccountDataType,
                         requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<TransferDataType, Error> {
        return performTransfer(pTransfer, from: account, bakerKeys: nil, requestPasswordDelegate: requestPasswordDelegate)
    }
}

class TransactionsService: TransactionsServiceProtocol, SubmissionStatusService {
    var networkManager: NetworkManagerProtocol
    private let mobileWallet: MobileWalletProtocol
    private var storageManager: StorageManagerProtocol
    init(networkManager: NetworkManagerProtocol, mobileWallet: MobileWalletProtocol, storageManager: StorageManagerProtocol) {
        self.networkManager = networkManager
        self.mobileWallet = mobileWallet
        self.storageManager = storageManager
    }
    
    func performTransfer(_ pTransfer: TransferDataType,
                         from account: AccountDataType,
                         bakerKeys: GeneratedBakerKeys? = nil,
                         requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<TransferDataType, Error> {
        switch pTransfer.transferType {
        case .simpleTransfer:
            return performPublicTransfer(pTransfer, from: account, requestPasswordDelegate: requestPasswordDelegate)
        case .transferToSecret:
            return performShielding(pTransfer, from: account, requestPasswordDelegate: requestPasswordDelegate)
        case .transferToPublic:
            return performUnshielding(pTransfer, from: account, requestPasswordDelegate: requestPasswordDelegate)
        case .encryptedTransfer:
            return performEncryptedTransfer(pTransfer, from: account, requestPasswordDelegate: requestPasswordDelegate)
        case .registerBaker, .updateBakerKeys, .updateBakerPool, .updateBakerStake, .removeBaker, .configureBaker:
            return performBakerTransfer(pTransfer, from: account, bakerKeys: bakerKeys, requestPasswordDelegate: requestPasswordDelegate)
        case .registerDelegation, .removeDelegation, .updateDelegation:
            return performDelegationTransfer(pTransfer, from: account, requestPasswordDelegate: requestPasswordDelegate)
        }
    }
   
    func getTransactions(for account: AccountDataType, startingFrom: Transaction? = nil) -> AnyPublisher<RemoteTransactions, Error> {
        var params = ["order": "descending"]
        params["limit"] = "20"

        let showRewards = account.transferFilters?.showRewardTransactions ?? true
        let showFinalRewards = account.transferFilters?.showFinalRewardTransactions ?? true

        // If show all rewards, we do nothing - this is default behaviour
        // If showRewards is true, but showFinalRewards is false => includeRewards = allButFinalization
        if showRewards && !showFinalRewards {
            params["includeRewards"] = "allButFinalization"
        }
        // If showRewards and showFinalRewards are both false => includeRewards = none
        if !showRewards && !showFinalRewards {
            params["includeRewards"] = "none"
        }

        if let startingFrom = startingFrom, let id = startingFrom.id {
            params["from"] = "\(id)"
        }
        let request = ResourceRequest(url: ApiConstants.accountTransactions.appendingPathComponent(account.address),
                                      parameters: params)
        return networkManager.load(request)
    }
  
    func getTransferCost(transferType: TransferType, costParameters: [TransferCostParameter]) -> AnyPublisher<TransferCost, Error> {
        var params: [String: CustomStringConvertible?] = ["type": transferType.rawValue]
        
        costParameters.forEach { costParameter in
            params[costParameter.name] = costParameter.value
        }
        
        let request = ResourceRequest(url: ApiConstants.transferCost, parameters: params)
        return networkManager.load(request)
    }
    
    // swiftlint:disable function_body_length
    func decryptEncryptedTransferAmounts(transactions: [Transaction],
                                         from account: AccountDataType,
                                         requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<[(String, Int)], Error> {

        let receivedTransactions = transactions.filter { (transaction) -> Bool in
            transaction.origin?.type != OriginTypeEnum.typeSelf
        }
        var amounts = receivedTransactions.map {
            $0.encrypted?.encryptedAmount ?? ""
        }.filter { $0 != ""}

        // for sent transactions we remember both newSelfAmount AND inputEncryptedAmount
        // so we can decrypt them and calculated the value of the encrypted amount
        let sentTransactions = transactions.filter { (transaction) -> Bool in
            transaction.origin?.type == OriginTypeEnum.typeSelf
        }
        let selfAmounts = sentTransactions.map {
            $0.encrypted?.newSelfEncryptedAmount ?? ""
        }.filter { $0 != ""}
        let inputAmounts = sentTransactions.map {
            $0.details.inputEncryptedAmount ?? ""
        }.filter { $0 != ""}
        
        amounts.append(contentsOf: selfAmounts)
        amounts.append(contentsOf: inputAmounts)
        
        return mobileWallet.decryptEncryptedAmounts(from: account, amounts, requestPasswordDelegate: requestPasswordDelegate)
            .map { (values) -> [(String, Int)] in
                
                values.map { (encryptedValue, decryptedValue) -> ShieldedAmountType in
                    ShieldedAmountTypeFactory.create().with(account: account,
                                                            encryptedValue: encryptedValue,
                                                            decryptedValue: String(decryptedValue),
                                                            incomingAmountIndex: -1)
                }.forEach { (shieldedAmount) in
                    _ = try? self.storageManager.storeShieldedAmount(amount: shieldedAmount)
                }
                
                let calculatedencryptedValues = sentTransactions.map { (transaction) -> (String, Int) in
                    if let newSelfEncrypted = values.filter({ (encrypted, _) -> Bool in
                        encrypted == transaction.encrypted?.newSelfEncryptedAmount
                    }).first,
                    let inputAmount = values.filter({ (encrypted, _) -> Bool in
                        encrypted == transaction.details.inputEncryptedAmount
                    }).first,
                    let encryptedValue = transaction.encrypted?.encryptedAmount {
                        return (encryptedValue, (inputAmount.1 - newSelfEncrypted.1))
                        
                    } else {
                        return ("", 0)
                    }
                }
                calculatedencryptedValues.filter { $0.0 != ""}.forEach { (encryptedValue, decryptedValue) in
                    let shieldedAmount = ShieldedAmountTypeFactory.create().with(account: account,
                                                                                 encryptedValue: encryptedValue,
                                                                                 decryptedValue: String(decryptedValue),
                                                                                 incomingAmountIndex: -1)
                    _ = try? self.storageManager.storeShieldedAmount(amount: shieldedAmount)
                }
                
                return values
            }
            .eraseToAnyPublisher()
    }
}

extension TransactionsService {
    // MARK: Create transfer helpers
    private func performPublicTransfer(_ pTransfer: TransferDataType,
                                       from account: AccountDataType,
                                       requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<TransferDataType, Error> {
        var transfer = updateLocalTransferWithExpiration(pTransfer)
        return getAccountNonce(for: transfer.fromAddress)
            .flatMap { [weak self] (nonce: AccNonce) -> AnyPublisher<CreateTransferRequest, Error> in
                transfer.nonce = nonce.nonce
                guard let self = self else { return .fail(GeneralError.unexpectedNullValue) }
                return self.createTransfer(transfer,
                                    from: account,
                                    requestPasswordDelegate: requestPasswordDelegate,
                                    bakerKeys: nil,
                                    global: nil,
                                    inputEncryptedAmount: nil,
                                    receiverPublicKey: nil)
            }
            .flatMap(submitTransfer)
            .flatMap { (submissionResponse: SubmissionResponse) -> AnyPublisher<SubmissionStatus, Error> in
                transfer.submissionId = submissionResponse.submissionID
                return self.submissionStatus(submissionId: submissionResponse.submissionID)
            }.map { [weak self] in
                self?.updateLocalTransfer(transfer, withSubmissionStatus: $0) ?? transfer
            }
            .eraseToAnyPublisher()
    }

    private func performShielding(_ pTransfer: TransferDataType,
                                  from account: AccountDataType,
                                  requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<TransferDataType, Error> {
        var transfer = updateLocalTransferWithExpiration(pTransfer)
        return getAccountNonce(for: transfer.fromAddress).zip(getGlobal())
            .flatMap { [weak self] (nonce, global)  -> AnyPublisher<CreateTransferRequest, Error>  in
                transfer.nonce = nonce.nonce
                guard let self = self else { return .fail(GeneralError.unexpectedNullValue) }
                return self.createTransfer(transfer,
                                           from: account,
                                           requestPasswordDelegate: requestPasswordDelegate,
                                           bakerKeys: nil,
                                           global: global,
                                           inputEncryptedAmount: nil,
                                           receiverPublicKey: nil)
            }.map({ [weak self](transferRequest) -> CreateTransferRequest in
                // try and store the expected selfAmount, based on calculations
                transfer = self?.updateLocalTransfer(transfer, withShieldingRequest: transferRequest, forAccount: account) ?? transfer
                return transferRequest
            })
            .flatMap(submitTransfer)
            .flatMap { (submissionResponse: SubmissionResponse) -> AnyPublisher<SubmissionStatus, Error> in
                transfer.submissionId = submissionResponse.submissionID
                return self.submissionStatus(submissionId: submissionResponse.submissionID)
            }.map { [weak self] in
                self?.updateLocalTransfer(transfer, withSubmissionStatus: $0) ?? transfer
            }
            .eraseToAnyPublisher()
        
    }
    
    private func performUnshielding(_ pTransfer: TransferDataType,
                                    from account: AccountDataType,
                                    requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<TransferDataType, Error> {
        var transfer = updateLocalTransferWithExpiration(pTransfer)
        let inputEncryptedAmount = self.getInputEncryptedAmount(for: account)
        return getAccountNonce(for: transfer.fromAddress).zip(getGlobal())
            .flatMap { (nonce, global)  -> AnyPublisher<CreateTransferRequest, Error> in
                transfer.nonce = nonce.nonce
                return self.createTransfer(transfer,
                                           from: account,
                                           requestPasswordDelegate: requestPasswordDelegate,
                                           bakerKeys: nil,
                                           global: global,
                                           inputEncryptedAmount: inputEncryptedAmount,
                                           receiverPublicKey: nil)
            }.map { [weak self] (transferRequest) -> CreateTransferRequest in
                transfer = self?.updateLocalTransfer(transfer,
                                                     withUnshieldingRequest: transferRequest,
                                                     andInputEncryptedAmount: inputEncryptedAmount,
                                                     forAccount: account) ?? transfer
                return transferRequest
            }
            .flatMap(submitTransfer)
            .flatMap { [weak self] (submissionResponse: SubmissionResponse) -> AnyPublisher<SubmissionStatus, Error> in
                guard let self = self else { return .fail(GeneralError.unexpectedNullValue) }
                transfer.submissionId = submissionResponse.submissionID
                return self.submissionStatus(submissionId: submissionResponse.submissionID)
            }.map { [weak self] in
                self?.updateLocalTransfer(transfer, withSubmissionStatus: $0) ?? transfer
            }
            .eraseToAnyPublisher()
    }
    
    private func performEncryptedTransfer(_ pTransfer: TransferDataType,
                                          from account: AccountDataType,
                                          requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<TransferDataType, Error> {
        
        var transfer = updateLocalTransferWithExpiration(pTransfer)
        let inputEncryptedAmount = self.getInputEncryptedAmount(for: account)
        return getAccountNonce(for: transfer.fromAddress).zip(getGlobal(), getPublicAccountKey(for: transfer.toAddress))
            .flatMap { [weak self](nonce, global, receiverPublicKey)  -> AnyPublisher<CreateTransferRequest, Error>  in
                guard let self = self else { return .fail(GeneralError.unexpectedNullValue) }
                transfer.nonce = nonce.nonce
                return self.createTransfer(transfer,
                                           from: account,
                                           requestPasswordDelegate:
                                            requestPasswordDelegate,
                                           bakerKeys: nil,
                                           global: global,
                                           inputEncryptedAmount: inputEncryptedAmount,
                                           receiverPublicKey: receiverPublicKey.accountEncryptionKey)
            }.map({ [weak self] (transferRequest) -> CreateTransferRequest in
                transfer = self?.updateLocalTransfer(transfer,
                                                     withEncryptedTransferRequest: transferRequest,
                                                     andInputEncryptedAmount: inputEncryptedAmount,
                                                     forAccount: account) ?? transfer
                return transferRequest
            })
            .flatMap(submitTransfer)
            .flatMap { [weak self] (submissionResponse: SubmissionResponse) -> AnyPublisher<SubmissionStatus, Error> in
                guard let self = self else { return .fail(GeneralError.unexpectedNullValue) }
                transfer.submissionId = submissionResponse.submissionID
                return self.submissionStatus(submissionId: submissionResponse.submissionID)
            }.map { [weak self] in
                self?.updateLocalTransfer(transfer, withSubmissionStatus: $0) ?? transfer
            }
            .eraseToAnyPublisher()
    }
    
    private func performDelegationTransfer(_ pTransfer: TransferDataType,
                                           from account: AccountDataType,
                                           requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<TransferDataType, Error> {
        
        var transfer = updateLocalTransferWithExpiration(pTransfer)
        return getAccountNonce(for: transfer.fromAddress)
            .flatMap { (nonce: AccNonce) -> AnyPublisher<CreateTransferRequest, Error> in
                transfer.nonce = nonce.nonce
                return self.createTransfer(transfer,
                                           from: account,
                                           requestPasswordDelegate:
                                            requestPasswordDelegate,
                                           bakerKeys: nil,
                                           global: nil,
                                           inputEncryptedAmount: nil,
                                           receiverPublicKey: nil)
            }
            .flatMap(submitTransfer)
            .flatMap { (submissionResponse: SubmissionResponse) -> AnyPublisher<SubmissionStatus, Error> in
                transfer.submissionId = submissionResponse.submissionID
                return self.submissionStatus(submissionId: submissionResponse.submissionID)
            }.map { [weak self] in
                self?.updateLocalTransfer(transfer, withSubmissionStatus: $0) ?? transfer
            }
            .eraseToAnyPublisher()
        
    }
    
    private func performBakerTransfer(_ pTransfer: TransferDataType,
                                      from account: AccountDataType,
                                      bakerKeys: GeneratedBakerKeys?,
                                      requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<TransferDataType, Error> {
        var transfer = updateLocalTransferWithExpiration(pTransfer)
        return getAccountNonce(for: transfer.fromAddress)
            .flatMap { (nonce: AccNonce) -> AnyPublisher<CreateTransferRequest, Error> in
                transfer.nonce = nonce.nonce
                return self.createTransfer(transfer,
                                           from: account,
                                           requestPasswordDelegate:
                                            requestPasswordDelegate,
                                           bakerKeys: bakerKeys,
                                           global: nil,
                                           inputEncryptedAmount: nil,
                                           receiverPublicKey: nil)
            }
            .flatMap(submitTransfer)
            .flatMap { (submissionResponse: SubmissionResponse) -> AnyPublisher<SubmissionStatus, Error> in
                transfer.submissionId = submissionResponse.submissionID
                return self.submissionStatus(submissionId: submissionResponse.submissionID)
            }.map { [weak self] in
                self?.updateLocalTransfer(transfer, withSubmissionStatus: $0) ?? transfer
            }
            .eraseToAnyPublisher()
    }
    
    private func createTransfer(_ transfer: TransferDataType,
                                from account: AccountDataType,
                                requestPasswordDelegate: RequestPasswordDelegate,
                                bakerKeys: GeneratedBakerKeys? = nil,
                                global: GlobalWrapper? = nil,
                                inputEncryptedAmount: InputEncryptedAmount? = nil,
                                receiverPublicKey: String? = nil) -> AnyPublisher<CreateTransferRequest, Error> {
        let transactionFeeCommission = (transfer.transactionFeeCommission == -1) ? nil : transfer.transactionFeeCommission
        let bakingRewardCommission = (transfer.bakingRewardCommission == -1) ? nil : transfer.bakingRewardCommission
        let finalizationRewardCommission = (transfer.finalizationRewardCommission == -1) ? nil : transfer.finalizationRewardCommission
        let delegationTarget: DelegationTarget?
        if let delegationType = transfer.delegationType {
            delegationTarget = DelegationTarget(
                delegateType: delegationType,
                bakerID: transfer.delegationTargetBaker)
        } else {
            delegationTarget = nil
        }
        
        return self.mobileWallet.createTransfer(from: account,
                                                to: transfer.toAddress == "" ? nil : transfer.toAddress,
                                                amount: transfer.amount == "" ? nil : transfer.amount,
                                                nonce: transfer.nonce,
                                                memo: transfer.memo,
                                                capital: transfer.capital == "" ? nil : transfer.capital,
                                                restakeEarnings: transfer.restakeEarnings,
                                                delegationTarget: delegationTarget,
                                                openStatus: transfer.openStatus,
                                                metadataURL: transfer.metadataURL,
                                                transactionFeeCommission: transactionFeeCommission,
                                                bakingRewardCommission: bakingRewardCommission,
                                                finalizationRewardCommission: finalizationRewardCommission,
                                                bakerKeys: bakerKeys,
                                                expiry: transfer.expiry,
                                                energy: transfer.energy,
                                                transferType: transfer.transferType,
                                                requestPasswordDelegate: requestPasswordDelegate,
                                                global: global,
                                                inputEncryptedAmount: inputEncryptedAmount,
                                                receiverPublicKey: receiverPublicKey
        )
    }
    
    // MARK: Network helpers
    private func getAccountNonce(for address: String) -> AnyPublisher<AccNonce, Error> {
        networkManager.load(ResourceRequest(url: ApiConstants.accNonce.appendingPathComponent(address)))
    }
    
    private func getGlobal() -> AnyPublisher<GlobalWrapper, Error> {
        networkManager.load(ResourceRequest(url: ApiConstants.global))
    }
    
    private func getPublicAccountKey(for address: String) -> AnyPublisher<PublicEncriptionKey, Error> {
        networkManager.load(ResourceRequest(url: ApiConstants.accEncryptionKey.appendingPathComponent(address)))
    }
    
    private func submitTransfer(_ createTransferRequest: CreateTransferRequest) -> AnyPublisher<SubmissionResponse, Error> {
        do {
            let data = try createTransferRequest.jsonData()
            return networkManager.load(ResourceRequest(url: ApiConstants.submitTransfer, httpMethod: .put, body: data))
        } catch {
            return .fail(error)
        }
    }
   
    // MARK: Encrypted Amount calculation helpers
    private func getInputEncryptedAmount(for account: AccountDataType) -> InputEncryptedAmount {
        // if existing pending transactions,
        // aggEncryptedAmount = last self amount from transaction + any incoming amounts that were NOT used in that transaction
        // else aggEncryptedAmount = selfAmount + incoming Amounts
        
        var index: Int
        let aggEncryptedAmount: String?
        
        if let encryptedBalance = account.encryptedBalance {
            
            let incomingAmounts = encryptedBalance.incomingAmounts.filter { (amount) -> Bool in
                storageManager.getShieldedAmount(encryptedValue: amount, account: account) != nil
            }
            
            // we always use all the indexes available in incoming Amounts
            index = encryptedBalance.startIndex + incomingAmounts.count
            
            // if we have any pending transactions, we calculate the amount and the index based on what was used in that transaction
            if let transaction = storageManager.getLastEncryptedBalanceTransfer(for: account.address),
               let encryptedDetails = transaction.encryptedDetails,
               let latestSelfAmount = encryptedDetails.updatedNewSelfEncryptedAmount {
                var amounts: [String] = [latestSelfAmount]
                let lastUsedIndexInTransaction = encryptedDetails.updatedNewStartIndex
                
                // get the first unused index of incoming amounts and add that to the selfAmount
                let startIndexInIncomingAmounts = lastUsedIndexInTransaction - encryptedBalance.startIndex
                if startIndexInIncomingAmounts < incomingAmounts.count {
                    amounts.append(contentsOf: incomingAmounts[startIndexInIncomingAmounts..<incomingAmounts.count])
                }
                aggEncryptedAmount = addAmounts(amounts)
            } else {
                // if we don't have any pending transactions, we just add up the incoming amounts
                var amounts: [String] = incomingAmounts
                if let selfAmount = encryptedBalance.selfAmount {
                    amounts.append(selfAmount)
                }
                aggEncryptedAmount = addAmounts(amounts)
            }
        } else {
            // this shouldn't happen
            index = 0
            aggEncryptedAmount = account.encryptedBalance?.selfAmount
        }
        let inputEncryptedAmount = InputEncryptedAmount(aggEncryptedAmount: aggEncryptedAmount,
                                                        aggAmount: String(account.forecastEncryptedBalance),
                                                        aggIndex: index)
        return inputEncryptedAmount
    }
    
    private func addAmounts(_ amounts: [String]) -> String {
        do {
            return try amounts.reduce("") { (result, amount) -> String in
                if result == "" {
                    return amount
                } else {
                    return try mobileWallet.combineEncryptedAmount(result, amount).get()
                }
            }
        } catch {
            return ""
        }
    }
    
    // MARK: Update local transfer helpers
    private func updateLocalTransfer (_ ptransfer: TransferDataType,
                                      withShieldingRequest transferRequest: CreateTransferRequest,
                                      forAccount account: AccountDataType) -> TransferDataType {
        var transfer = ptransfer
        if let transaction = storageManager.getLastEncryptedBalanceTransfer(for: account.address),
           let encryptedDetails = transaction.encryptedDetails,
           let selfAmount = encryptedDetails.updatedNewSelfEncryptedAmount,
           let decryptedSelfAmount = storageManager.getShieldedAmount(encryptedValue: selfAmount, account: account)?.decryptedValue,
           let transferAmount = Int(transfer.amount),
           let decryptedSelfAmountInt = Int(decryptedSelfAmount),
           let addedSelfEncryptedAmount = transferRequest.addedSelfEncryptedAmount,
           let newSelfAmount = try? self.mobileWallet.combineEncryptedAmount(addedSelfEncryptedAmount, selfAmount).get() {
            let newDecryptedSelfAmount = decryptedSelfAmountInt + transferAmount

            let shieldedAmount = ShieldedAmountTypeFactory.create().with(account: account,
                                                                         encryptedValue: newSelfAmount,
                                                                         decryptedValue: String(newDecryptedSelfAmount),
                                                                         incomingAmountIndex: -1)
            _ = try? self.storageManager.storeShieldedAmount(amount: shieldedAmount)

            let encryptedDetails = EncryptedDetailsEntity(newSelfEncryptedAmount: newSelfAmount,
                                                          newStartIndex: encryptedDetails.updatedNewStartIndex)
            transfer.encryptedDetails = encryptedDetails

        } else if let selfAmount = account.encryptedBalance?.selfAmount,
                  let startIndex = account.encryptedBalance?.startIndex,
                  let addedSelfEncryptedAmount = transferRequest.addedSelfEncryptedAmount,
                  let decryptedSelfAmount = storageManager.getShieldedAmount(encryptedValue: selfAmount,
                                                                                  account: account)?.decryptedValue,
                  let transferAmount = Int(transfer.amount),
                  let decryptedSelfAmountInt = Int(decryptedSelfAmount),
                  let newSelfAmount = try? self.mobileWallet.combineEncryptedAmount(addedSelfEncryptedAmount, selfAmount).get() {

            let newDecryptedSelfAmount = decryptedSelfAmountInt + transferAmount

            let shieldedAmount = ShieldedAmountTypeFactory.create().with(account: account,
                                                                         encryptedValue: newSelfAmount,
                                                                         decryptedValue: String(newDecryptedSelfAmount),
                                                                         incomingAmountIndex: -1)
            _ = try? self.storageManager.storeShieldedAmount(amount: shieldedAmount)

            let encryptedDetails = EncryptedDetailsEntity(newSelfEncryptedAmount: newSelfAmount, newStartIndex: startIndex)
            transfer.encryptedDetails = encryptedDetails
        }
        return transfer
    }
    
    private func updateLocalTransfer (_ ptransfer: TransferDataType,
                                      withUnshieldingRequest transferRequest: CreateTransferRequest,
                                      andInputEncryptedAmount inputEncryptedAmount: InputEncryptedAmount,
                                      forAccount account: AccountDataType) -> TransferDataType {
        var transfer = ptransfer
        if let aggAmount = inputEncryptedAmount.aggAmount,
           let remainingSelfAmount = transferRequest.remaining,
           let aggAmountInt = Int(aggAmount),
           let transferedAmount = Int(transfer.amount) {
            let remainingAmount = aggAmountInt - transferedAmount

            let shieldedAmount = ShieldedAmountTypeFactory.create().with(account: account,
                                                                         encryptedValue: remainingSelfAmount,
                                                                         decryptedValue: String(remainingAmount),
                                                                         incomingAmountIndex: -1)
            _ = try? self.storageManager.storeShieldedAmount(amount: shieldedAmount)

            // store encrypted details
            let encryptedDetails = EncryptedDetailsEntity(newSelfEncryptedAmount: remainingSelfAmount,
                                                          newStartIndex: inputEncryptedAmount.aggIndex)
            transfer.encryptedDetails = encryptedDetails
        }
        return transfer
    }
    
    private func updateLocalTransfer (_ ptransfer: TransferDataType,
                                      withEncryptedTransferRequest transferRequest: CreateTransferRequest,
                                      andInputEncryptedAmount inputEncryptedAmount: InputEncryptedAmount,
                                      forAccount account: AccountDataType) -> TransferDataType {
        var transfer = ptransfer
        if let aggAmount = inputEncryptedAmount.aggAmount,
           let remainingSelfAmount = transferRequest.remaining,
           let aggAmountInt = Int(aggAmount),
           let transferedAmount = Int(transfer.amount) {
            let remainingAmount = aggAmountInt - transferedAmount

            let shieldedAmount = ShieldedAmountTypeFactory.create().with(account: account,
                                                                         encryptedValue: remainingSelfAmount,
                                                                         decryptedValue: String(remainingAmount),
                                                                         incomingAmountIndex: -1)
            _ = try? self.storageManager.storeShieldedAmount(amount: shieldedAmount)

            let encryptedDetails = EncryptedDetailsEntity(newSelfEncryptedAmount: remainingSelfAmount,
                                                          newStartIndex: inputEncryptedAmount.aggIndex)
            transfer.encryptedDetails = encryptedDetails
        }
        return transfer
    }
    
    private func updateLocalTransfer(_ pTransfer: TransferDataType, withSubmissionStatus submissionStatus: SubmissionStatus) -> TransferDataType {
        var transfer = pTransfer
        transfer.transactionStatus = submissionStatus.status
        transfer.outcome = submissionStatus.outcome
        return transfer
    }
    
    private func updateLocalTransferWithExpiration(_ pTransfer: TransferDataType) -> TransferDataType {
        var transfer = pTransfer
        let tenMinutes: TimeInterval = 60 * 10
        let expiry = Date(timeIntervalSinceNow: tenMinutes)
        transfer.expiry = expiry
        transfer.createdAt = Date()
        return transfer
    }
}

extension TransactionsServiceProtocol {
    func getBakingTransferCostRange(parameters: [TransferCostParameter]) -> AnyPublisher<TransferCostRange, Error> {
        let minPublisher = getTransferCost(transferType: .registerBaker, costParameters: parameters + [.metadataSize(0)]).first()
        let maxPublisher = getTransferCost(transferType: .registerBaker, costParameters: parameters + [.metadataSize(2048)]).first()
        
        return minPublisher
            .zip(maxPublisher)
            .map { (min, max) in
                TransferCostRange(min: min, max: max)
            }
            .eraseToAnyPublisher()
    }
}
