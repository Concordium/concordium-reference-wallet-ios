//
//  UpdatePasswordViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/03/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit

class UpdatePasswordFactory {
    class func create(with presenter: UpdatePasswordPresenter) -> UpdatePasswordViewController {
        UpdatePasswordViewController.instantiate(fromStoryboard: "Login") { coder in
            return UpdatePasswordViewController(coder: coder, presenter: presenter)
        }
    }
}

class UpdatePasswordViewController: BaseViewController, UpdatePasswordViewProtocol, Storyboarded {
    var presenter: UpdatePasswordPresenterProtocol
 
    @IBOutlet weak var infoTextView: UITextView!
    
    init?(coder: NSCoder, presenter: UpdatePasswordPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "more.updatePasswordAndBiometrics.title".localized
        
        let addIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: addIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
       
        infoTextView.text = "more.updatePasswordAndBiometrics.infoText".localized
        
        presenter.view = self
        presenter.viewDidLoad()
    }
        
    @objc func closeButtonTapped(_ sender: Any) {
        presenter.closeButtonPressed()
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        presenter.userSelectedContinue()
    }
}
