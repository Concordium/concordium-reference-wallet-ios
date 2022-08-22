//
//  Combine+TestHelpers.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Combine
import XCTest

extension XCTestCase {
    func XCTAssertEmits<P: Publisher>(
        _ publisher: P,
        _ elements: [P.Output],
        timeout: TimeInterval = 5.0,
        file: StaticString = #file,
        line: UInt = #line
    ) where P.Output: Equatable {
        XCTAssertEqual(waitForElements(from: publisher, timeout: timeout), elements, file: file, line: line)
    }
    
    func XCTAssertEmits<P: Publisher>(
        _ publisher: P,
        timeout: TimeInterval = 5.0,
        file: StaticString = #file,
        line: UInt = #line,
        verification: ([P.Output]) -> Bool
    ) {
        XCTAssert(verification(waitForElements(from: publisher, timeout: timeout)), file: file, line: line)
    }
    
    func XCTAssertReceivesValue<T: Equatable>(
        _ publisher: Published<T>.Publisher,
        _ element: T,
        timeout: TimeInterval = 5.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var cancellables = Set<AnyCancellable>()
        var emittedValues = [T]()
        var hasEmittedTarget = false
        
        let publisherExpectation = expectation(description: "Publisher Expectation")
        
        publisher
            .sink { value in
                if value == element {
                    emittedValues.append(value)
                    hasEmittedTarget = true
                    publisherExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: timeout) { _ in
            XCTAssert(
                hasEmittedTarget,
                "Expected \(element), received \(emittedValues)",
                file: file,
                line: line
            )
        }
    }
    
    private func waitForElements<P: Publisher>(from publisher: P, timeout: TimeInterval) -> [P.Output] {
        var cancellables = Set<AnyCancellable>()
        var emittedElements: [P.Output]?
        
        let publisherExpectation = expectation(description: "Publisher Expectation")
        
        publisher.collect()
            .sink(
                receiveError: { _ in
                    publisherExpectation.fulfill()
                },
                receiveValue: { values in
                    emittedElements = values
                }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: timeout)
        
        return emittedElements ?? []
    }
}

extension PassthroughSubject {
    func bindLatestValue(to cancellables: inout Set<AnyCancellable>) -> CurrentValueSubject<Output?, Failure> {
        let subject = CurrentValueSubject<Output?, Failure>(nil)
        
        sink(
            receiveCompletion: { completion in
                subject.send(completion: completion)
            },
            receiveValue: { value in
                subject.send(value)
            }
        ).store(in: &cancellables)
        
        return subject
    }
}
