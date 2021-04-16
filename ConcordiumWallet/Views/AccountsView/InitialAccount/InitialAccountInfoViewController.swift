//
//  GettingStartedInfoViewController.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 11/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class InitialAccountInfoFactory {
    class func create(with presenter: InitialAccountInfoPresenter) -> InitialAccountInfoViewController {
        InitialAccountInfoViewController.instantiate(fromStoryboard: "Identity") { coder in
            return InitialAccountInfoViewController(coder: coder, presenter: presenter)
        }
    }
}

class InitialAccountInfoViewController: BaseViewController, InitialAccountInfoViewProtocol, Storyboarded {

    var presenter: InitialAccountInfoPresenterProtocol
    
    private var cancellables = [AnyCancellable]()
    
    @IBOutlet weak var okButton: StandardButton! {
        didSet {
            okButton.setTitle("okay.gotit".localized, for: .normal)
        }
    }

    @IBOutlet weak var subtitleLabel: UILabel! 
    @IBOutlet weak var detailsLabel: UILabel!
    
    init?(coder: NSCoder, presenter: InitialAccountInfoPresenterProtocol) {
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

    func setup(details: String) {
        self.detailsLabel.text = details
    }
    
    func bind(to viewModel: InitialAccountInfoViewModel) {
        self.title = viewModel.title
        self.subtitleLabel.text = viewModel.subtitle
        self.detailsLabel.text = viewModel.details
        self.okButton.setTitle(viewModel.buttonTitle, for: .normal)
        if viewModel.showsClose {
            let addIcon = UIImage(named: "close_icon")
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: addIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
        }
    }
    
    @objc func closeButtonTapped(_ sender: Any) {
        presenter.userTappedClose()
    }
    
    @IBAction func okTapped(_ sender: Any) {
        presenter.userTappedOK()
    }
}
