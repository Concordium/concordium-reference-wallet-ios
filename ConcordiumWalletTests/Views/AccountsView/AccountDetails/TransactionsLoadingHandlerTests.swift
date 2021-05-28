//
// Created by Concordium on 04/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import XCTest
import Combine
@testable import ProdMainNet

class DependencyProviderMock: DependencyProviderMockHelper {
    var transactionsServiceMock: TransSrcvMock
    var storageManagerMock: StorageManagerMock

    init(transactionsServiceMock: TransSrcvMock, storageManagerMock: StorageManagerMock) {
        self.transactionsServiceMock = transactionsServiceMock
        self.storageManagerMock = storageManagerMock
        super.init()
    }

    override func transactionsService() -> TransactionsServiceProtocol {
        transactionsServiceMock
    }

    override func storageManager() -> StorageManagerProtocol {
        storageManagerMock
    }
}

class StorageManagerMock: StorageManagerMockHelper {
    var transfers = [TransferDataType]()

    override func getRecipient(withAddress address: String) -> RecipientDataType? {
        RecipientEntity()
    }

    override func getTransfers(for accountAddress: String) -> [TransferDataType] {
        transfers
    }

    func addMockLocalTransaction(time: Int) {
        let transferEntity = TransferEntity()
        transferEntity.createdAt = Date(timeIntervalSince1970: Double(time))
        transfers.append(transferEntity)
    }
}

class TransSrcvMock: TransactionsServiceMockHelper {
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
        let mockDetails: Details = Details(transferDestination: nil, transferAmount: nil, events: nil,
                outcome: .success, type: nil, detailsDescription: nil, transferSource: nil, rejectReason: nil)
        transactions.append(Transaction(blockTime: time, origin: nil, energy: nil, blockHash: "",
                cost: "0", subtotal: "0",
                transactionHash: "", details: mockDetails,
                total: "0", id: 0))
        transactions.sort { $0.blockTime ?? 0 > $1.blockTime ?? 0 } //sort descending
    }
}

//swiftlint:disable:next type_body_length
class TransactionsLoadingHandlerTests: XCTestCase {
    let transactionsServiceMock = TransSrcvMock()
    let storageManagerMock = StorageManagerMock()
    var dp: DependencyProviderMock!
    var account = AccountEntity()

    var sut: TransactionsLoadingHandler!

    override func setUp() {
        super.setUp()
        dp = DependencyProviderMock(transactionsServiceMock: transactionsServiceMock, storageManagerMock: storageManagerMock)
        account = AccountEntity()
        account.name = "test name"
        sut = TransactionsLoadingHandler(account: account, dependencyProvider: dp)

    }

    func testSimpleMerging() {
        transactionsServiceMock.addMockRemoteTransaction(time: 0)
        transactionsServiceMock.addMockRemoteTransaction(time: 2)

        storageManagerMock.addMockLocalTransaction(time: 1)
        storageManagerMock.addMockLocalTransaction(time: 3)

        let expectation = self.expectation(description: "waiting publisher finish")
        _ = sut.getTransactions()
                .map { self.applyViewModelSorting(transactionViewModels: $0) }
                .sink(receiveError: { _ in }, receiveValue: { transactionViewModels in
                    XCTAssertEqual(transactionViewModels.count, 4)
                    XCTAssertEqual(transactionViewModels[0].date.timeIntervalSince1970, 3)
                    XCTAssertEqual(transactionViewModels[1].date.timeIntervalSince1970, 2)
                    XCTAssertEqual(transactionViewModels[2].date.timeIntervalSince1970, 1)
                    XCTAssertEqual(transactionViewModels[3].date.timeIntervalSince1970, 0)
                    expectation.fulfill()
                })

        wait(for: [expectation], timeout: 1)
    }

    func testMergingWhereServerHasMorePagesToReturn() {
        transactionsServiceMock.addMockRemoteTransaction(time: 4)
        transactionsServiceMock.addMockRemoteTransaction(time: 2)
        transactionsServiceMock.addMockRemoteTransaction(time: 0)

        transactionsServiceMock.limit = 2 //only return the first two elements

        storageManagerMock.addMockLocalTransaction(time: 3)
        storageManagerMock.addMockLocalTransaction(time: 1)

        let expectation = self.expectation(description: "waiting publisher finish")
        _ = sut.getTransactions()
                .map { self.applyViewModelSorting(transactionViewModels: $0) }
                .sink(receiveError: { _ in }, receiveValue: { transactionViewModels in
                    XCTAssertEqual(transactionViewModels.count, 3)
                    XCTAssertEqual(transactionViewModels[0].date.timeIntervalSince1970, 4)
                    XCTAssertEqual(transactionViewModels[1].date.timeIntervalSince1970, 3)
                    XCTAssertEqual(transactionViewModels[2].date.timeIntervalSince1970, 2)
                    expectation.fulfill()
                })

        wait(for: [expectation], timeout: 1)
    }

