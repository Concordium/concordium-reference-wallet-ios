//
//  SeedIdentityStatusPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol SeedIdentityStatusPresenterDelegate: AnyObject {
    
}

class SeedIdentityStatusPresenter: SwiftUIPresenter<SeedIdentityStatusViewModel> {
    private weak var delegate: SeedIdentityStatusPresenterDelegate?
    
    init(
        delegate: SeedIdentityStatusPresenterDelegate
    ) {
        self.delegate = delegate
        
        super.init(
            viewModel: .init()
        )
    }
}
