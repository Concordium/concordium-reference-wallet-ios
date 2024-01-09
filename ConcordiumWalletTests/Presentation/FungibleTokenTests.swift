//
//  BigInt+String.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 20/09/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import BigInt
@testable import Mock
import XCTest
class FungibleTokenTests: XCTestCase {
    let sep = NumberFormatter().decimalSeparator!

    func test_input_with_too_many_decimal_places_throws_fractionPartTooLong() {
        XCTAssertThrowsError(try FungibleToken.parse(input: "12\(sep)3456", decimals: 2, symbol: "CCD")) { error in
            XCTAssertEqual(error as! FungibleTokenParseError, .fractionPartTooLong)
        }
    }
    
    func test_input_with_fractional_part_shorter_than_decimals_value() throws {
        let token = try FungibleToken.parse(input: "12\(sep)123", decimals: 6, symbol: "CCD")
        XCTAssertEqual(token.formattedString(minDecimalDigits: 12), "12\(sep)123000")
    }
    
    func test_input_containing_only_zeros() throws {
        let token1 = try FungibleToken.parse(input: "0", decimals: 3, symbol: "CCD")
        XCTAssertEqual(token1.displayValue, "0\(sep)000 CCD")
        
        let token2 = try FungibleToken.parse(input: "00\(sep)00", decimals: 3, symbol: "CCD")
        XCTAssertEqual(token2.displayValue, "0\(sep)000 CCD")

        let token3 = try FungibleToken.parse(input: "0\(sep)000", decimals: 3, symbol: "CCD")
        XCTAssertEqual(token3.displayValue, "0\(sep)000 CCD")
    }

    func test_invalid_input_non_numeric_characters_throws_invalidInput_exception() {
        XCTAssertThrowsError(try FungibleToken.parse(input: "abc", decimals: 2, symbol: "CCD")) { error in
            XCTAssertEqual(error as! FungibleTokenParseError, FungibleTokenParseError.invalidInput)
        }
    }

    func test_input_with_negative_decimals_count_throws_negativeDecimals_exception() {
        do {
            _ = try FungibleToken.parse(input: "-456\(sep)789", decimals: -3, symbol: "CCD")
            XCTFail("expected_error_not_thrown")
        } catch let error as FungibleTokenParseError {
            XCTAssertEqual(error, .negativeDecimals)
        } catch {
            XCTFail("unexpected_error: \(error.localizedDescription)")
        }
    }

    func test_display_value_with_decimal_separator() {
        let token = FungibleToken(intValue: BigInt(123456), decimals: 3, symbol: "CCD")
        XCTAssertEqual(token.displayValue, "123\(sep)456 CCD")
    }

    func test_display_value_with_zero_decimals() {
        let token = FungibleToken(intValue: BigInt(987654), decimals: 0, symbol: "CCD")
        XCTAssertEqual(token.displayValue, "987654 CCD")
    }

    func test_display_value_with_negative_value() {
        let token = FungibleToken(intValue: BigInt(-123456), decimals: 3, symbol: "CCD")
        XCTAssertEqual(token.displayValue, "-123\(sep)456 CCD")
    }
    
    func test_numbers_without_fractional_part() throws {
        let token1 = try FungibleToken.parse(input: "10000", decimals: 3, symbol: "CCD")
        XCTAssertEqual(token1.displayValue, "10000\(sep)000 CCD")
        
        let token2 = try FungibleToken.parse(input: "10000", decimals: 0, symbol: "CCD")
        XCTAssertEqual(token2.displayValue, "10000 CCD")
    }
}
