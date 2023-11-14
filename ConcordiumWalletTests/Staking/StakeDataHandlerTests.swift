//
//  StakeDataHandlerTests.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 05/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import XCTest

@testable import Mock

// swiftlint:disable type_body_length
class StakeDataHandlerTests: XCTestCase {
    private var testAccount: AccountDataType {
        AddressOnlyAccount()
    }
    
    func testRegisterBakerTransfer() {
        let account = testAccount
        let dataHandler = BakerDataHandler(account: account, action: .register)
        
        dataHandler.add(entry: BakerAmountData(amount: GTU(intValue: 125)))
        dataHandler.add(entry: RestakeBakerData(restake: true))
        dataHandler.add(entry: BakerPoolSettingsData(poolSettings: .open))
        dataHandler.add(entry: BakerMetadataURLData(metadataURL: "https://example.com"))
        dataHandler.add(entry: BakerKeyData(keys: .randomKeys))
        dataHandler.add(entry: BakerCommissionData(
            bakingRewardComission: 0.5,
            finalizationRewardComission: 1.0,
            transactionComission: 1.5
        ))
        
        assertStateEqual(
            account: account,
            dataHandler: dataHandler,
            transferType: .registerBaker,
            costParameters: [],
            capital: "125",
            restakeEarnings: true,
            openStatus: "openForAll",
            metadataURL: "https://example.com",
            bakingRewardsComission: 0.5,
            finalizationRewardsComission: 1.0,
            transactionFeeComission: 1.5
        )
    }
    
    func testRegisterClosedBakerTransfer() {
        let account = testAccount
        let dataHandler = BakerDataHandler(account: account, action: .register)
        
        dataHandler.add(entry: BakerAmountData(amount: GTU(intValue: 125)))
        dataHandler.add(entry: RestakeBakerData(restake: true))
        dataHandler.add(entry: BakerPoolSettingsData(poolSettings: .closed))
        dataHandler.add(entry: BakerKeyData(keys: .randomKeys))
        dataHandler.add(entry: BakerCommissionData(
            bakingRewardComission: 0.5,
            finalizationRewardComission: 1.0,
            transactionComission: 1.5
        ))
        
        assertStateEqual(
            account: account,
            dataHandler: dataHandler,
            transferType: .registerBaker,
            costParameters: [],
            capital: "125",
            restakeEarnings: true,
            openStatus: "closedForAll",
            metadataURL: "",
            bakingRewardsComission: 0.5,
            finalizationRewardsComission: 1.0,
            transactionFeeComission: 1.5
        )
    }
    
    func testStopBakerTransfer() {
        let account = testAccount
        let dataHandler = BakerDataHandler(account: account, action: .stopBaking)
        
        assertStateEqual(
            account: account,
            dataHandler: dataHandler,
            transferType: .removeBaker,
            costParameters: [],
            capital: "0"
        )
    }
    
    func testUpdateBakerStakeTransfer() {
        let poolInfo = PoolInfo(
            commissionRates: CommissionRates(
                transactionCommission: 0.5,
                finalizationCommission: 1.0,
                bakingCommission: 1.5
            ),
            openStatus: "openForAll",
            metadataURL: "https://example.com"
        )
        let account = testAccount
        let baker = TestBaker(stakedAmount: 125, restakeEarnings: true, pendingChange: nil)
        let dataHandler = BakerDataHandler(account: account, action: .updateBakerStake(baker, poolInfo))
        
        dataHandler.add(entry: BakerAmountData(amount: GTU(intValue: 150)))
        
        assertStateEqual(
            account: account,
            dataHandler: dataHandler,
            transferType: .updateBakerStake,
            costParameters: [.amount(nil)],
            capital: "150"
        )
        
        dataHandler.add(entry: RestakeBakerData(restake: false))
        
        assertStateEqual(
            account: account,
            dataHandler: dataHandler,
            transferType: .updateBakerStake,
            costParameters: [.amount(nil), .restake],
            capital: "150",
            restakeEarnings: false
        )
        
        dataHandler.add(entry: BakerAmountData(amount: GTU(intValue: 125)))
        dataHandler.add(entry: RestakeBakerData(restake: true))
        
        assertStateEqual(
            account: account,
            dataHandler: dataHandler,
            transferType: .updateBakerStake,
            costParameters: []
        )
    }
    
