//
//  AmountInputValidatorTests.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 08/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import XCTest
@testable import Mock

class AmountInputValidatorTests: XCTestCase {
    func testReleaseTotalCanBeUsedForStakingButNotFee() {
        let validator = StakeAmountInputValidator(
            minimumValue: GTU(intValue: 0),
            balance: GTU(intValue: 500),
            atDisposal: GTU(intValue: 10),
            releaseSchedule: GTU(intValue: 490),
            previouslyStakedInPool: GTU(intValue: 0)
        )
        
        XCTAssertEqual(
            validator.validate(amount: GTU(intValue: 300), fee: GTU(intValue: 8)),
            .success(GTU(intValue: 300))
        )
        
        XCTAssertEqual(
            validator.validate(amount: GTU(intValue: 300), fee: GTU(intValue: 15)),
            .failure(.notEnoughFund(GTU(intValue: 10)))
        )
    }
}
