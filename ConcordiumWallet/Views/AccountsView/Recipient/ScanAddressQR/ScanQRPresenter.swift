//
//  ScanAddressQRPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 16/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View

// sourcery: AutoMockable
protocol ScanQRViewProtocol: AnyObject {
    func showQrValid()
    func showQrInvalid()
}

// MARK: -

// MARK: Delegate

// sourcery: AutoMockable
protocol QRCodeStrategyDelegate: AnyObject {
    func qrScanner(didScanAddress: String)
    func qrScanner(didScanWalletConnect: String)
    func qrScanner(failedToScanQRCode: String)
}

// MARK: -

// MARK: Presenter

protocol ScanQRPresenterProtocol: AnyObject {
    var view: ScanQRViewProtocol? { get set }
    func viewDidLoad()
    func scannedQrCode(_: String)
}

protocol QRScannerStrategy {
    var delegate: QRCodeStrategyDelegate? { get set }
    func didScan(code: String)
}

extension ScanQRPresenter: QRCodeStrategyDelegate {
    func qrScanner(didScanAddress: String) {
        view?.showQrValid()
    }

    func qrScanner(didScanWalletConnect: String) {
        view?.showQrValid()
    }

    func qrScanner(failedToScanQRCode: String) {
        view?.showQrInvalid()
    }
}

class ScanQRPresenter: ScanQRPresenterProtocol {
    weak var view: ScanQRViewProtocol?
    weak var delegate: QRCodeStrategyDelegate?
    var strategy: QRScannerStrategy
    var didScanQrCode: (_ address: String) -> Void

    init(strategy: QRScannerStrategy, didScanQrCode: @escaping ((_ address: String) -> Void)) {
        self.strategy = strategy
        self.didScanQrCode = didScanQrCode
        self.strategy.delegate = self
    }

    func viewDidLoad() {}

    func scannedQrCode(_ code: String) {
        strategy.didScan(code: code)
    }
}

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

class AddressScannerStrategy: QRScannerStrategy {
    var delegate: QRCodeStrategyDelegate?
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
