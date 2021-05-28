//
//  GeneralFormatterTests.swift
//  ConcordiumWalletTests
//
//  Created by Concordium on 01/07/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import XCTest
@testable import ProdMainNet

class GeneralFormatterTests: XCTestCase {
    func testDateFormatting() throws {
        XCTAssertEqual(GeneralFormatter.formatISO8601Date(date: "202009"),
                       "September, 2020")
        XCTAssertEqual(GeneralFormatter.formatISO8601Date(date: "20200903", hasDay: true, outputFormat: "ddMMyyyy"),
                       "03092020")
        XCTAssertEqual(GeneralFormatter.formatISO8601Date(date: "**********"),
                       "**********")
    }
}
