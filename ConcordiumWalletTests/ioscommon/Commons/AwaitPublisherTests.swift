//
//  AwaitPublisherTests.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 12/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import XCTest
import Combine
@testable import Mock

class AwaitPublisherTests: XCTestCase {
    func test_an_awaited_publisher_will_return_the_first_element() async throws {
        let publisher = Just("Hello")
        
        let output = try await publisher.awaitFirst()
        
        XCTAssertEqual(output, "Hello")
    }
    
    func test_an_empty_publisher_throws_if_awaited() async {
        do {
            _ = try await Empty<Void, Error>().awaitFirst()
            XCTFail("Empty publisher should throw on await")
        } catch {
            XCTAssert(error is MissingOutput)
        }
    }
    
    func test_a_failed_publisher_throws_if_awaited() async {
        do {
            _ = try await Fail(outputType: Void.self, failure: TestError()).awaitFirst()
            XCTFail("Fail publisher should throw on await")
        } catch {
            XCTAssert(error is TestError)
        }
    }
}

private struct TestError: Error {}
