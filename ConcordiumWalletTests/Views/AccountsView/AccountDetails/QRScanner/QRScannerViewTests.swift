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

    func test__scan_valid_qr_should_call_qr_valid() {
        // given
        sut = ScanQRPresenter(didScanQrCode: { _ in true })
        sut.view = view

        // when
        sut.scannedQrCode("valid")

        // then
        XCTAssertTrue(view.showQrValidCalled)
    }

    func test__scan_invalid_qr_should_call_qr_invalid() {
        // given
        sut = ScanQRPresenter(didScanQrCode: { _ in false })
        sut.view = view

        // when
        sut.scannedQrCode("invalid")

        // then
        XCTAssertTrue(view.showQrInvalidCalled)
    }
}
