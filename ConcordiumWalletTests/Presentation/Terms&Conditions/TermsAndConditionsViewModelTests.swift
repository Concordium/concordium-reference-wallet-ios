//
//  TermsAndConditionsViewModelTests.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 27/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

@testable import Mock
import XCTest

final class TermsAndConditionsViewModelTests: XCTestCase {
    var termsAndConditionsLink = "http://wallet-proxy.mainnet.concordium.software/v0/termsAndConditionsVersion"

    func test_continue_button_tapped__tac_accepted_should_store_tac_version() throws {
        // given
        let storageManagerMock = StorageManagerMock()
        let returnedTermsAndConditionsResponse: TermsAndConditionsResponse = .init(
            url: URL(string: termsAndConditionsLink)!,
            version: "6.6.6"
        )

        let viewModel = TermsAndConditionsViewModel(
            storageManager: storageManagerMock,
            termsAndConditions: returnedTermsAndConditionsResponse
        )

        // when
        viewModel.termsAndConditionsAccepted = true
        viewModel.continueButtonTapped()

        // then
        XCTAssertTrue(storageManagerMock.storeLastAcceptedTermsAndConditionsVersionCalled)
        XCTAssertEqual(storageManagerMock.latestTermsAndConditionsVersion, returnedTermsAndConditionsResponse.version)
    }
    
    func test_continue_button_tapped__tac_not_accepted_should_do_nothing() throws {
        // given
        let storageManagerMock = StorageManagerMock()
        let viewModel = TermsAndConditionsViewModel(
            storageManager: storageManagerMock,
            termsAndConditions: .init(
                url: URL(string: termsAndConditionsLink)!,
                version: "6.6.6"
            )
        )

        // when
        viewModel.termsAndConditionsAccepted = false
        viewModel.continueButtonTapped()

        // then
        XCTAssertFalse(storageManagerMock.storeLastAcceptedTermsAndConditionsVersionCalled)
    }

    func test_continue_button_title_when_tac_never_accepted() throws {
        // given
        let storageManagerMock = StorageManagerMock()
        storageManagerMock.latestTermsAndConditionsVersion = ""
        let viewModel = TermsAndConditionsViewModel(
            storageManager: storageManagerMock,
            termsAndConditions: .init(
                url: URL(string: termsAndConditionsLink)!,
                version: ""
            )
        )

        // then
        XCTAssertEqual(viewModel.buttonTitle, "welcomeScreen.create.password".localized)
    }

    func test_continue_button_title_when_updated_version_of_tac_available() throws {
        // given
        let storageManagerMock = StorageManagerMock()
        storageManagerMock.latestTermsAndConditionsVersion = "1.0.0"
        let viewModel = TermsAndConditionsViewModel(
            storageManager: storageManagerMock,
            termsAndConditions: .init(
                url: URL(string: termsAndConditionsLink)!,
                version: "6.6.6"
            )
        )

        // then
        XCTAssertEqual(viewModel.buttonTitle, "welcomeScreen.button".localized)
    }
}
