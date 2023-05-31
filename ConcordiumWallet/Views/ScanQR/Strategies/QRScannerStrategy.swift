//
//  QRScannerStrategy.swift
//  Mock
//
//  Created by Milan Sawicki on 31/05/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

// MARK: Delegate

// sourcery: AutoMockable
protocol QRCodeStrategyDelegate: AnyObject {
    func qrScanner(didScanAddress: String)
    func qrScanner(didScanWalletConnect: String)
    func qrScanner(failedToScanQRCode: String)
}

protocol QRScannerStrategy {
    var delegate: QRCodeStrategyDelegate? { get set }
    func didScan(code: String)
}
