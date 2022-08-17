//
//  SeedIdentityStatusPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

protocol SeedIdentityStatusPresenterDelegate: AnyObject {
    func seedIdentityStatusDidFinish(with identity: IdentityDataType)
}

class SeedIdentityStatusPresenter: SwiftUIPresenter<SeedIdentityStatusViewModel> {
    private weak var delegate: SeedIdentityStatusPresenterDelegate?
    
    private let identity: IdentityDataType
    
    init(
        identity: IdentityDataType,
        delegate: SeedIdentityStatusPresenterDelegate
    ) {
        self.identity = identity
        self.delegate = delegate
        let identityViewModel = IdentityCard.ViewModel()
        identityViewModel.update(with: identity)
        
        super.init(
            viewModel: .init(
                title: "identities.seed.status.title".localized,
                body: "identities.seed.status.body".localized,
                identityViewModel: identityViewModel,
                continueLabel: "identities.seed.status.continue".localized
            )
        )
        
        viewModel.navigationTitle = "identities.seed.status.navigationtitle".localized
    }
    
    override func receive(event: SeedIdentityStatusEvent) {
        switch event {
        case .finish:
            delegate?.seedIdentityStatusDidFinish(with: identity)
        }
    }
}