    func testUpdateBakerStakeWarnings() {
        let poolInfo = PoolInfo(
            commissionRates: CommissionRates(
                transactionCommission: 0.5,
                finalizationCommission: 1.0,
                bakingCommission: 1.5
            ),
            openStatus: "openForAll",
            metadataURL: "https://example.com"
        )
        let baker = TestBaker(stakedAmount: 125, restakeEarnings: true, pendingChange: nil)
        let atDisposal = 200
        let dataHandler = BakerDataHandler(account: testAccount, action: .updateBakerStake(baker, poolInfo))
        
        XCTAssertEqual(dataHandler.getCurrentWarning(atDisposal: atDisposal), .noChanges)
        
        dataHandler.add(entry: BakerAmountData(amount: GTU(intValue: 0)))
        
        XCTAssertEqual(dataHandler.getCurrentWarning(atDisposal: atDisposal), .amountZero)
        
        dataHandler.add(entry: BakerAmountData(amount: GTU(intValue: 310)))
        
        XCTAssertEqual(dataHandler.getCurrentWarning(atDisposal: atDisposal), .moreThan95)
        
        dataHandler.add(entry: BakerAmountData(amount: GTU(intValue: 100)))
        
        XCTAssertEqual(dataHandler.getCurrentWarning(atDisposal: atDisposal), .loweringStake)
        
        dataHandler.add(entry: BakerAmountData(amount: GTU(intValue: 300)))
        
        XCTAssertEqual(dataHandler.getCurrentWarning(atDisposal: atDisposal), nil)
    }
    
    func testUpdatePoolSettingsData() {
        let poolInfo = PoolInfo(
            commissionRates: CommissionRates(
                transactionCommission: 0.5,
                finalizationCommission: 1.0,
                bakingCommission: 1.5
            ),
            openStatus: "openForAll",
            metadataURL: "https://example.com"
        )
        let baker = TestBaker(stakedAmount: 125, restakeEarnings: true, pendingChange: nil)
        let account = testAccount
        let dataHandler = BakerDataHandler(account: account, action: .updatePoolSettings(baker, poolInfo))
        
        dataHandler.add(entry: BakerPoolSettingsData(poolSettings: .closed))
        dataHandler.add(entry: BakerMetadataURLData(metadataURL: ""))
        
        assertStateEqual(
            account: account,
            dataHandler: dataHandler,
            transferType: .updateBakerPool,
            costParameters: [.openStatus, .metadataSize(0)],
            openStatus: "closedForAll",
            metadataURL: ""
        )
        
        dataHandler.add(entry: BakerPoolSettingsData(poolSettings: .closedForNew))
        dataHandler.add(entry: BakerMetadataURLData(metadataURL: "https://example.com"))
        
        assertStateEqual(
            account: account,
            dataHandler: dataHandler,
            transferType: .updateBakerPool,
            costParameters: [.openStatus],
            openStatus: "closedForNew"
        )
        
        dataHandler.add(entry: BakerPoolSettingsData(poolSettings: .open))
        dataHandler.add(entry: BakerMetadataURLData(metadataURL: "https://metadata.com"))
        
        assertStateEqual(
            account: account,
            dataHandler: dataHandler,
            transferType: .updateBakerPool,
            costParameters: [.metadataSize("https://metadata.com".count)],
            metadataURL: "https://metadata.com"
        )
    }
    
