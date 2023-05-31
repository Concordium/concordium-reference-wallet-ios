//
//  WalletConnectStrategy.swift
//  Mock
//
//  Created by Milan Sawicki on 31/05/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

class WalletConnectStrategy: QRScannerStrategy {
    var delegate: QRCodeStrategyDelegate?

    func didScan(code: String) {
        if code.lowercased().hasPrefix("wc:") {
            delegate?.qrScanner(didScanWalletConnect: code)
        } else {
            delegate?.qrScanner(failedToScanQRCode: code)
        }
    }

    func validate(qrCode: String) -> Bool {
        qrCode.lowercased().hasPrefix("wc:")
    }
}
