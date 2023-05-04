//
//  LoginCoordinatorTests.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 24/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import XCTest
import SwiftUI
@testable import Mock
import Combine
class LoginCoordinatorTests: XCTestCase {
    var sut: LoginCoordinator!
    var termsAndConditionsLink = "http://wallet-proxy.mainnet.concordium.software/v0/termsAndConditionsVersion"

    @MainActor
    func test_start__tac_never_accepted_and_password_never_set_should_show_tac_screen() {
        // given
        let appSettingsMock = AppSettingsServiceProtocolMock()
        let storageManagerMock = StorageManagerMock()
        let keychainMock = InMemoryKeychain()
        let dependecyProvider = LoginDependencyProviderMock()
        
        dependecyProvider.appSettingsServiceReturnValue = appSettingsMock
        dependecyProvider.keychainWrapperReturnValue = keychainMock
        dependecyProvider.storageManagerReturnValue = storageManagerMock

        storageManagerMock.latestTermsAndConditionsVersion = "1.0.0"
        let returnedResponse = TermsAndConditionsResponse(url: URL(string: termsAndConditionsLink)!, version: "1.0.1")
        appSettingsMock.getTermsAndConditionsVersionReturnValue = .just(returnedResponse)

        // when
        sut = .init(
            navigationController: .init(),
            parentCoordinator: LoginCoordinatorDelegateMock(),
            dependencyProvider: dependecyProvider
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
        let appSettingsMock = AppSettingsServiceProtocolMock()
        let storageManagerMock = StorageManagerMock()
        let keychainMock = InMemoryKeychain()
        let dependecyProvider = LoginDependencyProviderMock()
        
        dependecyProvider.appSettingsServiceReturnValue = appSettingsMock
        dependecyProvider.keychainWrapperReturnValue = keychainMock
        dependecyProvider.storageManagerReturnValue = storageManagerMock
        dependecyProvider.mobileWalletReturnValue = MobileWalletProtocolMock()

        keychainMock.storePassword(password: "anypass")
        storageManagerMock.latestTermsAndConditionsVersion = "1.0.0"
        let returnedResponse = TermsAndConditionsResponse(url: URL(string: termsAndConditionsLink)!, version: "1.0.0")
        appSettingsMock.getTermsAndConditionsVersionReturnValue = .just(returnedResponse)

        // when
        sut = .init(
            navigationController: .init(),
            parentCoordinator: LoginCoordinatorDelegateMock(),
            dependencyProvider: dependecyProvider
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
        let appSettingsMock = AppSettingsServiceProtocolMock()
        let storageManagerMock = StorageManagerMock()
        let keychainMock = InMemoryKeychain()
        let dependecyProvider = LoginDependencyProviderMock()
        
        dependecyProvider.appSettingsServiceReturnValue = appSettingsMock
        dependecyProvider.keychainWrapperReturnValue = keychainMock
        dependecyProvider.storageManagerReturnValue = storageManagerMock
        dependecyProvider.mobileWalletReturnValue = MobileWalletProtocolMock()

        storageManagerMock.latestTermsAndConditionsVersion = "1.0.0"
        let returnedResponse = TermsAndConditionsResponse(url: URL(string: termsAndConditionsLink)!, version: "1.0.0")
        appSettingsMock.getTermsAndConditionsVersionReturnValue = .just(returnedResponse)

        // when
        sut = .init(
            navigationController: .init(),
            parentCoordinator: LoginCoordinatorDelegateMock(),
            dependencyProvider: dependecyProvider
        )
        sut.start()

        // then
        XCTAssertTrue(appSettingsMock.getTermsAndConditionsVersionCalled)
        XCTAssertEqual(appSettingsMock.getTermsAndConditionsVersionCallsCount, 1)
        XCTAssertTrue(sut.navigationController.topViewController is UIHostingController<TermsAndConditionsView>)
    }
}