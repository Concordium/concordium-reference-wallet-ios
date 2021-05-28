//
// Created by Concordium on 21/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import XCTest
@testable import ProdMainNet

class GTUTests: XCTestCase {

    let decimalSeparator = NumberFormatter().decimalSeparator!

    func testFormatGtu() {
        XCTAssertEqual(GTU(intValue: 1000000).displayValue(), replaceDecimalSep("1.00"))
        XCTAssertEqual(GTU(intValue: 100000000).displayValue(), replaceDecimalSep("100.00"))
        XCTAssertEqual(GTU(intValue: 1200000).displayValue(), replaceDecimalSep("1.20"))
        XCTAssertEqual(GTU(intValue: 1230000).displayValue(), replaceDecimalSep("1.23"))
        XCTAssertEqual(GTU(intValue: 1234000).displayValue(), replaceDecimalSep("1.234"))
        XCTAssertEqual(GTU(intValue: 1234500).displayValue(), replaceDecimalSep("1.2345"))
        XCTAssertEqual(GTU(intValue: 123456700).displayValue(), replaceDecimalSep("123.4567"))
        XCTAssertEqual(GTU(intValue: 1234567000).displayValue(), replaceDecimalSep("1234.567"))
        XCTAssertEqual(GTU(intValue: 12345670000).displayValue(), replaceDecimalSep("12345.67"))
        XCTAssertEqual(GTU(intValue: 123456700000).displayValue(), replaceDecimalSep("123456.70"))
        XCTAssertEqual(GTU(intValue: 1234567000000).displayValue(), replaceDecimalSep("1234567.00"))
        XCTAssertEqual(GTU(intValue: 100).displayValue(), replaceDecimalSep("0.0001"))
        XCTAssertEqual(GTU(intValue: 1000).displayValue(), replaceDecimalSep("0.001"))
        XCTAssertEqual(GTU(intValue: 10000).displayValue(), replaceDecimalSep("0.01"))
        XCTAssertEqual(GTU(intValue: 100000).displayValue(), replaceDecimalSep("0.10"))
//
        XCTAssertEqual(GTU(intValue: 0).displayValue(), replaceDecimalSep("0.00"))
        XCTAssertEqual(GTU(intValue: -1).displayValue(), replaceDecimalSep("-0.000001"))
        XCTAssertEqual(GTU(intValue: -10).displayValue(), replaceDecimalSep("-0.00001"))
        XCTAssertEqual(GTU(intValue: -100).displayValue(), replaceDecimalSep("-0.0001"))
        XCTAssertEqual(GTU(intValue: -1000).displayValue(), replaceDecimalSep("-0.001"))
        XCTAssertEqual(GTU(intValue: -10000).displayValue(), replaceDecimalSep("-0.01"))
        XCTAssertEqual(GTU(intValue: -100000).displayValue(), replaceDecimalSep("-0.10"))
    }

    func testFormatGtuWithGStroke() {
        XCTAssertEqual(GTU(intValue: 1).displayValueWithGStroke(), replaceDecimalSep("Ǥ0.000001"))
        XCTAssertEqual(GTU(intValue: 10).displayValueWithGStroke(), replaceDecimalSep("Ǥ0.00001"))
        XCTAssertEqual(GTU(intValue: 100).displayValueWithGStroke(), replaceDecimalSep("Ǥ0.0001"))
        XCTAssertEqual(GTU(intValue: 1000).displayValueWithGStroke(), replaceDecimalSep("Ǥ0.001"))
        XCTAssertEqual(GTU(intValue: 10000).displayValueWithGStroke(), replaceDecimalSep("Ǥ0.01"))
        XCTAssertEqual(GTU(intValue: 100000).displayValueWithGStroke(), replaceDecimalSep("Ǥ0.10"))

        XCTAssertEqual(GTU(intValue: 0).displayValueWithGStroke(), replaceDecimalSep("Ǥ0.00"))
        XCTAssertEqual(GTU(intValue: -1).displayValueWithGStroke(), replaceDecimalSep("-Ǥ0.000001"))
        XCTAssertEqual(GTU(intValue: -10).displayValueWithGStroke(), replaceDecimalSep("-Ǥ0.00001"))
        XCTAssertEqual(GTU(intValue: -100).displayValueWithGStroke(), replaceDecimalSep("-Ǥ0.0001"))
        XCTAssertEqual(GTU(intValue: -1000).displayValueWithGStroke(), replaceDecimalSep("-Ǥ0.001"))
        XCTAssertEqual(GTU(intValue: -10000).displayValueWithGStroke(), replaceDecimalSep("-Ǥ0.01"))
        XCTAssertEqual(GTU(intValue: -100000).displayValueWithGStroke(), replaceDecimalSep("-Ǥ0.10"))
    }

    func testStringToGtu() {
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("1.00")).intValue, 1000000)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("100.00")).intValue, 100000000)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("1.20")).intValue, 1200000)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("1.23")).intValue, 1230000)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("1.2340")).intValue, 1234000)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("1.2345")).intValue, 1234500)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("123.4567")).intValue, 123456700)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("0.0001")).intValue, 100)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("0.0010")).intValue, 1000)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("0.01")).intValue, 10000)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("0.10")).intValue, 100000)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("0.000001")).intValue, 1)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("0.0000001")).intValue, 0)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("1.0000001")).intValue, 1000000)

        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("-0.00")).intValue, 0)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("-0.01")).intValue, -10000)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("-0.10")).intValue, -100000)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("-0.000001")).intValue, -1)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("-0.0000001")).intValue, 0)
        XCTAssertEqual(GTU(displayValue: replaceDecimalSep("-1.0000001")).intValue, -1000000)
    }

    private func replaceDecimalSep(_ str: String) -> String {
        if decimalSeparator != "." {
            return str.replacingOccurrences(of: ".", with: decimalSeparator)
        }
        return str
    }
}
