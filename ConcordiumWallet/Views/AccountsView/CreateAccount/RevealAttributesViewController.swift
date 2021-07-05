//
//  RevealAttributesViewController.swift
//  ConcordiumWallet
//
//  Concordium on 17/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class RevealAttributesFactory {
    class func create(with presenter: RevealAttributesPresenter) -> RevealAttributesViewController {
        RevealAttributesViewController.instantiate(fromStoryboard: "Account") { coder in
            return RevealAttributesViewController(coder: coder, presenter: presenter)
        }
    }
}

class RevealAttributesViewController: BaseViewController, RevealAttributesViewProtocol, Storyboarded {

    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var revealAttributesButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!

    var presenter: RevealAttributesPresenterProtocol

    init?(coder: NSCoder, presenter: RevealAttributesPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "revealattributes.title".localized
        
        let addIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: addIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
        
        presenter.view = self
        presenter.viewDidLoad()
    }

    @IBAction func revealAction(_ sender: Any) {
        presenter.revealAttributes()
    }
    
    @IBAction func finishAction(_ sender: Any) {
        presenter.finish()
    }
    
    @objc func closeButtonTapped() {
        presenter.closeButtonPressed()
    }
}
