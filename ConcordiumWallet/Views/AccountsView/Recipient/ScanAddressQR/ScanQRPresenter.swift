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
    func validate(qrCode: String) -> Bool
    func didScan(code: String) 
}

class ScanQRPresenter: ScanQRPresenterProtocol {
    weak var view: ScanQRViewProtocol?
    weak var delegate: QRCodeStrategyDelegate?
    let strategy: QRScannerStrategy
    init(strategy: QRScannerStrategy) {
        self.strategy = strategy
    }

    func viewDidLoad() {}

    func scannedQrCode(_ code: String) {
        let isValid = strategy.validate(qrCode: code)
        if isValid {
            strategy.didScan(code: code)
            view?.showQrValid()
        } else {
            view?.showQrInvalid()
        }
    }
}

class WalletConnectStrategy: QRScannerStrategy {
    var delegate: QRCodeStrategyDelegate?

    init(delegate: QRCodeStrategyDelegate? = nil) {
        self.delegate = delegate
    }

    func didScan(code: String) {
        delegate?.qrScanner(didScanWalletConnect: code)
    }
    
    
    func validate(qrCode: String) -> Bool {
        !qrCode.isEmpty && qrCode.lowercased().hasPrefix("wc:")
    }
}

class AddressScannerStrategy: QRScannerStrategy {
    var delegate: QRCodeStrategyDelegate?
    let wallet: MobileWalletProtocol

    
    init(wallet: MobileWalletProtocol, delegate: QRCodeStrategyDelegate? = nil) {
        self.wallet = wallet
        self.delegate = delegate
    }

    func didScan(code: String) {
        delegate?.qrScanner(didScanAddress: code)
    }

    func validate(qrCode: String) -> Bool {
        wallet.check(accountAddress: qrCode)
    }
}
