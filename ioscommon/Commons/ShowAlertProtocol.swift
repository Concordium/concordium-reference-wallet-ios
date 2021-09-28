//
//  ShowAlert.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/28/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol ShowAlert: AnyObject {
    func showErrorAlert(_ error: ViewError)
    func showRecoverableErrorAlert(_ error: ViewError, completion: @escaping () -> Void)
    func showRecoverableAlert(title: String?, message: String?, actionTitle: String, completion: @escaping () -> Void)
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
    
    func showRecoverableErrorAlert(_ error: ViewError, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "errorAlert.title".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let continueAction = UIAlertAction(title: "errorAlert.continueButton".localized, style: .default) { (_) in
            completion()
        }
        
        let cancelAction = UIAlertAction(title: "errorAlert.cancelButton".localized, style: .cancel)
        
        alert.addAction(continueAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func showRecoverableAlert(title: String?, message: String?, actionTitle: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
       
        let action = UIAlertAction(title: actionTitle, style: .default) { _ in
            completion()
        }
        
        alert.addAction(action)
        
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

    func showRecoverableErrorAlert(_ error: ViewError, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "errorAlert.title".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let continueAction = UIAlertAction(title: "errorAlert.continueButton".localized, style: .default) { (_) in
            completion()
        }
        
        let cancelAction = UIAlertAction(title: "errorAlert.cancelButton".localized, style: .cancel)
        
        alert.addAction(continueAction)
        alert.addAction(cancelAction)
        
        navigationController.present(alert, animated: true)
    }
    
    func showRecoverableAlert(title: String?, message: String?, actionTitle: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
       
        let action = UIAlertAction(title: actionTitle, style: .default) { _ in
            completion()
        }
        
        alert.addAction(action)
        
        navigationController.present(alert, animated: true)
    }
}