    func testMergingWhereLocalTransfersContainsNewestValues() {
        transactionsServiceMock.addMockRemoteTransaction(time: 6)
        transactionsServiceMock.addMockRemoteTransaction(time: 4)
        transactionsServiceMock.addMockRemoteTransaction(time: 2)

        transactionsServiceMock.limit = 2 //only return the first two elements

        storageManagerMock.addMockLocalTransaction(time: 13)
        storageManagerMock.addMockLocalTransaction(time: 11)
        storageManagerMock.addMockLocalTransaction(time: 9)
        storageManagerMock.addMockLocalTransaction(time: 7)
        storageManagerMock.addMockLocalTransaction(time: 5)
        storageManagerMock.addMockLocalTransaction(time: 3)//not expected to be returned

        let expectation = self.expectation(description: "waiting publisher finish")
        _ = sut.getTransactions()
                .map { self.applyViewModelSorting(transactionViewModels: $0) }
                .sink(receiveError: { _ in }, receiveValue: { transactionViewModels in
                    XCTAssertEqual(transactionViewModels.count, 7)
                    let allReturnedTimes = transactionViewModels.map { $0.date.timeIntervalSince1970 }
                    XCTAssertEqual(allReturnedTimes, [13, 11, 9, 7, 6, 5, 4])
                    expectation.fulfill()
                })

        wait(for: [expectation], timeout: 1)
    }

    func testPaging() {
        transactionsServiceMock.addMockRemoteTransaction(time: 12)
        transactionsServiceMock.addMockRemoteTransaction(time: 10)
        transactionsServiceMock.addMockRemoteTransaction(time: 8)
        transactionsServiceMock.addMockRemoteTransaction(time: 6)
        transactionsServiceMock.addMockRemoteTransaction(time: 4)
        transactionsServiceMock.addMockRemoteTransaction(time: 2)

        transactionsServiceMock.limit = 2 //only return the first two elements

        let expectation = self.expectation(description: "waiting publisher finish")
        _ = sut.getTransactions()
                .map { self.applyViewModelSorting(transactionViewModels: $0) }
                .sink(receiveError: { _ in }, receiveValue: { transactionViewModels1 in
                    XCTAssertEqual(transactionViewModels1.count, 2)
                    let allReturnedTimes = transactionViewModels1.map { $0.date.timeIntervalSince1970 }
                    XCTAssertEqual(allReturnedTimes, [12, 10])
                    _ = self.sut.getTransactions(startingFrom: transactionViewModels1.last)
                            .map { self.applyViewModelSorting(transactionViewModels: $0, currentList: transactionViewModels1) }
                            .sink(receiveError: { _ in }, receiveValue: { transactionViewModels2 in
                                XCTAssertEqual(transactionViewModels2.count, 4)
                                let allReturnedTimes = transactionViewModels2.map { $0.date.timeIntervalSince1970 }
                                XCTAssertEqual(allReturnedTimes, [12, 10, 8, 6])
                                expectation.fulfill()
                            })
                })

        wait(for: [expectation], timeout: 1)
    }

