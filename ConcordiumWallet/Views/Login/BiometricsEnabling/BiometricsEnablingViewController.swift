//
//  BiometricsEnablingViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 06/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import LocalAuthentication

class BiometricsEnablingFactory {
    class func create(with presenter: BiometricsEnablingPresenter) -> BiometricsEnablingViewController {
        BiometricsEnablingViewController.instantiate(fromStoryboard: "Login") {coder in
            return BiometricsEnablingViewController(coder: coder, presenter: presenter)
        }
    }
}

class BiometricsEnablingViewController: BaseViewController, BiometricsEnablingViewProtocol, Storyboarded {
    @IBOutlet weak var faceIdTouchIdIcon: UIImageView! {
        didSet {
            switch presenter.getBiometricType() {
            case .touchID:
                faceIdTouchIdIcon.image = UIImage(named: "touchId")
            default:
                break
            }
        }
    }

    @IBOutlet weak var infoText: UILabel! {
        didSet {
            switch presenter.getBiometricType() {
            case .faceID:
                infoText.text = "selectPassword.biometrics.infoText.faceIdText".localized
            case .touchID:
                infoText.text = "selectPassword.biometrics.infoText.touchIdText".localized
            default:
                break
            }
        }
    }

    @IBOutlet weak var enableButton: StandardButton! {
        didSet {
            switch presenter.getBiometricType() {
            case .faceID:
                enableButton.setTitle("selectPassword.biometrics.enableButton.faceIdText".localized, for: .normal)
            case .touchID:
                enableButton.setTitle("selectPassword.biometrics.enableButton.touchIdText".localized, for: .normal)
            default:
                break
            }
        }
    }
    
	var presenter: BiometricsEnablingPresenterProtocol

    init?(coder: NSCoder, presenter: BiometricsEnablingPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
        presenter.viewDidLoad()

        switch presenter.getBiometricType() {
        case .faceID:
            self.title =  "selectPassword.biometrics.title.faceId".localized
        case .touchID:
            self.title =  "selectPassword.biometrics.title.touchId".localized
        default:
            break
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }

    @IBAction func enableButtonPressed(_ sender: Any) {
        presenter.enablePressed()
    }

    @IBAction func continueWithoutButtonPressed(_ sender: Any) {
        presenter.continueWithoutBiometrics()
    }
}
