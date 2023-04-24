//
//  CreateSeedIdentityViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum CreateSeedIdentityEvent {
    case failedToLoad(Error)
    case receivedCallback(String)
    case close
}

class CreateSeedIdentityViewModel: PageViewModel<CreateSeedIdentityEvent> {
    @Published var request: URLRequest?
    
    init(
        request: URLRequest?
    ) {
        self.request = request
        
        super.init()
    }
}
