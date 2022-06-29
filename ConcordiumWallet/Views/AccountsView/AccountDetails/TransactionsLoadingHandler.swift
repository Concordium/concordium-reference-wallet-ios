//
// Created by Concordium on 04/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

class TransactionsLoadingHandler {
    let storageManager: StorageManagerProtocol
    let account: AccountDataType
    var balanceType: AccountBalanceTypeEnum
    let transactionsService: TransactionsServiceProtocol

    private var localTransactionsNotShownYet: [TransactionViewModel] = []
    let displayedTransactions = [TransactionViewModel]()
    var undecryptedTransactions: [Transaction] = []

    init(account: AccountDataType, balanceType: AccountBalanceTypeEnum, dependencyProvider: AccountsFlowCoordinatorDependencyProvider) {
        self.account = account
        self.transactionsService = dependencyProvider.transactionsService()
        self.storageManager = dependencyProvider.storageManager()
        self.balanceType = balanceType
    }

    func updateBalanceType(_ balanceType: AccountBalanceTypeEnum) {
        self.balanceType = balanceType
    }
    
    private func recipientListLookup(accountAddress: String?) -> String? {
        guard let accountAddress = accountAddress else { return nil }
        return storageManager.getRecipient(withAddress: accountAddress)?.name
    }

    private func encryptedAmopuntLookup(encryptedAmount: String?) -> Int? {
        guard let encryptedValue = encryptedAmount else { return 0 }
        guard let amount = self.storageManager.getShieldedAmount(encryptedValue: encryptedValue, account: account) else { return nil }
        return Int(amount.decryptedValue ) ?? nil
       }
    
