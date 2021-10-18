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

protocol ShowIdentityFailure: AnyObject {
    func showIdentityFailureAlert(reference: String, completion: @escaping () -> Void)
}

typealias IdentityFailableViewController = UIViewController & ShowToast & SupportMail & MFMailComposeViewControllerDelegate

extension ShowIdentityFailure where Self: IdentityFailableViewController {
    func showIdentityFailureAlert(reference: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "identityfailed.title".localized,
            message: nil,
            preferredStyle: .alert
        )
        
        let tryAgainAction = UIAlertAction(title: "identityfailed.tryagain", style: .default) { _ in
            completion()
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
            let supportAction = UIAlertAction(title: "identityfailed.contactsupport", style: .default) { [weak self] _ in
                guard let self = self else { return }

                self.launchSupport(
                    presenter: self,
                    delegate: self,
                    recipient: AppConstants.Support.identityProviderSupportMail,
                    ccRecipient: AppConstants.Support.concordiumSupportMail,
                    subject: String(format: "supportmail.subject".localized, reference),
                    body: supportMailBody
                )
            }
            
            alert.message = "identityfailed.message".localized
            alert.addAction(supportAction)
            
        } else {
            let copyAction = UIAlertAction(title: "identityfailed.copyreference".localized, style: .default) { [weak self] _ in
                CopyPasterHelper.copy(string: supportMailBody)
                self?.showToast(withMessage: "supportmail.copied".localized)
            }
            alert.message = "identityfailed.nomail.message".localized
            alert.addAction(copyAction)
        }
        
        let cancelAction = UIAlertAction(title: "errorAlert.cancelButton".localized, style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
