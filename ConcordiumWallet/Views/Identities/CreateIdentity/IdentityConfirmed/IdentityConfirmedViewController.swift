//
//  IdentityConfirmedViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class IdentityConfirmedFactory {
    class func create(with presenter: IdentityConfirmedPresenter) -> IdentityConfirmedViewController {
        IdentityConfirmedViewController.instantiate(fromStoryboard: "Identity") {coder in
            return IdentityConfirmedViewController(coder: coder, presenter: presenter)
        }
    }
}

class IdentityConfirmedViewController: BaseViewController, IdentityConfirmedViewProtocol, Storyboarded, ShowAlert {

	var presenter: IdentityConfirmedPresenterProtocol
    
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var accountCardView: AccountCardView!
    @IBOutlet weak var identityCardView: IdentityCardView!
        
    init?(coder: NSCoder, presenter: IdentityConfirmedPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(title: String, subtitle: String, details: String, accountViewModel: AccountViewModel, identityViewModel: IdentityDetailsInfoViewModel) {
        self.title = title
        self.subtitle.text = subtitle
        self.details.text = details

        accountCardView.setup(accountViewModel: accountViewModel)

        accountCardView.showStatusImage(nil)
        identityCardView.titleLabel?.text = identityViewModel.nickname
        identityCardView.iconImageView?.image = UIImage.decodeBase64(toImage: identityViewModel.encodedImage)
        identityCardView.expirationDateLabel?.text = identityViewModel.bottomLabel
        identityCardView?.statusIcon.image = UIImage(named: "pending")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
        presenter.viewDidLoad()
    }

    @IBAction func finishAction(_ sender: Any) {
        let options = AlertOptions(
            title: "identitySubmitted.alert.title".localized,
            message: "identitySubmitted.alert.message".localized,
            actions: [
                AlertAction(
                    name: "ok".localized,
                    completion: { [weak self] in self?.presenter.finish() },
                    style: .default
                )
            ]
        )

        showAlert(with: options)
    }
}
