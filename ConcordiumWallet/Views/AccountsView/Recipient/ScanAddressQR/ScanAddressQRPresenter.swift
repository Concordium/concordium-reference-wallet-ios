//
//  ScanAddressQRPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 16/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol ScanAddressQRViewProtocol: class {
    func showQrValid()
    func showQrInvalid()
}

// MARK: -
// MARK: Delegate
protocol ScanAddressQRPresenterDelegate: class {
    func scanAddressQr(didScanAddress: String)
}

// MARK: -
// MARK: Presenter
protocol ScanAddressQRPresenterProtocol: class {
	var view: ScanAddressQRViewProtocol? { get set }
    func viewDidLoad()
    func scannedQrCode(_: String)
}

class ScanAddressQRPresenter: ScanAddressQRPresenterProtocol {

    weak var view: ScanAddressQRViewProtocol?
    weak var delegate: ScanAddressQRPresenterDelegate?
    let wallet: MobileWalletProtocol

    init(wallet: MobileWalletProtocol, delegate: ScanAddressQRPresenterDelegate? = nil) {
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
