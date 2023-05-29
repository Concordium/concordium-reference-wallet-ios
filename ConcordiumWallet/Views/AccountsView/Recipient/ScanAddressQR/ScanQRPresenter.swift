//
//  ScanAddressQRPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 16/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol ScanQRViewProtocol: AnyObject {
    func showQrValid()
    func showQrInvalid()
}

// MARK: -
// MARK: Delegate
protocol ScanAddressQRPresenterDelegate: AnyObject {
    func scanAddressQr(didScanAddress: String)
    func qrScanner(didScanWalletConnect: String)
}

// MARK: -
// MARK: Presenter
protocol ScanQRPresenterProtocol: AnyObject {
	var view: ScanQRViewProtocol? { get set }
    func viewDidLoad()
    func scannedQrCode(_: String)
}

class ScanQRPresenter: ScanQRPresenterProtocol {

    enum QRScannerStrategy {
        case address
        case walletConnect
    }

    weak var view: ScanQRViewProtocol?
    weak var delegate: ScanAddressQRPresenterDelegate?
    let wallet: MobileWalletProtocol

    init(wallet: MobileWalletProtocol, delegate: ScanAddressQRPresenterDelegate? = nil, strategy: QRScannerStrategy) {
        self.delegate = delegate
        self.wallet = wallet
    }

    func viewDidLoad() {
    }
    
    func scannedQrCode(_ address: String) {
        let qrValid = wallet.check(accountAddress: address)
        if qrValid {
            view?.showQrValid()
            self.delegate?.scanAddressQr(didScanAddress: address)
        } else {
            view?.showQrInvalid()
        }
    }
}
