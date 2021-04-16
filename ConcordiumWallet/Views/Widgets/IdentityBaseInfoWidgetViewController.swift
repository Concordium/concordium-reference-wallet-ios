//
//  IdentityBaseInfoWidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Johan Rugager Vase on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class IdentityBaseInfoWidgetFactory {
    class func create(with presenter: IdentityBaseInfoWidgetPresenter) -> IdentityBaseInfoWidgetViewController {
        IdentityBaseInfoWidgetViewController.instantiate(fromStoryboard: "Widget") {coder in
            return IdentityBaseInfoWidgetViewController(coder: coder, presenter: presenter)
        }
    }
}

class IdentityBaseInfoWidgetViewController: BaseViewController, IdentityBaseInfoWidgetViewProtocol, Storyboarded {

    var presenter: IdentityBaseInfoWidgetPresenterProtocol
    
    @IBOutlet weak var identityCardView: IdentityCardView!

    init?(coder: NSCoder, presenter: IdentityBaseInfoWidgetPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self

        identityCardView.titleLabel?.text = presenter.identityViewModel.nickname
        identityCardView.iconImageView?.image = UIImage.decodeBase64(toImage: presenter.identityViewModel.encodedImage)
        identityCardView.expirationDateLabel?.text = presenter.identityViewModel.bottomLabel
        identityCardView.statusIcon.image = UIImage(named: presenter.identityViewModel.bottomIcon)

    }
}
