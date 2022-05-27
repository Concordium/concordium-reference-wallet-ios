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
    func getAppSettings() -> AnyPublisher<AppSettingsResponse, Error>
}

class AppSettingsService: AppSettingsServiceProtocol {
    
    let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func getAppSettings() -> AnyPublisher<AppSettingsResponse, Error> {
        let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        let request = ResourceRequest(url: ApiConstants.appSettings, parameters: [ "platform": "ios", "appVersion": appVersion ])
        return networkManager.load(request)
    }
}
