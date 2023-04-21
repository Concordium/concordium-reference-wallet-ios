//
//  CreationFailedViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class CreationFailedFactory {
    class func create(with presenter: CreationFailedPresenter) -> CreationFailedViewController {
        CreationFailedViewController.instantiate(fromStoryboard: "Account") { coder in
            return CreationFailedViewController(coder: coder, presenter: presenter)
        }
    }
}

class CreationFailedViewController: BaseViewController, CreationFailedViewProtocol, Storyboarded {

    @IBOutlet weak var errorTitleLabel: UILabel! {
        didSet {
            errorTitleLabel.text = ""
        }
    }
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.text = ""
        }
    }
    @IBOutlet weak var okButton: StandardButton! {
        didSet {
            okButton.setTitle("", for: .normal)
        }
    }
    @IBOutlet weak var tryAgainLabel: UILabel! {
        didSet {
            tryAgainLabel.text = ""
        }
    }
    
    var presenter: CreationFailedPresenterProtocol

    init?(coder: NSCoder, presenter: CreationFailedPresenterProtocol) {
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

    func set(errorTitle: String) {
        errorTitleLabel.text = errorTitle
    }

    func set(errorMessage: String) {
        errorLabel.text = errorMessage
    }
    
    func set(viewControllerTitle: String) {
        title = viewControllerTitle
    }
    
    func set(tryAgainMessage: String) {
        tryAgainLabel.text = tryAgainMessage
    }
    
    func set(buttonTitle: String) {
        okButton.setTitle(buttonTitle, for: .normal)
    }

    @IBAction func finishAction(_ sender: Any) {
        presenter.finish()
    }
}
