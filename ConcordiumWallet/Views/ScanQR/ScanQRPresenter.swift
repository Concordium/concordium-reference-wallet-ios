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

// MARK: Presenter

protocol ScanQRPresenterProtocol: AnyObject {
    var view: ScanQRViewProtocol? { get set }
    func viewDidLoad()
    func scannedQrCode(_: String)
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
