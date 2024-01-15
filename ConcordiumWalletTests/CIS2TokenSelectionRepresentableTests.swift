//
//  CIS2TokenSelectionRepresentableTests.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 08/12/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import BigInt
@testable import Mock
import XCTest
extension CIS2TokenSelectionRepresentable {
    static func mock(
        contractName: String = "",
        tokenId: String = "",
        balance: BigInt = 0,
        contractIndex: String = "",
        name: String = "a",
        symbol: String? = nil,
        decimals: Int = 6,
        description: String = "",
        thumbnail: URL? = nil,
        unique: Bool = false,
        accountAddress: String = "",
        dateAdded: Date? = Date()
    ) -> CIS2TokenSelectionRepresentable {
        .init(contractName: contractName, tokenId: tokenId, balance: balance, contractIndex: contractIndex, name: name, symbol: symbol, decimals: decimals, description: description, thumbnail: thumbnail, unique: unique, accountAddress: accountAddress, dateAdded: dateAdded)
    }
}

final class CIS2TokenSelectionRepresentableTests: XCTestCase {
    // Test case where both elements have a date
    func test_sort_success_with_all_items_have_date_from_oldest_to_newest() {
        let element1 = CIS2TokenSelectionRepresentable.mock(name: "A", dateAdded: Date(timeIntervalSince1970: 100))
        let element2 = CIS2TokenSelectionRepresentable.mock(name: "B", dateAdded: Date(timeIntervalSince1970: 200))
        let element3 = CIS2TokenSelectionRepresentable.mock(name: "C", dateAdded: Date(timeIntervalSince1970: 300))
        let element4 = CIS2TokenSelectionRepresentable.mock(name: "D", dateAdded: Date(timeIntervalSince1970: 400))
        let element5 = CIS2TokenSelectionRepresentable.mock(name: "E", dateAdded: Date(timeIntervalSince1970: 600))
        let element6 = CIS2TokenSelectionRepresentable.mock(name: "F", dateAdded: Date(timeIntervalSince1970: 700))
        let array = [element6, element2, element5, element3, element4, element1].shuffled()
        let sortedArray = array.sorted()

        XCTAssertEqual(sortedArray, [element1, element2, element3, element4, element5, element6])
    }
    
    // Test case where both elements have a date
    func test_sort_success_with_mixed_items_should_sort_by_date_first_then_alphabetically() {
        let element1 = CIS2TokenSelectionRepresentable.mock(name: "Third", dateAdded: Date(timeIntervalSince1970: 600)) // 3
        let element2 = CIS2TokenSelectionRepresentable.mock(name: "Second", dateAdded: Date(timeIntervalSince1970: 200)) // 2
        let element3 = CIS2TokenSelectionRepresentable.mock(name: "I should be first", dateAdded: Date(timeIntervalSince1970: 100)) // 1
        let element4 = CIS2TokenSelectionRepresentable.mock(name: "Alpabetically", dateAdded: nil) // 4
        let element5 = CIS2TokenSelectionRepresentable.mock(name: "Sorted", dateAdded: nil) // 6
        let element6 = CIS2TokenSelectionRepresentable.mock(name: "Bee", dateAdded: nil) // 5
        let array = [element6, element2, element5, element3, element4, element1].shuffled()
        let sortedArray = array.sorted()

        XCTAssertEqual(sortedArray, [element3, element2, element1, element4, element6, element5])
    }
    
    func test_sort_success_with_all_items_with_no_date_should_be_sorted_alphabetically() {
        let element1 = CIS2TokenSelectionRepresentable.mock(name: "Third. Just kidding. I am last.", dateAdded: nil) // 6
        let element2 = CIS2TokenSelectionRepresentable.mock(name: "Data", dateAdded: nil) // 3
        let element3 = CIS2TokenSelectionRepresentable.mock(name: "I should be fourth", dateAdded: nil) // 4
        let element4 = CIS2TokenSelectionRepresentable.mock(name: "Alpabetically", dateAdded: nil) // 1
        let element5 = CIS2TokenSelectionRepresentable.mock(name: "Sorted", dateAdded: nil) // 5
        let element6 = CIS2TokenSelectionRepresentable.mock(name: "Better be second.", dateAdded: nil) // 2
        let array = [element6, element2, element5, element3, element4, element1].shuffled()
        let sortedArray = array.sorted()

        XCTAssertEqual(sortedArray, [element4, element6, element2, element3, element5, element1])
    }
    
    func test_sort_success_with_only_item_contains_date_should_be_shown_first() {
        let element1 = CIS2TokenSelectionRepresentable.mock(name: "Third. Just kidding. I am last.", dateAdded: nil) // 7
        let element2 = CIS2TokenSelectionRepresentable.mock(name: "Data", dateAdded: nil) // 4
        let element3 = CIS2TokenSelectionRepresentable.mock(name: "I should be fourth", dateAdded: nil) // 5
        let element4 = CIS2TokenSelectionRepresentable.mock(name: "Alpabetically", dateAdded: nil) // 2
        let element5 = CIS2TokenSelectionRepresentable.mock(name: "Sorted", dateAdded: nil) // 6
        let element6 = CIS2TokenSelectionRepresentable.mock(name: "Better be second.", dateAdded: nil) // 3
        let element7 = CIS2TokenSelectionRepresentable.mock(name: "I will be first because I have date", dateAdded: Date()) // 1

        let array = [element6, element2, element5, element3, element4, element1, element7].shuffled()
        let sortedArray = array.sorted()

        XCTAssertEqual(sortedArray, [element7, element4, element6, element2, element3, element5, element1])
    }
}