    func testRegisterBakerDisplayValues() {
        let account = testAccount
        let keys = GeneratedBakerKeys.randomKeys
        let amount = GTU(intValue: 125)
        let dataHandler = BakerDataHandler(account: account, action: .register)
        
        dataHandler.add(entry: BakerAmountData(amount: amount))
        dataHandler.add(entry: RestakeBakerData(restake: true))
        dataHandler.add(entry: BakerPoolSettingsData(poolSettings: .closed))
        dataHandler.add(entry: BakerKeyData(keys: keys))
        
        let closedDisplayValues = dataHandler.getAllOrdered()
        
        assertDisplayValues(
            actualValues: closedDisplayValues,
            expectedValues: [
                DisplayValue(key: "Account to register as baker", value: "\(account.name ?? "")\n\n\(account.address)"),
                DisplayValue(key: "Baker stake", value: amount.displayValueWithGStroke()),
                DisplayValue(key: "Rewards will be", value: "Added to stake"),
                DisplayValue(key: "Delegation pool status", value: "Closed for delegation"),
                DisplayValue(key: "Election verify key", value: keys.electionVerifyKey.splitInto(lines: 2)),
                DisplayValue(key: "Signature verify key", value: keys.signatureVerifyKey.splitInto(lines: 2)),
                DisplayValue(key: "Aggregation verify key", value: keys.aggregationVerifyKey.splitInto(lines: 6))
            ]
        )
    }
    
    func testUpdatePoolSettingsMetadataDisplayValues() {
        let poolInfo = PoolInfo(
            commissionRates: CommissionRates(
                transactionCommission: 0.5,
                finalizationCommission: 1.0,
                bakingCommission: 1.5
            ),
            openStatus: "openForAll",
            metadataURL: "https://example.com"
        )
        let baker = TestBaker(stakedAmount: 125, restakeEarnings: true, pendingChange: nil)
        let account = testAccount
        let dataHandler = BakerDataHandler(account: account, action: .updatePoolSettings(baker, poolInfo))
        
        XCTAssert(!dataHandler.getAllOrdered().contains { $0.key == "Metadata URL" })
        
        dataHandler.add(entry: BakerMetadataURLData(metadataURL: ""))
        
        XCTAssert(dataHandler.getAllOrdered().contains { $0.key == "Metadata URL" && $0.value == "Metadata URL removed" })
        
        dataHandler.add(entry: BakerMetadataURLData(metadataURL: "https://newurl.com"))
        
        XCTAssert(dataHandler.getAllOrdered().contains { $0.key == "Metadata URL" && $0.value == "https://newurl.com" })
    }
    
    func testUpdateBakerKeys() {
        let poolInfo = PoolInfo(
            commissionRates: CommissionRates(
                transactionCommission: 0.5,
                finalizationCommission: 1.0,
                bakingCommission: 1.5
            ),
            openStatus: "openForAll",
            metadataURL: "https://example.com"
        )
        let baker = TestBaker(stakedAmount: 125, restakeEarnings: true, pendingChange: nil)
        let account = testAccount
        let dataHandler = BakerDataHandler(account: account, action: .updateBakerKeys(baker, poolInfo))
        
        dataHandler.add(entry: BakerKeyData(keys: .randomKeys))
        
        assertStateEqual(
            account: account,
            dataHandler: dataHandler,
            transferType: .updateBakerKeys,
            costParameters: []
        )
    }
    
    private func assertDisplayValues(
        actualValues: [DisplayValue],
        expectedValues: [DisplayValue],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard actualValues.count == expectedValues.count else {
            XCTFail("Expected \(expectedValues.count) display values found \(actualValues.count)", file: file, line: line)
            
            return
        }
        
        for (index, value) in actualValues.enumerated() {
            XCTAssertEqual(value, expectedValues[index], "Expected \(expectedValues[index]) at \(index) found \(value)", file: file, line: line)
        }
    }
    
