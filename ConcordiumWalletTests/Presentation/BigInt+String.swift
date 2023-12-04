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
        XCTAssertEqual(BigInt(12345000000).format(implicitDecimals: 6, minDecimals: 3), "12345,000")
        XCTAssertEqual(BigInt(12345000000).format(implicitDecimals: 5, minDecimals: 1), "123450,0")
    }
    
    func testEdgeCases() {
        XCTAssertEqual(BigInt(0).format(implicitDecimals: 6, minDecimals: 3), "0,000")
        XCTAssertEqual(BigInt(0).format(implicitDecimals: 0), "0")
        XCTAssertEqual(BigInt(0).format(implicitDecimals: 0, minDecimals: 3), "0")
        XCTAssertEqual(BigInt(12345).format(implicitDecimals: 0, minDecimals: 3), "12345")
        XCTAssertEqual(BigInt(-12345).format(implicitDecimals: 4, minDecimals: 3), "-1,2345")
        XCTAssertEqual(BigInt(-12345).format(implicitDecimals: -4, minDecimals: 3), "-1,2345")
    }
}
