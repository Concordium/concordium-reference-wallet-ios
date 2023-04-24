//
//  SelectIdentityPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 23/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol SelectIdentityPresenterDelegate: AnyObject {
    func selectIdentityPresenter(didSelectIdentity identity: IdentityDataType)
}

class SelectIdentityPresenter: SwiftUIPresenter<SelectIdentityViewModel> {
    private weak var delegate: SelectIdentityPresenterDelegate?
    
    init(
        identities: [IdentityDataType],
        delegate: SelectIdentityPresenterDelegate
    ) {
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                title: "selectidentity.title".localized,
                identities: identities
            )
        )
        
        viewModel.navigationTitle = "selectidentity.navigationtitle".localized
    }
    
    override func receive(event: SelectIdentityEvent) {
        switch event {
        case .identitySelected(let identityDataType):
            delegate?.selectIdentityPresenter(didSelectIdentity: identityDataType)
        }
    }
}