    private func assertStateEqual(
        account: AccountDataType,
        dataHandler: StakeDataHandler,
        transferType: TransferType,
        costParameters: [TransferCostParameter],
        capital: String? = "",
        restakeEarnings: Bool? = nil,
        openStatus: String? = nil,
        metadataURL: String? = nil,
        bakingRewardsComission: Double = -1,
        finalizationRewardsComission: Double = -1,
        transactionFeeComission: Double = -1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let cost = GTU(intValue: 3)
        let energy = 25
        
        XCTAssertEqual(dataHandler.transferType, transferType, file: file, line: line)
        XCTAssert(dataHandler.getCostParameters().allSatisfy(costParameters.contains(_:)), file: file, line: line)
        
        let transfer = dataHandler.getTransferObject(cost: cost, energy: energy)
        
        XCTAssertEqual(transfer.fromAddress, account.address, file: file, line: line)
        XCTAssertEqual(transfer.cost, String(cost.intValue), file: file, line: line)
        XCTAssertEqual(transfer.energy, energy, file: file, line: line)
        XCTAssertEqual(transfer.capital, capital, file: file, line: line)
        XCTAssertEqual(transfer.restakeEarnings, restakeEarnings, file: file, line: line)
        XCTAssertEqual(transfer.openStatus, openStatus, file: file, line: line)
        XCTAssertEqual(transfer.metadataURL, metadataURL, file: file, line: line)
        XCTAssertEqual(transfer.bakingRewardCommission, bakingRewardsComission, file: file, line: line)
        XCTAssertEqual(transfer.finalizationRewardCommission, finalizationRewardsComission, file: file, line: line)
        XCTAssertEqual(transfer.transactionFeeCommission, transactionFeeComission, file: file, line: line)
    }
}

private extension GeneratedBakerKeys {
    static var randomKeys: GeneratedBakerKeys {
        let allowedCharacters = "abcdefghijklmnopqrstuvxyz1234567890"
        let randomKey = { (length: Int) -> String in
            String(
                (0..<length)
                    .compactMap { _ in allowedCharacters.randomElement() }
            )
        }
        
        return GeneratedBakerKeys(
            electionVerifyKey: randomKey(16),
            electionPrivateKey: randomKey(16),
            signatureVerifyKey: randomKey(16),
            signatureSignKey: randomKey(16),
            aggregationVerifyKey: randomKey(32),
            aggregationSignKey: randomKey(32)
        )
    }
}

private struct AddressOnlyAccount: AccountDataType {
    var name: String? = "Test"
    var displayName: String = ""
    var address: String = "abcdefg123456"
    var accountIndex: Int = 0
    var submissionId: String?
    var transactionStatus: SubmissionStatusEnum?
    var encryptedAccountData: String?
    var encryptedPrivateKey: String?
    var encryptedCommitmentsRandomness: String?
    var identity: IdentityDataType?
    var revealedAttributes: [String: String] = [:]
    var finalizedBalance: Int = 0
    var forecastBalance: Int = 0
    var forecastAtDisposalBalance: Int = 0
    var finalizedEncryptedBalance: Int = 0
    var forecastEncryptedBalance: Int = 0
    var totalForecastBalance: Int = 0
    var encryptedBalance: EncryptedBalanceDataType?
    var encryptedBalanceStatus: ShieldedAccountEncryptionStatus?
    var accountNonce: Int = 0
    var credential: Credential?
    var createdTime: Date = Date()
    var usedIncomingAmountIndex: Int = 0
    var isReadOnly: Bool = false
    var baker: BakerDataType?
    var delegation: DelegationDataType?
    var releaseSchedule: ReleaseScheduleDataType?
    var transferFilters: TransferFilter?
    var showsShieldedBalance: Bool = false
    var hasShieldedTransactions: Bool = false
    
    func write(code: (AddressOnlyAccount) -> Void) -> Result<Void, Error> {
        return .success(())
    }
}

private struct TestBaker: BakerDataType {
    var bakerID: Int = 1
    var stakedAmount: Int
    var restakeEarnings: Bool
    var bakerElectionVerifyKey: String = ""
    var bakerSignatureVerifyKey: String = ""
    var bakerAggregationVerifyKey: String = ""
    var pendingChange: PendingChangeDataType?
    
    func write(code: (TestBaker) -> Void) -> Result<Void, Error> {
        return .success(())
    }
}
