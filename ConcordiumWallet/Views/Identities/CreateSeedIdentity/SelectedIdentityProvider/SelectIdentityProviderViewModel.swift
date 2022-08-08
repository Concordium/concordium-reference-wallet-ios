//
//  SelectIdentityProviderViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum SelectIdentityProviderEvent {
    case showInfo(url: URL)
    case selectIdentityProvider(identityProvider: IPInfoResponseElement)
}

class SelectIdentityProviderViewModel: PageViewModel<SelectIdentityProviderEvent> {
    @Published var identityProviders: [IPInfoResponseElement]
    
    init(
        identityProviders: [IPInfoResponseElement]
    ) {
        self.identityProviders = identityProviders
        
        super.init()
    }
}
