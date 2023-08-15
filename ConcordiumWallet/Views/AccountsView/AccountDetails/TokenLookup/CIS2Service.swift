//
//  CIS2Service.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 10/08/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine

protocol CIS2ServiceProtocol {
    func fetchTokens(contractIndex: String, contractSubindex: String) -> AnyPublisher<CIS2Tokens, Error>
}

class CIS2Service: CIS2ServiceProtocol {
    let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    func fetchTokens(contractIndex: String, contractSubindex: String = "0") -> AnyPublisher<CIS2Tokens, Error> {
        networkManager.load(
            ResourceRequest(url: ApiConstants.cis2Tokens.appendingPathComponent(contractIndex).appendingPathComponent(contractSubindex)
            )
        )
    }
}
