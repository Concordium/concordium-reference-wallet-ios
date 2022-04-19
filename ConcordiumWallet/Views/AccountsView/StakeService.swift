//
//  StakeService.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 22/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

protocol StakeServiceProtocol {
    func getBakerPool(bakerId: Int) -> AnyPublisher<BakerPoolResponse, Error>
    func getPoolParameters() -> AnyPublisher<PoolParametersResponse, Error>
    func generateBakerKeys() -> Result<GeneratedBakerKeys, Error>
}

class StakeService: StakeServiceProtocol {
    let networkManager: NetworkManagerProtocol
    let mobileWallet: MobileWalletProtocol
    
    init(networkManager: NetworkManagerProtocol, mobileWallet: MobileWalletProtocol) {
        self.networkManager = networkManager
        self.mobileWallet = mobileWallet
    }
    
    func getPoolParameters() -> AnyPublisher<PoolParametersResponse, Error> {
        let request = ResourceRequest(url: ApiConstants.poolParameters)
        return networkManager.load(request)
    }
    
    func getBakerPool(bakerId: Int) -> AnyPublisher<BakerPoolResponse, Error> {
        let request = ResourceRequest(url: ApiConstants.bakerPool.appendingPathComponent("\(bakerId)"))
        return networkManager.load(request)
    }
    
    func generateBakerKeys() -> Result<GeneratedBakerKeys, Error> {
        return mobileWallet.generateBakerKeys()
    }
}
