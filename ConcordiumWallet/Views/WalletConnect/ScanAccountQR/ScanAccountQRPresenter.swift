//
//  ScanAccountQRPresenter.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 13.3.23.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol ScanAccountQRViewProtocol: AnyObject {
    func showQrValid()
    func showQrInvalid()
}

// MARK: -
// MARK: Delegate
protocol ScanAccountQRPresenterDelegate: AnyObject {
    func scanAccountQr(didScanAccount: String)
}

// MARK: -
// MARK: Presenter
protocol ScanAccountQRPresenterProtocol: AnyObject {
    var view: ScanAccountQRViewProtocol? { get set }
    func viewDidLoad()
    func scannedQrCode(_: String)
}

class ScanAccountQRPresenter: ScanAccountQRPresenterProtocol {

    weak var view: ScanAccountQRViewProtocol?
    weak var delegate: ScanAccountQRPresenterDelegate?
    let wallet: MobileWalletProtocol

    init(wallet: MobileWalletProtocol, delegate: ScanAccountQRPresenterDelegate? = nil) {
        self.delegate = delegate
        self.wallet = wallet
    }

    func viewDidLoad() {
    }
    
    func scannedQrCode(_ address: String) {
        let qrValid = wallet.check(accountAddress: address)
        if qrValid {
            view?.showQrValid()
            self.delegate?.scanAccountQr(didScanAccount: address)
        } else {
            view?.showQrInvalid()
        }
    }
}
