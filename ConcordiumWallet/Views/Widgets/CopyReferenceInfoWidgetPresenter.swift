//
//  CopyReferenceInfoWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 15/10/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

// MARK: - Presenter

protocol CopyReferenceInfoWidgetPresenterProtocol {
    var view: CopyReferenceInfoWidgetViewProtocol? { get set }
    var identityProviderName: String { get }
    var identityProviderSupportEmail: String { get }
    func viewDidLoad()
}

class CopyReferenceInfoWidgetPresenter: CopyReferenceInfoWidgetPresenterProtocol {
    var view: CopyReferenceInfoWidgetViewProtocol?
    var identityProviderName: String
    var identityProviderSupportEmail: String
    
    func viewDidLoad() {}
    
    init(
        identityProviderName: String,
        identityProviderSupportEmail: String
    ) {
        self.identityProviderName = identityProviderName
        self.identityProviderSupportEmail = identityProviderSupportEmail
    }
    
}
