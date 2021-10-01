//
//  SupportMailProtocol.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 14/07/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import MessageUI
import UIKit

protocol SupportMail: AnyObject {
    func launchSupport(
        presenter: UIViewController,
        delegate: MFMailComposeViewControllerDelegate,
        recipient: String,
        ccRecipient: String?,
        subject: String,
        body: String
    )
}
extension SupportMail {
    func launchSupport(
        presenter: UIViewController,
        delegate: MFMailComposeViewControllerDelegate,
        recipient: String,
        ccRecipient: String? = nil,
        subject: String,
        body: String
    ) {
        if MFMailComposeViewController.canSendMail() {
            let mfMailComposeViewController = MFMailComposeViewController()
            let ccRecipients = [ccRecipient].compactMap { $0 }
            
            mfMailComposeViewController.setCcRecipients(ccRecipients)
            mfMailComposeViewController.mailComposeDelegate = delegate
            mfMailComposeViewController.setToRecipients([recipient])
            mfMailComposeViewController.setSubject(subject)
            mfMailComposeViewController.setMessageBody(body, isHTML: false)
            
            presenter.present(mfMailComposeViewController, animated: true)
            
        } else if let emailUrl = MailHelper.thirdPartyMailUrl(to: recipient, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
    }
}
