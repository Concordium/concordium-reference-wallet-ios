//
//  QRScannerViewTests.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 29/05/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import XCTest
@testable import Mock

final class QRScannerViewTests: XCTestCase {

    var sut: ScanQRPresenter!
    var view: ScanQRViewProtocolMock!
    
    override func setUp() async throws {
        view = ScanQRViewProtocolMock()
    }

    func test__scan_wallet_connect_address_when_wallet_should_call_qr_valid() {
        let callback: ((String) -> Void) = { _ in }
        // given
        sut = ScanQRPresenter(strategy: WalletConnectStrategy(), didScanQrCode: callback)
        sut.view = view
        
        // when
        sut.scannedQrCode("wc://theFakeAddress")
        
        // then
        XCTAssertTrue(view.showQrValidCalled)
    }
    
    func test__scan_crypto_address_when_wallet_connect_expected__should_call_qr_invalid() {
        let callback: ((String) -> Void) = { _ in }

        // given
        let mockWallet = MobileWalletProtocolMock()
        sut = ScanQRPresenter(strategy: AddressScannerStrategy(wallet: mockWallet), didScanQrCode: callback)
        sut.view = view
        
        // when
        sut.scannedQrCode("blablabla")
        
        // then
        XCTAssertTrue(view.showQrInvalidCalled)
    }
}
