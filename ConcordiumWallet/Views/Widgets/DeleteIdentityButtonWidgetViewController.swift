//
//  DeleteIdentityButtonWidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 22/06/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

// MARK: View
protocol DeleteIdentityButtonWidgetViewProtocol: AnyObject {

}

class DeleteIdentityButtonWidgetFactory {
    class func create(with presenter: DeleteIdentityButtonWidgetPresenter) -> DeleteIdentityButtonWidgetViewController {
        DeleteIdentityButtonWidgetViewController.instantiate(fromStoryboard: "Widget") { coder in
            return DeleteIdentityButtonWidgetViewController(coder: coder, presenter: presenter)
        }
    }
}

class DeleteIdentityButtonWidgetViewController: BaseViewController, DeleteIdentityButtonWidgetViewProtocol, Storyboarded {

	var presenter: DeleteIdentityButtonWidgetPresenterProtocol

    init?(coder: NSCoder, presenter: DeleteIdentityButtonWidgetPresenterProtocol) {
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

    @IBAction func deleteButtonTapped(_ sender: Any) {
        presenter.deleteButtonTapped()
    }
}
