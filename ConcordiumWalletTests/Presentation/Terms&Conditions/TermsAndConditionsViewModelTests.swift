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

    func test_terms_and_conditions_stored_on_accept() throws {
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
        viewModel.termsAndConditionsAccepted = true
        viewModel.continueButtonTapped()

        // then
        XCTAssertTrue(storageManagerMock.storeLastAcceptedTermsAndConditionsVersionCalled)
        XCTAssertEqual(storageManagerMock.latestTermsAndConditionsVersion, "6.6.6")
    }
    
    func test_terms_and_conditions_not_accepted() throws {
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

    func test_button_title_no_terms_accepted_before() throws {
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

    func test_button_title_on_updated_terms() throws {
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
