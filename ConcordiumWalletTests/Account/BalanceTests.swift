//
//  BalanceTests.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 21/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import XCTest
@testable import Mock

class Balancetests: XCTestCase {
    struct AtDisposalCase {
        let forecastBalance: Int
        let scheduledTotal: Int?
        let stakedAmount: Int?
        let expectedAtDisposal: Int
        let file: StaticString
        let line: UInt
        
        init(
            forecastBalance: Int,
            scheduledTotal: Int? = nil,
            stakedAmount: Int? = nil,
            expectedAtDisposal: Int,
            file: StaticString = #file,
            line: UInt = #line
        ) {
            self.forecastBalance = forecastBalance
            self.scheduledTotal = scheduledTotal
            self.stakedAmount = stakedAmount
            self.expectedAtDisposal = expectedAtDisposal
            self.file = file
            self.line = line
        }
        
        func assert() {
            var account: AccountDataType = AccountEntity()
                .withUpdatedForecastBalance(forecastBalance, forecastShieldedBalance: 0)
            
            if let scheduledTotal = scheduledTotal {
                account = account.with(releaseSchedule: ReleaseScheduleEntity.fromTotal(scheduledTotal))
            }
            if let stakedAmount = stakedAmount {
                account = account.with(delegation: DelegationEntity.fromStake(stakedAmount))
            }
            
            XCTAssertEqual(account.forecastAtDisposalBalance, expectedAtDisposal, file: file, line: line)
        }
    }
    
    func test_at_disposal() {
        let cases = [
            AtDisposalCase(forecastBalance: 100_000, expectedAtDisposal: 100_000),
            AtDisposalCase(forecastBalance: 100_000, scheduledTotal: 5_000, expectedAtDisposal: 95_000),
            AtDisposalCase(forecastBalance: 100_000, stakedAmount: 5_000, expectedAtDisposal: 95_000),
            AtDisposalCase(forecastBalance: 100_000, scheduledTotal: 5_000, stakedAmount: 5_000, expectedAtDisposal: 100_000),
            AtDisposalCase(forecastBalance: 100_000, scheduledTotal: 3_000, stakedAmount: 5_000, expectedAtDisposal: 98_000),
            AtDisposalCase(forecastBalance: 100_000, scheduledTotal: 5_000, stakedAmount: 3_000, expectedAtDisposal: 95_000)
        ]
        
        for testCase in cases {
            testCase.assert()
        }
    }
}

private extension AccountDataType {
    func with(releaseSchedule: ReleaseScheduleDataType) -> AccountDataType {
        return withUpdatedFinalizedBalance(
            finalizedBalance,
            finalizedEncryptedBalance,
            encryptedBalanceStatus ?? .encrypted,
            encryptedBalance ?? EncryptedBalanceEntity(),
            hasShieldedTransactions: hasShieldedTransactions,
            accountNonce: accountNonce,
            accountIndex: accountIndex,
            delegation: delegation,
            baker: baker,
            releaseSchedule: releaseSchedule
        )
    }
    
    func with(delegation: DelegationDataType) -> AccountDataType {
        return withUpdatedFinalizedBalance(
            finalizedBalance,
            finalizedEncryptedBalance,
            encryptedBalanceStatus ?? .encrypted,
            encryptedBalance ?? EncryptedBalanceEntity(),
            hasShieldedTransactions: hasShieldedTransactions,
            accountNonce: accountNonce,
            accountIndex: accountIndex,
            delegation: delegation,
            baker: baker,
            releaseSchedule: releaseSchedule ?? ReleaseScheduleEntity()
        )
    }
}

private extension DelegationEntity {
    static func fromStake(_ amount: Int) -> DelegationEntity {
        return DelegationEntity(
            accountDelegationModel: AccountDelegation(
                stakedAmount: "\(amount)",
                restakeEarnings: true,
                delegationTarget: DelegationTarget(delegateType: "Passive", bakerID: nil),
                pendingChange: nil
            )
        )
    }
}

private extension ReleaseScheduleEntity {
    static func fromTotal(_ amount: Int) -> ReleaseScheduleEntity {
        return ReleaseScheduleEntity(
            from: AccountReleaseSchedule(
                schedule: [],
                total: "\(amount)"
            )
        )
    }
}
