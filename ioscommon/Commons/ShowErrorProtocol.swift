//
//  ShowError.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/28/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol ShowError: AnyObject {
    func showErrorAlert(_ error: ViewError)
    func showRecoverableAlert(_ error: ViewError, completion: @escaping () -> Void)
}

extension ShowError where Self: UIViewController {
    func showErrorAlert(_ error: ViewError) {
        let ac = UIAlertController(title: "errorAlert.title".localized, message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "errorAlert.okButton".localized, style: .default)
        ac.addAction(okAction)
        present(ac, animated: true)
    }
    
    func showRecoverableAlert(_ error: ViewError, completion: @escaping () -> Void) {
        let ac = UIAlertController(title: "errorAlert.title".localized, message: error.localizedDescription, preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "errorAlert.continueButton".localized, style: .default) { (_) in
            completion()
        }
        ac.addAction(continueAction)
        let cancelAction = UIAlertAction(title: "errorAlert.cancelButton".localized, style: .cancel)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
}

extension ShowError where Self: Coordinator {
    func showErrorAlert(_ error: ViewError) {
        let ac = UIAlertController(title: "errorAlert.title".localized, message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "errorAlert.okButton".localized, style: .default)
        ac.addAction(okAction)
        navigationController.present(ac, animated: true)
    }

    func showErrorAlertWithHandler(_ error: ViewError, completion: @escaping () -> Void) {
        let ac = UIAlertController(title: "errorAlert.title".localized, message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "errorAlert.okButton".localized, style: .default) { (_) in
            completion()
        }
        ac.addAction(okAction)
        navigationController.present(ac, animated: true)
    }

    func showRecoverableAlert(_ error: ViewError, completion: @escaping () -> Void) {
        let ac = UIAlertController(title: "errorAlert.title".localized, message: error.localizedDescription, preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "errorAlert.continueButton".localized, style: .default) { (_) in
            completion()
        }
        ac.addAction(continueAction)
        let cancelAction = UIAlertAction(title: "errorAlert.cancelButton".localized, style: .cancel)
        ac.addAction(cancelAction)
        navigationController.present(ac, animated: true)
    }
}
