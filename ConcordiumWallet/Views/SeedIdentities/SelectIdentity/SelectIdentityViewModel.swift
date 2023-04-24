//
//  SelectIdentityViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 23/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum SelectIdentityEvent {
    case identitySelected(IdentityDataType)
}

class SelectIdentityViewModel: PageViewModel<SelectIdentityEvent> {
    @Published var title: String
    @Published var identities: [IdentityDataType]
    
    init(
        title: String,
        identities: [IdentityDataType]
    ) {
        self.title = title
        self.identities = identities
        
        super.init()
    }
}
