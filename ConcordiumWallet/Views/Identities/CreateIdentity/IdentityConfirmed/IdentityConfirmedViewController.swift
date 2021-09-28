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
    
    private var recoverableAlert: RecoverableAlert?
    
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
        self.recoverableAlert = identityViewModel.recoverableAlert
        
        accountCardView.setupStaticStrings(accountTotal: accountViewModel.totalName,
                                           publicBalance: accountViewModel.generalName,
                                           atDisposal: accountViewModel.atDisposalName,
                                           staked: accountViewModel.stakedName,
                                           shieldedBalance: accountViewModel.shieldedName)
        accountCardView.setup(accountName: accountViewModel.name,
                              accountOwner: accountViewModel.owner,
                              isInitialAccount: accountViewModel.isInitialAccount,
                              isBaking: accountViewModel.isBaking,
                              isReadOnly: accountViewModel.isReadOnly,
                              totalAmount: accountViewModel.totalAmount,
                              showLock: false,
                              publicBalanceAmount: accountViewModel.generalAmount,
                              atDisposalAmount: accountViewModel.atDisposalAmount,
                              stakedAmount: accountViewModel.stakedAmount,
                              shieldedAmount: accountViewModel.shieldedAmount,
                              isExpanded: true,
                              isExpandable: false)
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
        guard let recoverableAlert = recoverableAlert else { return }
        showRecoverableAlert(recoverableAlert) { [weak self] in
            self?.presenter.finish()
        }
    }
}
