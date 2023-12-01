//
//  BigInt+String.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 20/09/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import XCTest
@testable import Mock
import BigInt
class IntegerFormattingTests: XCTestCase {

    func testFormattingWithTrailingZeros() {
        XCTAssertEqual(BigInt(12345000000).formatIntegerWithFractionDigits(fractionDigits: 6), "12345")
        XCTAssertEqual(BigInt(12345000000).formatIntegerWithFractionDigits(fractionDigits: 7), "1234,5")
    }
    
    func testEdgeCases() {
        XCTAssertEqual(BigInt(0).formatIntegerWithFractionDigits(fractionDigits: 2), "0")
        XCTAssertEqual(BigInt(0).formatIntegerWithFractionDigits(fractionDigits: 0), "0")
    }
}
