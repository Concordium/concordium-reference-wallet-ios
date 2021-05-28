//
//  IdentityRevokersWidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class IdentityRevokersWidgetFactory {
    class func create(with presenter: IdentityRevokersWidgetPresenter) -> IdentityRevokersWidgetViewController {
        IdentityRevokersWidgetViewController.instantiate(fromStoryboard: "Widget") {coder in
            return IdentityRevokersWidgetViewController(coder: coder, presenter: presenter)
        }
    }
}

class IdentityRevokersWidgetViewController: BaseViewController, IdentityRevokersWidgetViewProtocol, Storyboarded {

	var presenter: IdentityRevokersWidgetPresenterProtocol

    init?(coder: NSCoder, presenter: IdentityRevokersWidgetPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
    }
}
