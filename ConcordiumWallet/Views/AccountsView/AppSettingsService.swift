//
//  AppSettingsService.swift
//  ConcordiumWallet
//
//  Created by Lars Christensen on 16/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

protocol AppSettingsServiceProtocol {
    func getAppSettings(platform: String, version: String) -> AnyPublisher<AppSettingsResponse, Error>
}

class AppSettingsService: AppSettingsServiceProtocol {
    
    let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func getAppSettings(platform: String, version: String) -> AnyPublisher<AppSettingsResponse, Error> {
        let request = ResourceRequest(url: ApiConstants.appSettings, parameters: [ "platform": platform, "appVersion": version ])
        return networkManager.load(request)
    }
}