    func testPagingWithMerging() {
        transactionsServiceMock.addMockRemoteTransaction(time: 12)
        transactionsServiceMock.addMockRemoteTransaction(time: 10)
        transactionsServiceMock.addMockRemoteTransaction(time: 8)
        transactionsServiceMock.addMockRemoteTransaction(time: 6)
        transactionsServiceMock.addMockRemoteTransaction(time: 4)
        transactionsServiceMock.addMockRemoteTransaction(time: 2)

        storageManagerMock.addMockLocalTransaction(time: 13)
        storageManagerMock.addMockLocalTransaction(time: 11)
        storageManagerMock.addMockLocalTransaction(time: 9)
        storageManagerMock.addMockLocalTransaction(time: 7)
        storageManagerMock.addMockLocalTransaction(time: 5)
        storageManagerMock.addMockLocalTransaction(time: 3)//not expected to be returned

        transactionsServiceMock.limit = 2 //only return the first two elements

        let expectation = self.expectation(description: "waiting publisher finish")
        _ = sut.getTransactions()
                .map { self.applyViewModelSorting(transactionViewModels: $0) }
                .sink(receiveError: { _ in }, receiveValue: { transactionViewModels1 in
                    XCTAssertEqual(transactionViewModels1.count, 4)
                    let allReturnedTimes = transactionViewModels1.map { $0.date.timeIntervalSince1970 }
                    XCTAssertEqual(allReturnedTimes, [13, 12, 11, 10])
                    _ = self.sut.getTransactions(startingFrom: transactionViewModels1.last)
                            .map { self.applyViewModelSorting(transactionViewModels: $0, currentList: transactionViewModels1) }
                            .sink(receiveError: { _ in }, receiveValue: { transactionViewModels2 in
                                XCTAssertEqual(transactionViewModels2.count, 8)
                                let allReturnedTimes = transactionViewModels2.map { $0.date.timeIntervalSince1970 }
                                XCTAssertEqual(allReturnedTimes, [13, 12, 11, 10, 9, 8, 7, 6])
                                expectation.fulfill()
                            })
                })

        wait(for: [expectation], timeout: 1)
    }

    func testIsLastWithOnePage() {
        transactionsServiceMock.addMockRemoteTransaction(time: 4)
        transactionsServiceMock.addMockRemoteTransaction(time: 2)

        transactionsServiceMock.limit = 3

        let expectation = self.expectation(description: "waiting publisher finish")
        _ = sut.getTransactions()
                .sink(receiveError: { _ in }, receiveValue: { transactionViewModels in
                    XCTAssertEqual(transactionViewModels.count, 2)
                    XCTAssertEqual(transactionViewModels[0].isLast, false)
                    XCTAssertEqual(transactionViewModels[1].isLast, true)
                    expectation.fulfill()
                })

        wait(for: [expectation], timeout: 1)
    }

    func testIsLastWithOnePageAndNumberOfTransactionsEqualToLimit() {
        transactionsServiceMock.addMockRemoteTransaction(time: 6)
        transactionsServiceMock.addMockRemoteTransaction(time: 4)
        transactionsServiceMock.addMockRemoteTransaction(time: 2)

        transactionsServiceMock.limit = 3

        let expectation = self.expectation(description: "waiting publisher finish")
        _ = sut.getTransactions()
                .sink(receiveError: { _ in }, receiveValue: { transactionViewModels1 in
                    XCTAssertEqual(transactionViewModels1.count, 3)
                    XCTAssertEqual(transactionViewModels1[0].isLast, false)
                    XCTAssertEqual(transactionViewModels1[1].isLast, false)
                    XCTAssertEqual(transactionViewModels1[2].isLast, false)
                    _ = self.sut.getTransactions(startingFrom: transactionViewModels1.last)
                            .sink(receiveError: { _ in }, receiveValue: { transactionViewModels2 in
                                XCTAssertEqual(transactionViewModels2.count, 0)
                                //'isLast' must be set in the shown array when no elements are returned
                                // - therefore, nothing extra to check here
                                expectation.fulfill()
                            })
                })

        wait(for: [expectation], timeout: 1)
    }

    func testIsLastWithTwoPages() {
        transactionsServiceMock.addMockRemoteTransaction(time: 6)
        transactionsServiceMock.addMockRemoteTransaction(time: 4)
        transactionsServiceMock.addMockRemoteTransaction(time: 2)

        transactionsServiceMock.limit = 2 //only return the first two elements

        let expectation = self.expectation(description: "waiting publisher finish")
        _ = sut.getTransactions()
                .sink(receiveError: { _ in }, receiveValue: { transactionViewModels1 in
                    XCTAssertEqual(transactionViewModels1.count, 2)
                    XCTAssertEqual(transactionViewModels1[0].isLast, false)
                    XCTAssertEqual(transactionViewModels1[1].isLast, false)
                    _ = self.sut.getTransactions(startingFrom: transactionViewModels1.last)
                            .sink(receiveError: { _ in }, receiveValue: { transactionViewModels2 in
                                XCTAssertEqual(transactionViewModels2.count, 1)
                                XCTAssertEqual(transactionViewModels2[0].isLast, true)
                                expectation.fulfill()
                            })
                })

        wait(for: [expectation], timeout: 1)
    }

