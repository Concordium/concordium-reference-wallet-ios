//
//  IdentityBaseInfoWidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
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

class IdentityBaseInfoWidgetViewController: BaseViewController, IdentityBaseInfoWidgetViewProtocol, Storyboarded, IdentityCardViewDelegate {
    
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
        identityCardView.applyConcordiumEdgeStyle(color: presenter.identityViewModel.widgetColor)
        
        identityCardView.delegate = self
    }
    
    func edit() {
        let alert = UIAlertController(title: "renameidentity.title".localized, message: "renameidentity.message".localized, preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = self.presenter.identityViewModel.nickname
        }

        let saveAction = UIAlertAction(title: "renameidentity.save".localized, style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields![0], let newName = textField.text, !newName.isEmpty {
                do {
                    try self.presenter.identityViewModel.identity.write {
                        var mutableIdentity = $0
                        mutableIdentity.nickname = newName
                    }.get()
                    self.identityCardView.titleLabel?.text = newName
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        })

        let cancelAction = UIAlertAction(title: "renameidentity.cancel".localized, style: .cancel, handler: nil)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}
