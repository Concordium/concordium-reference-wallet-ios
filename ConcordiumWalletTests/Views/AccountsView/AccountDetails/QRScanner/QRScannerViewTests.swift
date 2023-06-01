//
//  QRScannerViewTests.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 29/05/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

@testable import Mock
import XCTest

final class QRScannerViewTests: XCTestCase {
    var sut: ScanQRPresenter!
    var view: ScanQRViewProtocolMock!

    override func setUp() async throws {
        view = ScanQRViewProtocolMock()
    }

    func test__scan_wallet_connect_address_when_wallet_should_call_qr_valid() {
        // given
        sut = ScanQRPresenter(strategy: WalletConnectStrategy(), didScanQrCode: { _ in })
        sut.view = view

        // when
        sut.scannedQrCode("wc://theFakeAddress")

        // then
        XCTAssertTrue(view.showQrValidCalled)
    }

    func test__scan_crypto_address_when_wallet_connect_expected__should_call_qr_invalid() {
        // given
        sut = ScanQRPresenter(strategy: WalletConnectStrategy(), didScanQrCode: { _ in })
        sut.view = view

        // when
        sut.scannedQrCode("3ymDHftPfdfY7GXkG44YWPZnvWN329ueHV25eSzaTaHCptWwms")

        // then
        XCTAssertTrue(view.showQrInvalidCalled)
    }

    func test__scan_wallet_connect_when_address_strategy_expected__should_call_qr_invalid() {
        let callback: ((String) -> Void) = { _ in }

        // given
        let mockWallet = MobileWalletProtocolMock()
        sut = ScanQRPresenter(strategy: AddressScannerStrategy(wallet: mockWallet), didScanQrCode: { _ in })
        sut.view = view
        mockWallet.checkAccountAddressReturnValue = false
        mockWallet.checkAccountAddressReceivedAccountAddress = "wc://theFakeAddress"

        // when
        sut.scannedQrCode("wc://theFakeAddress")

        // then
        XCTAssertTrue(view.showQrInvalidCalled)
    }

    func test__scan_crypto_address_when_address_strategy_expected__should_call_qr_invalid() {
        let callback: ((String) -> Void) = { _ in }

        // given
        let mockWallet = MobileWalletProtocolMock()
        sut = ScanQRPresenter(strategy: AddressScannerStrategy(wallet: mockWallet), didScanQrCode: { _ in })
        sut.view = view
        mockWallet.checkAccountAddressReturnValue = true
        mockWallet.checkAccountAddressReceivedAccountAddress = "3ymDHftPfdfY7GXkG44YWPZnvWN329ueHV25eSzaTaHCptWwmss"

        // when
        sut.scannedQrCode("3ymDHftPfdfY7GXkG44YWPZnvWN329ueHV25eSzaTaHCptWwmss")

        // then
        XCTAssertTrue(view.showQrValidCalled)
    }
}
