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
    
    func test__did_scan_wc_qr_code() {
        sut = ScanQRPresenter(strategy: WalletConnectStrategy(delegate: QRCodeStrategyDelegate?))
    }
}
