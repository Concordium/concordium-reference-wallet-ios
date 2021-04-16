//
//  ScanAddressQRViewController.swift
//  ConcordiumWallet
//
//  Created by Johan Rugager Vase on 16/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import AVFoundation

class ScanAddressQRFactory {
    class func create(with presenter: ScanAddressQRPresenter) -> ScanAddressQRViewController {
        ScanAddressQRViewController.instantiate(fromStoryboard: "SendFund") {coder in
            return ScanAddressQRViewController(coder: coder, presenter: presenter)
        }
    }
}

class ScanAddressQRViewController: BaseViewController, Storyboarded, ShowToast {

	var presenter: ScanAddressQRPresenterProtocol

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    @IBOutlet weak var scanGuide: UIImageView! {
        didSet {
            scanGuide.tintColor = .white
        }
    }
    
    init?(coder: NSCoder, presenter: ScanAddressQRPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "scanQr.title".localized

        presenter.view = self
        presenter.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

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

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "scanQr.unsupportedMessage.title".localized,
                message: "scanQr.unsupportedMessage.message".localized,
                preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    func found(code: String) {
        presenter.scannedQrCode(code)
    }
}

extension ScanAddressQRViewController: AVCaptureMetadataOutputObjectsDelegate {

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

extension ScanAddressQRViewController: ScanAddressQRViewProtocol {
    func showQrValid() {
        scanGuide.tintColor = .green
    }

    func showQrInvalid() {
        scanGuide.tintColor = .red
        showToast(withMessage: "scanQr.invalidQr".localized)
        self.captureSession.startRunning()
        UIView.animate(withDuration: 0.3, delay: 1.0, animations: {
            self.scanGuide.tintColor = .white
        })
    }
}
