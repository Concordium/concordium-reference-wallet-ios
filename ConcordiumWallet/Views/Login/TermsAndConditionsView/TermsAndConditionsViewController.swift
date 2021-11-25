//
//  TermsAndConditionsViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 17/05/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit

class TermsAndConditionsFactory {
    class func create(with presenter: TermsAndConditionsPresenter) -> TermsAndConditionsViewController {
        TermsAndConditionsViewController.instantiate(fromStoryboard: "Login") { coder in
            return TermsAndConditionsViewController(coder: coder, presenter: presenter)
        }
    }
}

class TermsAndConditionsViewController: BaseViewController, TermsAndConditionsViewProtocol, Storyboarded {

    var presenter: TermsAndConditionsPresenterProtocol

    @IBOutlet weak var detailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
        self.title = "termsAndConditionsScreen.title".localized

        detailsLabel.attributedText = termsAttributedString()
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
}

extension TermsAndConditionsViewController {
    private func termsAttributedString() -> NSAttributedString? {

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
