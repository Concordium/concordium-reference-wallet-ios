//
//  TermsAndConditionsViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 17/05/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit
import MessageUI

class TermsAndConditionsFactory {
    class func create(with presenter: TermsAndConditionsPresenterProtocol) -> TermsAndConditionsViewController {
        TermsAndConditionsViewController.instantiate(fromStoryboard: "Login") { coder in
            return TermsAndConditionsViewController(coder: coder, presenter: presenter)
        }
    }
}

class TermsAndConditionsViewController: BaseViewController, TermsAndConditionsViewProtocol, Storyboarded {

    var presenter: TermsAndConditionsPresenterProtocol
    
    var attributedString: NSMutableAttributedString!
    
    let contactRange = NSMakeRange(50, 5)
    let supportRange = NSMakeRange(100, 5)

    @IBOutlet weak var detailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
        presenter.viewDidLoad()
        self.title = "termsAndConditionsScreen.title".localized

        attributedString = termsAttributedString()
        let clickableWords = [AppConstants.Email.contact, AppConstants.Email.support]

        for clickableWord in clickableWords {
            let textRange = (attributedString!.string as NSString).range(of: clickableWord)

            attributedString?.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1.0), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single], range: textRange)
        }
        detailsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(tapGesture:))))
        detailsLabel.attributedText = attributedString
    }

    init?(coder: NSCoder, presenter: TermsAndConditionsPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func acceptTermsTapped() {
        presenter.userTappedAcceptTerms()
    }
    
    @objc private func handleTapOnLabel(tapGesture: UITapGestureRecognizer) {
        let contactRange = (attributedString!.string as NSString).range(of: AppConstants.Email.contact)
        let supportRange = (attributedString!.string as NSString).range(of: AppConstants.Email.support)
        
        if tapGesture.didTapAttributedTextInLabel(label: detailsLabel, inRange: contactRange) {
            sendEmailWithRecepient(AppConstants.Email.contact)
        } else if tapGesture.didTapAttributedTextInLabel(label: detailsLabel, inRange: supportRange) {
            sendEmailWithRecepient(AppConstants.Email.support)
        }
    }
    
    private func sendEmailWithRecepient(_ recepient: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recepient])
            
            present(mail, animated: true)
        }
    }
}

extension TermsAndConditionsViewController {
    private func termsAttributedString() -> NSMutableAttributedString? {

        let titleAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.primary
        ]

        let subtitleAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.primary
        ]

        let detailsAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.fadedText
        ]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 16.0
        paragraphStyle.headIndent = 38.0

        let paragraphAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.fadedText,
            .paragraphStyle: paragraphStyle
        ]
        return TermsHelper.createTermsAttributedString(titleAttribute: titleAttribute,
                                      detailsAttribute: detailsAttribute,
                                      subtitleAttribute: subtitleAttribute,
                                      paragraphAttribute: paragraphAttribute)
    }
}

extension TermsAndConditionsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}
