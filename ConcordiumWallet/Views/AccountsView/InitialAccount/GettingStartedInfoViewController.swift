//
//  GettingStartedInfoViewController.swift
//  ConcordiumWallet
//
//  Concordium on 11/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class GettingStartedInfoFactory {
    class func create(with presenter: GettingStartedInfoPresenter) -> InitialAccountInfoViewController {
        InitialAccountInfoViewController.instantiate(fromStoryboard: "Identity") { coder in
            return InitialAccountInfoViewController(coder: coder, presenter: presenter)
        }
    }
}

class InitialAccountInfoViewController: BaseViewController, GettingStartedInfoViewProtocol, Storyboarded {

    var presenter: GettingStartedInfoPresenterProtocol
    
    private var cancellables = [AnyCancellable]()
    
    @IBOutlet weak var okButton: StandardButton! {
        didSet {
            okButton.setTitle("".localized, for: .normal)
        }
    }

    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = "".localized
        }
    }
    @IBOutlet weak var detailsLabel: UILabel! {
        didSet {
            detailsLabel.text = "".localized
        }
    }
    
    init?(coder: NSCoder, presenter: GettingStartedInfoPresenterProtocol) {
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

    @IBAction func okTapped(_ sender: Any) {
        presenter.userTappedOK()
    }
}
