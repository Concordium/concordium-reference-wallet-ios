//
// Created by Concordium on 04/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

@testable import ProdMainNet

class TransactionsServiceMockHelper: TransactionsServiceProtocol {
    func performTransfer(_ pTransfer: TransferDataType,
                         from account: AccountDataType,
                         requestPasswordDelegate: RequestPasswordDelegate) -> Combine.AnyPublisher<TransferDataType, Error> {
        fatalError("performTransfer(_:from:requestPasswordDelegate:) has not been implemented")
    }

    func getTransactions(for account: AccountDataType, startingFrom: Transaction?) -> Combine.AnyPublisher<RemoteTransactions, Error> {
        fatalError("getTransactions(for:startingFrom:) has not been implemented")
    }

    func getTransferCost(transferType: TransferType) -> Combine.AnyPublisher<TransferCost, Error> {
        fatalError("getTransferCost() has not been implemented")
    }
}
