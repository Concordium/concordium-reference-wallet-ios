//
//  AccountConfirmedViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class AccountConfirmedFactory {
    class func create(with presenter: AccountConfirmedPresenter) -> AccountConfirmedViewController {
        AccountConfirmedViewController.instantiate(fromStoryboard: "Account") {coder in
            return AccountConfirmedViewController(coder: coder, presenter: presenter)
        }
    }
}

class AccountConfirmedViewController: BaseViewController, AccountConfirmedViewProtocol, Storyboarded {

	var presenter: AccountConfirmedPresenterProtocol

    @IBOutlet weak var accountCardView: AccountCardView!
    
    init?(coder: NSCoder, presenter: AccountConfirmedPresenterProtocol) {
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
    
    func bind(title: String, accountViewModel: AccountViewModel) {
        self.title = title
        accountCardView.setup(accountViewModel: accountViewModel)
        accountCardView.showStatusImage(nil)
    }

    @IBAction func finishAction(_ sender: Any) {
        presenter.finish()
    }
}
