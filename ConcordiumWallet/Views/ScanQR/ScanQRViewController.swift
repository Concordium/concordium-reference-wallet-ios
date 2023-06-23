//
//  ScanAddressQRViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 16/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import AVFoundation
import UIKit

class ScanQRViewControllerFactory {
    class func create(with presenter: ScanQRPresenter) -> ScanQRViewController {
        ScanQRViewController(presenter: presenter)
    }
}

class ScanQRViewController: BaseViewController, ShowToast {
    var presenter: ScanQRPresenterProtocol
    var captureSession: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer

    var scanGuide: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "qr_overlay")
        image.tintColor = .white
        return image
    }()

    init(presenter: ScanQRPresenter) {
        captureSession = AVCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "scanQr.title".localized
        view.backgroundColor = .black
        presenter.view = self
        setupScanGuide()
        setupCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
        #if DEBUG
            let buttonItem = UIBarButtonItem(title: "DEBUG", style: .plain, target: self, action: #selector(displayDebugScreen))
            buttonItem.tintColor = .red
            navigationItem.rightBarButtonItem = buttonItem
        #endif
    }

    @objc private func displayDebugScreen() {
        navigationController?.pushViewController(WCDebugViewController(), animated: true)
    }

    func failed() {
        let ac = UIAlertController(title: "scanQr.unsupportedMessage.title".localized,
                                   message: "scanQr.unsupportedMessage.message".localized,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(ac, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    func found(code: String) {
        presenter.scannedQrCode(code)
    }
}

extension ScanQRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
}

extension ScanQRViewController: ScanQRViewProtocol {
    func showQrValid() {
        scanGuide.tintColor = .green
    }

    func showQrInvalid() {
        scanGuide.tintColor = .red
        showToast(withMessage: "scanQr.invalidQr".localized)
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
        UIView.animate(withDuration: 0.3, delay: 1.0, animations: {
            self.scanGuide.tintColor = .white
        })
    }
}

private extension ScanQRViewController {
    func setupScanGuide() {
        view.addSubview(scanGuide)
        scanGuide.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            scanGuide.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanGuide.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanGuide.heightAnchor.constraint(equalToConstant: 256),
            scanGuide.widthAnchor.constraint(equalToConstant: 256),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
    }
}
