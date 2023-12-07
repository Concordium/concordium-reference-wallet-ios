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

    func test_FungibleToken_throws_when_fractional_part_too_long() {
        XCTAssertThrowsError(try FungibleToken.parse(input: "1,23", decimals: 1, symbol: nil)) { error in
            XCTAssertEqual(error as! FungibleTokenParseError, FungibleTokenParseError.fractionPartTooLong)
        }
    }

    func test_input_with_too_many_decimal_places_throws_fractionPartTooLong() {
        do {
            _ = try FungibleToken.parse(input: "12\(sep)3456", decimals: 2, symbol: "LMN")
            XCTFail("expected_error_not_thrown")
        } catch let error as FungibleTokenParseError {
            XCTAssertEqual(error, .fractionPartTooLong)
        } catch {
            XCTFail("unexpected_error: \(error.localizedDescription)")
        }
    }

    func test_invalid_input_non_numeric_characters_throws_invalidInput_exception() {
        do {
            _ = try FungibleToken.parse(input: "abc", decimals: 2, symbol: "XYZ")
            XCTFail("expected_error_not_thrown")
        } catch let error as FungibleTokenParseError {
            XCTAssertEqual(error, .invalidInput)
        } catch {
            XCTFail("unexpected_error: \(error.localizedDescription)")
        }
    }

    func test_input_with_negative_decimals_count_throws_negativeDecimals_exception() {
        do {
            _ = try FungibleToken.parse(input: "-456.789", decimals: -3, symbol: "PQR")
            XCTFail("expected_error_not_thrown")
        } catch let error as FungibleTokenParseError {
            XCTAssertEqual(error, .negativeDecimals)
        } catch {
            XCTFail("unexpected_error: \(error.localizedDescription)")
        }
    }

    func test_display_value_with_decimal_separator() {
        let token = FungibleToken(intValue: BigInt(123456), decimals: 3, symbol: "ABC")
        XCTAssertEqual(token.displayValue, "123\(sep)456 ABC")
    }

    func test_display_value_with_zero_decimals() {
        let token = FungibleToken(intValue: BigInt(987654), decimals: 0, symbol: "LMN")
        XCTAssertEqual(token.displayValue, "987654 LMN")
    }

    func test_display_value_with_negative_value() {
        let token = FungibleToken(intValue: BigInt(-123456), decimals: 3, symbol: "PQR")
        XCTAssertEqual(token.displayValue, "-123\(sep)456 PQR")
    }
}
