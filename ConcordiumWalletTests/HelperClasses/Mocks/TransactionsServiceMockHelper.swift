//
// Created by Concordium on 04/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

@testable import Mock

class TransactionsServiceMockHelper: TransactionsServiceProtocol {
    func performTransfer(
        _ pTransfer: TransferDataType,
        from account: AccountDataType,
        bakerKeys: GeneratedBakerKeys?,
        requestPasswordDelegate: RequestPasswordDelegate
    ) -> AnyPublisher<TransferDataType, Error> {
        NYI()
    }
    
    func getTransferCost(transferType: WalletProxyTransferType, costParameters: [TransferCostParameter]) -> AnyPublisher<TransferCost, Error> {
        NYI()
    }
    
    func decryptEncryptedTransferAmounts(
        transactions: [Transaction],
        from account: AccountDataType,
        requestPasswordDelegate: RequestPasswordDelegate
    ) -> AnyPublisher<[(String, Int)], Error> {
        NYI()
    }
    
    func getTransactions(for account: AccountDataType, startingFrom: Transaction?) -> Combine.AnyPublisher<RemoteTransactions, Error> {
        NYI()
    }
    
    func decodeContractParameter(with contractParams: Mock.ContractUpdateParameterToJsonInput) throws -> String {
        NYI()
    }
}