    func testIsLastWithTwoPagesAndLocalTransactionsOnlyAfterLastRemoteTransaction() {
        transactionsServiceMock.addMockRemoteTransaction(time: 6)
        transactionsServiceMock.addMockRemoteTransaction(time: 4)
        transactionsServiceMock.addMockRemoteTransaction(time: 2)

        storageManagerMock.addMockLocalTransaction(time: 7)
        storageManagerMock.addMockLocalTransaction(time: 5)
        storageManagerMock.addMockLocalTransaction(time: 3)

        transactionsServiceMock.limit = 2 //only return the first two elements

        let expectation = self.expectation(description: "waiting publisher finish")
        _ = sut.getTransactions()
                .sink(receiveError: { _ in }, receiveValue: { transactionViewModels1 in
                    XCTAssertEqual(transactionViewModels1.count, 4)
                    XCTAssertEqual(transactionViewModels1[0].isLast, false)
                    XCTAssertEqual(transactionViewModels1[1].isLast, false)
                    XCTAssertEqual(transactionViewModels1[2].isLast, false)
                    XCTAssertEqual(transactionViewModels1[3].isLast, false)
                    XCTAssertEqual(transactionViewModels1.map { $0.date.timeIntervalSince1970 }, [7, 6, 5, 4])
                    _ = self.sut.getTransactions(startingFrom: transactionViewModels1.last)
                            .sink(receiveError: { _ in }, receiveValue: { transactionViewModels2 in
                                XCTAssertEqual(transactionViewModels2.map { $0.date.timeIntervalSince1970 }, [3, 2])
                                XCTAssertEqual(transactionViewModels2.count, 2)
                                XCTAssertEqual(transactionViewModels2[0].isLast, false)
                                XCTAssertEqual(transactionViewModels2[1].isLast, true)
                                expectation.fulfill()
                            })
                })

        wait(for: [expectation], timeout: 1)
    }

    func testIsLastWithTwoPagesAndLocalTransactionsBeforeLastRemoteTransaction() {
        transactionsServiceMock.addMockRemoteTransaction(time: 6)
        transactionsServiceMock.addMockRemoteTransaction(time: 4)
        transactionsServiceMock.addMockRemoteTransaction(time: 2)

        storageManagerMock.addMockLocalTransaction(time: 5)
        storageManagerMock.addMockLocalTransaction(time: 3)
        storageManagerMock.addMockLocalTransaction(time: 1)

        transactionsServiceMock.limit = 2 //only return the first two elements

        let expectation = self.expectation(description: "waiting publisher finish")
        _ = sut.getTransactions()
                .sink(receiveError: { _ in }, receiveValue: { transactionViewModels1 in
                    XCTAssertEqual(transactionViewModels1.count, 3)
                    XCTAssertEqual(transactionViewModels1[0].isLast, false)
                    XCTAssertEqual(transactionViewModels1[1].isLast, false)
                    XCTAssertEqual(transactionViewModels1[2].isLast, false)
                    XCTAssertEqual(transactionViewModels1.map { $0.date.timeIntervalSince1970 }, [6, 5, 4])
                    _ = self.sut.getTransactions(startingFrom: transactionViewModels1.last)
                            .sink(receiveError: { _ in }, receiveValue: { transactionViewModels2 in
                                XCTAssertEqual(transactionViewModels2.map { $0.date.timeIntervalSince1970 }, [3, 2, 1])
                                XCTAssertEqual(transactionViewModels2.count, 3)
                                XCTAssertEqual(transactionViewModels2[0].isLast, false)
                                XCTAssertEqual(transactionViewModels2[1].isLast, false)
                                XCTAssertEqual(transactionViewModels2[2].isLast, true)
//                                XCTAssertEqual(transactionViewModels2[3].isLast, true)
//                                XCTAssertEqual(transactionViewModels2[3].date.timeIntervalSince1970, 1)
                                expectation.fulfill()
                            })
                })

        wait(for: [expectation], timeout: 1)
    }

    private func applyViewModelSorting(transactionViewModels: [TransactionViewModel],
                                       currentList: [TransactionViewModel] = []) -> [TransactionViewModel] {
        let accountDetailsViewModel = AccountDetailsViewModel(account: self.account)
        accountDetailsViewModel.appendTransactions(transactions: currentList)
        accountDetailsViewModel.appendTransactions(transactions: transactionViewModels)
        return accountDetailsViewModel.transactionsList.transactions
    }
}
