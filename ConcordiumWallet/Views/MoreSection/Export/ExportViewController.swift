//
//  ExportViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 25/05/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class ExportFactory {
    class func create(with presenter: ExportPresenter) -> ExportViewController {
        ExportViewController.instantiate(fromStoryboard: "More") {coder in
            return ExportViewController(coder: coder, presenter: presenter)
        }
    }
}

class ExportViewController: BaseViewController, ExportViewProtocol, Storyboarded {

	var presenter: ExportPresenterProtocol

    init?(coder: NSCoder, presenter: ExportPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "export.title".localized
        presenter.view = self
        presenter.viewDidLoad()
    }

    @IBAction func exportButtonPressed(_ sender: Any) {
        presenter.export()
    }
}
