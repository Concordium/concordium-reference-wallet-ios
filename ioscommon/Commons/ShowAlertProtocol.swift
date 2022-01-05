//
//  ShowAlert.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/28/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

struct AlertAction {
    let name: String
    let completion: (() -> Void)?
    let style: UIAlertAction.Style
}

struct AlertOptions {
    let title: String?
    let message: String?
    let actions: [AlertAction]
}

protocol ShowAlert: AnyObject {
    func showErrorAlert(_ error: ViewError)
    func showRecoverableErrorAlert(_ error: ViewError, recoverActionTitle: String, hasCancel: Bool, completion: @escaping () -> Void)
    func showAlert(with options: AlertOptions)
}

extension ShowAlert where Self: UIViewController {
    func showErrorAlert(_ error: ViewError) {
        let alert = UIAlertController(
            title: "errorAlert.title".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "errorAlert.okButton".localized, style: .default)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func showRecoverableErrorAlert(_ error: ViewError, recoverActionTitle: String, hasCancel: Bool, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "errorAlert.title".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        let recoverAction = UIAlertAction(title: recoverActionTitle, style: .default) { (_) in
            completion()
        }
        alert.addAction(recoverAction)

        if hasCancel {
            let cancelAction = UIAlertAction(title: "errorAlert.cancelButton".localized, style: .cancel)
            alert.addAction(cancelAction)
        }

        present(alert, animated: true)
    }
    
    func showAlert(with options: AlertOptions) {
        let alert = UIAlertController(
            title: options.title,
            message: options.message,
            preferredStyle: .alert
        )

        for alertAction in options.actions {
            let action = UIAlertAction(title: alertAction.name, style: alertAction.style) { _ in
                alertAction.completion?()
            }

            alert.addAction(action)
        }

        present(alert, animated: true)
    }
}

extension ShowAlert where Self: Coordinator {
    func showErrorAlert(_ error: ViewError) {
        let alert = UIAlertController(
            title: "errorAlert.title".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "errorAlert.okButton".localized, style: .default)
        
        alert.addAction(okAction)
        
        navigationController.present(alert, animated: true)
    }

    func showErrorAlertWithHandler(_ error: ViewError, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "errorAlert.title".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "errorAlert.okButton".localized, style: .default) { (_) in
            completion()
        }
        
        alert.addAction(okAction)
        
        navigationController.present(alert, animated: true)
    }

    func showRecoverableErrorAlert(_ error: ViewError, recoverActionTitle: String, hasCancel: Bool, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "errorAlert.title".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let recoverAction = UIAlertAction(title: recoverActionTitle, style: .default) { (_) in
            completion()
        }

        alert.addAction(recoverAction)

        if hasCancel {
            let cancelAction = UIAlertAction(title: "errorAlert.cancelButton".localized, style: .cancel)
            alert.addAction(cancelAction)
        }

        navigationController.present(alert, animated: true)
    }
    
    
    func showAlert(with options: AlertOptions) {
        let alert = UIAlertController(
            title: options.title,
            message: options.message,
            preferredStyle: .alert
        )
        
        for alertAction in options.actions {
            let action = UIAlertAction(title: alertAction.name, style: alertAction.style) { _ in
                alertAction.completion?()
            }

            alert.addAction(action)
        }

        navigationController.present(alert, animated: true)
    }
}
