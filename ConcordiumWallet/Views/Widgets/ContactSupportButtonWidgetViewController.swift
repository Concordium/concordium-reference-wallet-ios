//
//  ContactSupportButtonWidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 07/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import MessageUI
import UIKit

// MARK: - View

protocol ContactSupportButtonWidgetViewProtocol: AnyObject {
    func launchSupport(to supportEmail: String, with reference: String)
}

class ContactSupportButtonWidgetFactory {
    class func create(with presenter: ContactSupportButtonWidgetPresenter) -> ContactSupportButtonWidgetViewController {
        ContactSupportButtonWidgetViewController.instantiate(fromStoryboard: "Widget") { coder in
            return ContactSupportButtonWidgetViewController(coder: coder, presenter: presenter)
        }
    }
}

class ContactSupportButtonWidgetViewController: BaseViewController, ContactSupportButtonWidgetViewProtocol, SupportMail, Storyboarded {
    var presenter: ContactSupportButtonWidgetPresenterProtocol
    
    init?(coder: NSCoder, presenter: ContactSupportButtonWidgetPresenterProtocol) {
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
    }
    
    func launchSupport(to supportEmail: String, with reference: String) {
        launchSupport(
            presenter: self,
            delegate: self,
            recipient: supportEmail,
            ccRecipient: AppConstants.Support.concordiumSupportMail,
            subject: String(format: "supportmail.subject".localized, reference),
            body: String(
                format: "supportmail.body".localized,
                reference,
                AppSettings.appVersion,
                AppSettings.buildNumber,
                AppSettings.iOSVersion
            )
        )
    }
    
    @IBAction func contactSupportButtonTapped(_ sender: Any) {
        presenter.contactSupportButtonTapped()
    }
}

extension ContactSupportButtonWidgetViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}
