//
//  DeleteIdentityButtonWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 22/06/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// Add this to your coordinator:
//    func showDeleteIdentityButtonWidget() {
//        let vc = DeleteIdentityButtonWidgetFactory.create(with: DeleteIdentityButtonWidgetPresenter(delegate: self))
//        navigationController.pushViewController(vc, animated: false)
//    }

// MARK: -
// MARK: Delegate
protocol DeleteIdentityButtonWidgetPresenterDelegate: AnyObject {
    func deleteIdentityButtonWidgetDidDelete()
}

// MARK: -
// MARK: Presenter
protocol DeleteIdentityButtonWidgetPresenterProtocol: AnyObject {
	var view: DeleteIdentityButtonWidgetViewProtocol? { get set }
    func viewDidLoad()
    func deleteButtonTapped()
}

class DeleteIdentityButtonWidgetPresenter: DeleteIdentityButtonWidgetPresenterProtocol {

    weak var view: DeleteIdentityButtonWidgetViewProtocol?
    weak var delegate: DeleteIdentityButtonWidgetPresenterDelegate?
    private let identity: IdentityDataType
    private let dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider

    init(identity: IdentityDataType,
         dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider,
         delegate: DeleteIdentityButtonWidgetPresenterDelegate? = nil) {
        self.delegate = delegate
        self.identity = identity
        self.dependencyProvider = dependencyProvider
    }

    func viewDidLoad() {
    }
    
    func deleteButtonTapped() {
        dependencyProvider.storageManager().removeIdentity(identity)
        delegate?.deleteIdentityButtonWidgetDidDelete()
    }
}
