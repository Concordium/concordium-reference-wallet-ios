//
//  ShowIdentityFailureProtocol.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 18/10/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import MessageUI
import UIKit

enum IdentityFailureAlertOption {
    case tryAgain
    case support
    case copy
    case cancel
}

protocol ShowIdentityFailure: AnyObject {
    func showIdentityFailureAlert(identityProviderName: String,
                                  identityProviderSupportEmail: String,
                                  reference: String,
                                  completion: @escaping (_ result: IdentityFailureAlertOption) -> Void)
}

typealias IdentityFailableViewController = UIViewController & ShowToast & SupportMail & MFMailComposeViewControllerDelegate

extension ShowIdentityFailure where Self: IdentityFailableViewController {
    func showIdentityFailureAlert(identityProviderName: String,
                                  identityProviderSupportEmail: String,
                                  reference: String,
                                  completion: @escaping (_ result: IdentityFailureAlertOption) -> Void) {
        let concordiumSupportEmail = AppConstants.Support.concordiumSupportMail
        let alert = UIAlertController(
            title: "identityfailed.title".localized,
            message: nil,
            preferredStyle: .alert
        )
        
        let tryAgainAction = UIAlertAction(title: "identityfailed.tryagain".localized, style: .default) { _ in
            completion(.tryAgain)
        }
        
        alert.addAction(tryAgainAction)
        
        let supportMailBody = String(
            format: "supportmail.body".localized,
            reference,
            AppSettings.appVersion,
            AppSettings.buildNumber,
            AppSettings.iOSVersion
        )
        
        if MailHelper.canSendMail {
            let supportAction = UIAlertAction(title: "identityfailed.contactsupport".localized, style: .default) { [weak self] _ in
                guard let self = self else { return }

                self.launchSupport(
                    presenter: self,
                    delegate: self,
                    recipient: identityProviderSupportEmail,
                    ccRecipient: concordiumSupportEmail,
                    subject: String(format: "supportmail.subject".localized, reference),
                    body: supportMailBody
                )
                completion(.support)
            }
            
            alert.message = String(format: "identityfailed.message".localized, identityProviderName)
            alert.addAction(supportAction)
            
        } else {
            let copyAction = UIAlertAction(title: "identityfailed.copyreference".localized, style: .default) { [weak self] _ in
                CopyPasterHelper.copy(string: supportMailBody)
                self?.showToast(withMessage: "supportmail.copied".localized)
            }
            alert.message = String(format: "identityfailed.nomail.message".localized,
                                   identityProviderName,
                                   identityProviderName,
                                   identityProviderSupportEmail,
                                   concordiumSupportEmail)
            completion(.copy)
            alert.addAction(copyAction)
        }
        
        let cancelAction = UIAlertAction(title: "errorAlert.cancelButton".localized, style: .cancel) { _ in
            completion(.cancel)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
