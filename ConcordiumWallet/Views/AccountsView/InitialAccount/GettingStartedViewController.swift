//
//  GettingStartedViewController.swift
//  ConcordiumWallet
//
//  Concordium on 11/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class GettingStartedFactory {
    class func create(with presenter: GettingStartedPresenter) -> GettingStartedViewController {
        GettingStartedViewController.instantiate(fromStoryboard: "Identity") { coder in
            return GettingStartedViewController(coder: coder, presenter: presenter)
        }
    }
}

class GettingStartedViewController: BaseViewController, GettingStartedViewProtocol, Storyboarded {

    var presenter: GettingStartedPresenterProtocol
    
    private var cancellables = [AnyCancellable]()
    
    @IBOutlet weak var createAccountButton: StandardButton! {
        didSet {
            createAccountButton.setTitle("gettingstarted.newaccount".localized, for: .normal)
        }
    }
    
    @IBOutlet weak var importAccountButton: StandardButton! {
        didSet {
            importAccountButton.setTitle("gettingstarted.importaccount".localized, for: .normal)
        }
    }
    
    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = "gettingstarted.subtitle".localized
        }
    }
    @IBOutlet weak var detailsLabel: UILabel! {
        didSet {
            detailsLabel.text = "gettingstarted.details".localized
        }
    }
    
    init?(coder: NSCoder, presenter: GettingStartedPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
        self.title = "gettingstarted.title".localized
    }

    @IBAction func createAccountsTapped(_ sender: Any) {
        presenter.userTappedCreateAccount()
    }
    
    @IBAction func importTapped(_ sender: Any) {
        presenter.userTappedImport()
    }
}
