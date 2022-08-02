//
//  IdentityRecoveryTests.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import XCTest
import Combine
@testable import Mock

class IdentityRecoveryTests: XCTestCase {
    func test_presenter_is_initially_fecthing() throws {
        let presenter = try createPresenter()
        
        XCTAssertEqual(presenter.viewModel.status, .fetching)
    }
    
    func test_an_alert_is_presented_when_the_identity_request_fails() throws {
        var cancellables = Set<AnyCancellable>()
        let service = MockService()
        let presenter = try createPresenter(service: service)
        
        let alerts = presenter.viewModel.alertPublisher.bindLatestValue(to: &cancellables)
        
        service.resultSubject.send(.failure(MockError()))
        
        XCTAssertEqual(presenter.viewModel.status, .failed)
        if case let .alert(alert) = alerts.value {
            XCTAssertNotNil(alert.title)
            XCTAssertNotNil(alert.message)
            XCTAssertEqual(alert.actions.count, 2)
        } else {
            XCTFail("expected alert to be published")
        }
    }
    
    func test_an_empty_result_is_an_error() throws {
        let service = MockService()
        let presenter = try createPresenter(service: service)
        
        service.resultSubject.send(.success([]))
        
        XCTAssertEqual(presenter.viewModel.status, .emptyResponse)
    }
    
    func test_a_successful_response_is_a_success() throws {
        let service = MockService()
        let presenter = try createPresenter(service: service)
        
        service.resultSubject.send(.success([
            IdentityEntity()
        ]))
        
        XCTAssertEqual(presenter.viewModel.status, .success([IdentityEntity()]))
    }
    
    func test_finish_does_nothing_until_a_response_is_received() throws {
        let service = MockService()
        let delegate = TestDelegate()
        let presenter = try createPresenter(delegate: delegate, service: service)
        
        presenter.receive(event: .finish)
        
        XCTAssertFalse(delegate.complete)
        
        service.resultSubject.send(.success([
            IdentityEntity()
        ]))
        
        presenter.receive(event: .finish)
        
        XCTAssert(delegate.complete)
    }
    
    func test_error_is_a_valid_response() throws {
        let service = MockService()
        let delegate = TestDelegate()
        let presenter = try createPresenter(delegate: delegate, service: service)
        
        service.resultSubject.send(.success([]))
        
        XCTAssertEqual(presenter.viewModel.status, .emptyResponse)
        
        presenter.receive(event: .finish)
        
        XCTAssert(delegate.complete)
    }
    
    func test_identity_requests_can_be_retried() throws {
        let service = MockService()
        let delegate = TestDelegate()
        let presenter = try createPresenter(delegate: delegate, service: service)
        
        service.resultSubject.send(.success([]))
        
        presenter.receive(event: .fetchIdentities)
        
        XCTAssertEqual(presenter.viewModel.status, .fetching)
        
        service.resultSubject.send(.success([IdentityEntity()]))
        
        XCTAssertEqual(presenter.viewModel.status, .success([IdentityEntity()]))
    }
    
    func test_recovery_phrse_can_be_changed_after_empty_response() throws {
        let service = MockService()
        let delegate = TestDelegate()
        let presenter = try createPresenter(delegate: delegate, service: service)
        
        presenter.receive(event: .changeRecoveryPhrase)
        
        XCTAssertFalse(delegate.changingRecoveryPhrase)
        
        service.resultSubject.send(.success([]))
        
        presenter.receive(event: .changeRecoveryPhrase)
        
        XCTAssert(delegate.changingRecoveryPhrase)
    }
    
    private func createPresenter(
        delegate: TestDelegate = TestDelegate(),
        service: RecoveryPhraseServiceProtocol = MockService()
    ) throws -> IdentityRecoveryStatusPresenter {
        let presenter = IdentityRecoveryStatusPresenter(
            recoveryPhrase: try validPhrase,
            recoveryPhraseService: service,
            delegate: delegate
        )
        
        return presenter
    }
    
    private var validPhrase: RecoveryPhrase {
        get throws {
            let words = [
                "silly", "raven", "liar", "reduce",
                "mule", "walnut", "victory", "glass",
                "current", "collect", "unveil", "crystal",
                "warfare", "flock", "valve", "bottom",
                "lend", "ethics", "sausage", "spread",
                "regret", "ten", "wood", "protect"
            ]
            
            return try RecoveryPhrase(phrase: words.joined(separator: " "))
        }
    }
}

private struct MockError: Error {}

private class MockService: RecoveryPhraseServiceProtocol {
    let resultSubject = PassthroughSubject<Result<[IdentityDataType], Error>, Never>()
    
    func recoverIdentities(for recoveryPhrase: RecoveryPhrase) -> AnyPublisher<[IdentityDataType], Error> {
        return resultSubject
            .first()
            .setFailureType(to: Error.self)
            .flatMap { result -> AnyPublisher<[IdentityDataType], Error> in
                switch result {
                case let .success(identities):
                    return .just(identities)
                case let .failure(error):
                    return .fail(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

private class TestDelegate: IdentityRecoveryStatusPresenterDelegate {
    private (set) var complete = false
    private (set) var changingRecoveryPhrase = false
    
    func identityRecoveryCompleted() {
        complete = true
    }
    
    func reenterRecoveryPhrase() {
        changingRecoveryPhrase = true
    }
}
