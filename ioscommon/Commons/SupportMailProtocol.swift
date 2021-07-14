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
    func launchSupport(presenter: UIViewController, delegate: MFMailComposeViewControllerDelegate, recipient: String, subject: String, body: String)
}
extension SupportMail {
    var canSendMail: Bool {
        return MFMailComposeViewController.canSendMail() || thirdPartyMailUrl(to: "", subject: "", body: "") != nil
    }
    
    func launchSupport(presenter: UIViewController, delegate: MFMailComposeViewControllerDelegate, recipient: String, subject: String, body: String) {
        if MFMailComposeViewController.canSendMail() {
            let mfMailComposeViewController = MFMailComposeViewController()
            mfMailComposeViewController.mailComposeDelegate = delegate
            mfMailComposeViewController.setToRecipients([recipient])
            mfMailComposeViewController.setSubject(subject)
            mfMailComposeViewController.setMessageBody(body, isHTML: false)
            
            presenter.present(mfMailComposeViewController, animated: true)
            
        } else if let emailUrl = thirdPartyMailUrl(to: recipient, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
    }
    
    private func thirdPartyMailUrl(to: String, subject: String, body: String) -> URL? {
        guard
            let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            return nil
        }
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        
        return nil
    }
}