    func decryptUndecryptedTransactions(requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<[(String, Int)], Error> {
        transactionsService.decryptEncryptedTransferAmounts(transactions: self.undecryptedTransactions,
                                                            from: account,
                                                            requestPasswordDelegate: requestPasswordDelegate)
    }

    func decryptUndecryptedTransaction(withTransactionHash: String?,
                                       requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<[(String, Int)], Error> {
        let matchingTransaction = self.undecryptedTransactions.filter { $0.transactionHash == withTransactionHash }
        return transactionsService.decryptEncryptedTransferAmounts(transactions: matchingTransaction,
                                                                   from: account,
                                                                   requestPasswordDelegate: requestPasswordDelegate).map { [weak self] result in
            self?.undecryptedTransactions = []
            return result
        }.eraseToAnyPublisher()
    }

    func getTransactions(startingFrom: TransactionViewModel? = nil) -> AnyPublisher<([TransactionViewModel], [TransactionViewModel]), Error> {
        if startingFrom == nil {
            undecryptedTransactions = []
            loadLocalTransfers()
        }
        return transactionsService.getTransactions(for: account, startingFrom: startingFrom?.source as? Transaction)
            .map { transactionsWrapper in
                var filteredMerged = self.mergeTransactions(newTransactions: transactionsWrapper)
                let allMerged = self.mergeTransactions(newTransactions: transactionsWrapper, useAllTransactions: true)
                if allMerged.last?.isLast == true && filteredMerged.count > 0 {
                    filteredMerged[filteredMerged.count - 1].isLast = true
                }
                let tuple = (filteredMerged, allMerged)
                return tuple
            }
            .eraseToAnyPublisher()
    }

    func loadLocalTransfers() {
        self.localTransactionsNotShownYet = storageManager.getTransfers(for: account.address)
            .filter { (transfer) -> Bool in
                // we don't show simple trasnfers in shielded balance
                if balanceType == .shielded && (transfer.transferType == .simpleTransfer) {
                    return false
                }
                return true }
            .map {
            TransactionViewModel(localTransferData: $0,
                                 submissionStatus: nil,
                                 account: self.account,
                                 balanceType: self.balanceType,
                                 encryptedAmountLookup: self.encryptedAmopuntLookup(encryptedAmount:),
                                 recipientListLookup: self.recipientListLookup(accountAddress:))
        }
    }

    private func isLastFromServer(transactions: RemoteTransactions) -> Bool {
        if let cnt = transactions.count, let limit = transactions.limit {
            if cnt == 0 || cnt < limit {
                return true
            }
        }
        return false
    }

    // swiftlint:disable function_body_length
    private func mergeTransactions(newTransactions: RemoteTransactions, useAllTransactions: Bool = false) -> [TransactionViewModel] {
        let rawTransactions: [Transaction] = newTransactions.transactions ?? []
        let filteredRawTransactions: [Transaction]
        if !useAllTransactions {
            
            filteredRawTransactions = rawTransactions.filter { (transaction) -> Bool in
                if balanceType == .balance {
                     // For balance type balance, we only remove incoming shielded transactions
                    let incomingEncrypted = transaction.details.type == "encryptedAmountTransfer"
                        && transaction.origin?.type != OriginTypeEnum.typeSelf
                    let incomingEncryptedWithMemo = transaction.details.type == "encryptedAmountTransferWithMemo"
                        && transaction.origin?.type != OriginTypeEnum.typeSelf

                    if incomingEncrypted || incomingEncryptedWithMemo {
                        return false
                    }
                } else if balanceType == .shielded {
                    // For balance type shielded, we only keep shielded transactions and the self transfers
                    if transaction.details.type != "encryptedAmountTransfer" &&
                        transaction.details.type != "encryptedAmountTransferWithMemo" &&
                        transaction.details.type != "transferToEncrypted" &&
                        transaction.details.type != "transferToPublic" {
                        return false
                    }
                }
                return true
            }
        } else {
            filteredRawTransactions = rawTransactions
        }
        
        if balanceType == .shielded {
            // swiftlint:disable line_length
            let association: [(Transaction, String?, Int?)] = filteredRawTransactions.map { (transaction) -> (Transaction, String?, Int?) in
                (transaction, transaction.encrypted?.encryptedAmount, self.encryptedAmopuntLookup(encryptedAmount: transaction.encrypted?.encryptedAmount))
            }
            let newUndecrypted = association.filter { (_, encrypted, value) -> Bool in
                value == nil && encrypted != nil
            }.map { (transaction, _, _) -> Transaction in
                return transaction
            }
            undecryptedTransactions += newUndecrypted
        }
        
        let remoteTransactionsVM: [TransactionViewModel] = filteredRawTransactions.map {
            TransactionViewModel(remoteTransactionData: $0,
                                 account: self.account,
                                 balanceType: self.balanceType,
                                 encryptedAmountLookup: self.encryptedAmopuntLookup(encryptedAmount:),
                                 recipientListLookup: self.recipientListLookup(accountAddress:))
        }
        var timeOfLastRemoteTransaction = remoteTransactionsVM.last?.date ?? Date.distantPast

        if isLastFromServer(transactions: newTransactions)  || remoteTransactionsVM.count == 0 {
            timeOfLastRemoteTransaction = Date.distantPast
        } else {
            // We know that there is elements in remoteTransactionsVM since the isLastFromServer method
            // will return true if there are no elements in the list
            timeOfLastRemoteTransaction = remoteTransactionsVM.last!.date
        }

        let localTransfersToMerge = self.localTransactionsNotShownYet.filter { localTrns in localTrns.date >= timeOfLastRemoteTransaction }
        if useAllTransactions {
            self.localTransactionsNotShownYet.removeAll { localTransfersToMerge.contains($0) }
        }

        var mergedTransactions: [TransactionViewModel] = remoteTransactionsVM + localTransfersToMerge
        
        // Sort the list
        mergedTransactions.sort { $0.date > $1.date }
        // Handle special case where no transactions were returned from server in last call
        if isLastFromServer(transactions: newTransactions) && useAllTransactions {
            if mergedTransactions.count > 0 {
                mergedTransactions[mergedTransactions.count - 1].isLast = true
            }
        }
        return mergedTransactions
    }
}
