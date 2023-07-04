//
//  WalletConnectService.swift
//  ConcordiumWallet
//
//  Created by Michael Olesen on 04/07/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
import WalletConnectSign

class WalletConnectService {
    let client: SignClient
    let session: Session? = nil
    
    init(client: SignClient) {
        self.client = client
    }
    
}
