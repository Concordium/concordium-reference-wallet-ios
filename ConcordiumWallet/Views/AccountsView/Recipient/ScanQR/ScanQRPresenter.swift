//
//  ScanQRPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 16/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

enum ScanQRType: Int {
    case Address = 0, WalletConnect
}

// MARK: View
protocol ScanQRViewProtocol: AnyObject {
    func showQrValid()
    func showQrInvalid()
}

// MARK: -
// MARK: Delegate
protocol ScanQRPresenterDelegate: AnyObject {
    func scanQr(didScanQrCode: String)
}

// MARK: -
// MARK: Presenter
protocol ScanQRPresenterProtocol: AnyObject {
	var view: ScanQRViewProtocol? { get set }
    var type: ScanQRType? { get set }
    func viewDidLoad()
    func scannedQrCode(_: String)
}

class ScanQRPresenter: ScanQRPresenterProtocol {

    weak var view: ScanQRViewProtocol?
    weak var delegate: ScanQRPresenterDelegate?
    let wallet: MobileWalletProtocol
    var type: ScanQRType?

    init(wallet: MobileWalletProtocol, delegate: ScanQRPresenterDelegate? = nil, type: ScanQRType = .Address) {
        self.delegate = delegate
        self.wallet = wallet
        self.type = type
    }

    func viewDidLoad() {
    }
    
    func scannedQrCode(_ qrCode: String) {
        let qrValid = type == .Address ? wallet.check(accountAddress: qrCode) : wallet.checkWalletConnect(qrCode: qrCode)
        if qrValid {
            view?.showQrValid()
            self.delegate?.scanQr(didScanQrCode: qrCode)
        } else {
            view?.showQrInvalid()
        }
    }
}
