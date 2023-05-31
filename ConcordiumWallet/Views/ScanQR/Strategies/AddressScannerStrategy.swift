//
//  AddressScannerStrategy.swift
//  Mock
//
//  Created by Milan Sawicki on 31/05/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

class AddressScannerStrategy: QRScannerStrategy {
    weak var delegate: QRCodeStrategyDelegate?
    let wallet: MobileWalletProtocol

    init(wallet: MobileWalletProtocol) {
        self.wallet = wallet
    }

    func didScan(code: String) {
        if wallet.check(accountAddress: code) {
            delegate?.qrScanner(didScanAddress: code)
        } else {
            delegate?.qrScanner(failedToScanQRCode: code)
        }
    }
}
