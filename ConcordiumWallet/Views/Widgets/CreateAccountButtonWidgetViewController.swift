//
//  CreateAccountButtonWidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/22/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class CreateAccountButtonWidgetFactory {
    class func create(with presenter: CreateAccountButtonWidgetPresenter) -> CreateAccountButtonWidgetViewController {
        CreateAccountButtonWidgetViewController.instantiate(fromStoryboard: "Widget") { coder in
            return CreateAccountButtonWidgetViewController(coder: coder, presenter: presenter)
        }
    }
}

class CreateAccountButtonWidgetViewController: BaseViewController, CreateAccountButtonWidgetViewProtocol, Storyboarded {

	var presenter: CreateAccountButtonWidgetPresenterProtocol
    
    init?(coder: NSCoder, presenter: CreateAccountButtonWidgetPresenterProtocol) {
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

    @IBAction func createAccountTapped(_ sender: Any) {
        presenter.createAccountTapped()
    }
}
