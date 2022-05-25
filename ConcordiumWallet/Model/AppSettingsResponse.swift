//
//  AppSettingsResponse.swift
//  ConcordiumWallet
//
//  Created by Lars Christensen on 16/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct AppSettingsResponse: Codable {
    let status: AppSettingsStatus
    let url: URL?
}

enum AppSettingsStatus: String, Codable {
    case ok
    case warning
    case needsUpdate
}
