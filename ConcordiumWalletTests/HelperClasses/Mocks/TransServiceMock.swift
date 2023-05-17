//
//  TransServiceMock.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 24/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
import Combine
@testable import Mock

class TransServiceMock: TransactionsServiceMockHelper {
    var transactions = [Transaction]()
    var limit = 10

    override func getTransactions(for account: AccountDataType, startingFrom: Transaction?) -> Combine.AnyPublisher<RemoteTransactions, Error> {
        var dropFirst = 0
        if let startingFrom = startingFrom {
            let foundIndex = transactions.firstIndex { transaction in transaction.blockTime == startingFrom.blockTime }
            dropFirst = foundIndex != nil ? foundIndex! + 1 : 0
        }
        let transactionsToReturn = Array(transactions.dropFirst(dropFirst).prefix(limit))
        return .just(RemoteTransactions(transactions: transactionsToReturn, count: transactionsToReturn.count, limit: limit, order: "d"))
    }

    func addMockRemoteTransaction(time: Double) {
        
        let mockDetails: Details = Details(transferDestination: nil, memo: nil, transferAmount: nil, events: nil,
                                           outcome: .success, type: nil, detailsDescription: nil, transferSource: nil,
                                           newIndex: nil, inputEncryptedAmount: nil, newSelfEncryptedAmount: nil,
                                           encryptedAmount: nil, aggregatedIndex: nil, amountSubtracted: nil,
                                           rejectReason: nil, amountAdded: nil)
        transactions.append(Transaction(blockTime: time, origin: nil, energy: nil, blockHash: "",
                cost: "0", subtotal: "0",
                transactionHash: "", details: mockDetails,
                total: "0", id: 0, encrypted: nil))
        transactions.sort { $0.blockTime ?? 0 > $1.blockTime ?? 0 } // sort descending
    }
}
