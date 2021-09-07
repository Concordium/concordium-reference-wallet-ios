//
//  ContactSupportButtonWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 07/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

// MARK: - Delegate
protocol ContactSupportButtonWidgetPresenterDelegate: AnyObject {
    func contactSupportButtonWidgetDidContactSupport()
}

// MARK: - Presenter
protocol ContactSupportButtonWidgetPresenterProtocol: AnyObject {
    var view: ContactSupportButtonWidgetViewProtocol? { get set }
    func viewDidLoad()
    func contactSupportButtonTapped()
}

class ContactSupportButtonWidgetPresenter: ContactSupportButtonWidgetPresenterProtocol {
    
    var view: ContactSupportButtonWidgetViewProtocol?
    weak var delegate: ContactSupportButtonWidgetPresenterDelegate?
    private let identity: IdentityDataType

    init(
        identity: IdentityDataType,
        delegate: ContactSupportButtonWidgetPresenterDelegate
    ) {
        self.delegate = delegate
        self.identity = identity
    }
    
    func viewDidLoad() {}
    
    func contactSupportButtonTapped() {
        guard let reference = IdentityFailureHelper.hash(codeUri: identity.ipStatusUrl) else { return }
        view?.launchSupport(with: reference)
        delegate?.contactSupportButtonWidgetDidContactSupport()
    }
}
