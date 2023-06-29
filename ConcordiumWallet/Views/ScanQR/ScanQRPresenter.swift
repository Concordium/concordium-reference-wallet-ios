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
    var viewWillDisappear: (() -> Void) { get set }
    func scannedQrCode(_: String)
}

class ScanQRPresenter: ScanQRPresenterProtocol {
    weak var view: ScanQRViewProtocol?
    var viewWillDisappear: (() -> Void)
    var didScanQrCode: (_ address: String) -> Bool // TODO create/use result enum

    init(didScanQrCode: @escaping ((_ value: String) -> Bool), viewWillDisappear: @escaping (() -> Void)) {
        self.didScanQrCode = didScanQrCode
        self.viewWillDisappear = viewWillDisappear
    }

    func scannedQrCode(_ value: String) {
        let success = didScanQrCode(value)
        if success {
            view?.showQrValid()
        } else {
            view?.showQrInvalid()
        }
    }
}
