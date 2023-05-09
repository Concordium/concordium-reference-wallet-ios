//
//  LoginCoordinatorTests.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 24/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
@testable import Mock
import SwiftUI
import XCTest

class LoginCoordinatorTests: XCTestCase {
    var sut: LoginCoordinator!
    var appSettingsMock: AppSettingsServiceProtocolMock!
    var storageManagerMock: StorageManagerMock!
    var keychainMock: InMemoryKeychain!
    var dependencyProvider: LoginDependencyProviderMock!
    private var cancellables: Set<AnyCancellable>!

    var termsAndConditionsLink = "http://wallet-proxy.mainnet.concordium.software/v0/termsAndConditionsVersion"

    override func setUp() async throws {
        appSettingsMock = AppSettingsServiceProtocolMock()
        storageManagerMock = StorageManagerMock()
        keychainMock = InMemoryKeychain()
        dependencyProvider = LoginDependencyProviderMock()
        dependencyProvider.appSettingsServiceReturnValue = appSettingsMock
        cancellables = []
        dependencyProvider.keychainWrapperReturnValue = keychainMock
        dependencyProvider.storageManagerReturnValue = storageManagerMock
        dependencyProvider.mobileWalletReturnValue = MobileWalletProtocolMock()
    }

    override func tearDown() async throws {
        dependencyProvider = nil
        appSettingsMock = nil
        keychainMock = nil
        storageManagerMock = nil
    }

    @MainActor
    func test_start__tac_never_accepted_and_password_never_set_should_show_tac_screen() {
        // given

        storageManagerMock.latestTermsAndConditionsVersion = "1.0.0"
        let returnedResponse = TermsAndConditionsResponse(url: URL(string: termsAndConditionsLink)!, version: "1.0.1")
        appSettingsMock.getTermsAndConditionsVersionReturnValue = .just(returnedResponse)

        // when
        sut = .init(
            navigationController: .init(),
            parentCoordinator: LoginCoordinatorDelegateMock(),
            dependencyProvider: dependencyProvider
        )
        sut.start()

        // then
        XCTAssertTrue(appSettingsMock.getTermsAndConditionsVersionCalled)
        XCTAssertEqual(appSettingsMock.getTermsAndConditionsVersionCallsCount, 1)
        XCTAssertTrue(sut.navigationController.topViewController is UIHostingController<TermsAndConditionsView>)
    }

    @MainActor
    func test_start__password_set_and_tac_not_changed_should_display_login_view() {
        // given

        keychainMock.storePassword(password: "anypass")
        storageManagerMock.latestTermsAndConditionsVersion = "1.0.0"
        let returnedResponse = TermsAndConditionsResponse(url: URL(string: termsAndConditionsLink)!, version: "1.0.0")
        appSettingsMock.getTermsAndConditionsVersionReturnValue = .just(returnedResponse)

        // when
        sut = .init(
            navigationController: .init(),
            parentCoordinator: LoginCoordinatorDelegateMock(),
            dependencyProvider: dependencyProvider
        )
        sut.start()

        // then
        XCTAssertTrue(appSettingsMock.getTermsAndConditionsVersionCalled)
        XCTAssertEqual(appSettingsMock.getTermsAndConditionsVersionCallsCount, 1)
        XCTAssertTrue(sut.navigationController.topViewController is EnterPasswordViewController)
    }

    @MainActor
    func test_start__password_not_set_terms_up_to_date_should_display_tac_view() {
        // given
        storageManagerMock.latestTermsAndConditionsVersion = "1.0.0"
        let returnedResponse = TermsAndConditionsResponse(url: URL(string: termsAndConditionsLink)!, version: "1.0.0")
        appSettingsMock.getTermsAndConditionsVersionReturnValue = .just(returnedResponse)

        // when
        sut = .init(
            navigationController: .init(),
            parentCoordinator: LoginCoordinatorDelegateMock(),
            dependencyProvider: dependencyProvider
        )
        sut.start()

        // then
        XCTAssertTrue(appSettingsMock.getTermsAndConditionsVersionCalled)
        XCTAssertEqual(appSettingsMock.getTermsAndConditionsVersionCallsCount, 1)
        XCTAssertTrue(sut.navigationController.topViewController is UIHostingController<TermsAndConditionsView>)
    }

    @MainActor
    func test_start__network_response_should_display_error_alert() {
        // given

        appSettingsMock.getTermsAndConditionsVersionReturnValue = Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()

        sut = .init(
            navigationController: .init(),
            parentCoordinator: LoginCoordinatorDelegateMock(),
            dependencyProvider: dependencyProvider
        )

        // when
        sut.start()

        // then
        var encounteredError: Error!
        appSettingsMock.getTermsAndConditionsVersion()
            .sink(receiveError: { error in
                encounteredError = error
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertNotNil(encounteredError)
        XCTAssertEqual(encounteredError.localizedDescription, NetworkError.invalidResponse.localizedDescription)
    }
}
