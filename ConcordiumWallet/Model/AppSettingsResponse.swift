//
//  AppSettingsResponse.swift
//  ConcordiumWallet
//
//  Created by Lars Christensen on 16/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum AppSettingsResponse: Codable {
    case ok
    case warning(url: URL)
    case needsUpdate(url: URL)
    
    enum CodingKeys: String, CodingKey {
        case status
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let status = try container.decode(String.self, forKey: .status)
        
        switch status {
        case "ok":
            self = .ok
        case "warning":
            let url = try container.decode(URL.self, forKey: .url)
            
            self = .warning(url: url)
        case "needsUpdate":
            let url = try container.decode(URL.self, forKey: .url)
            
            self = .needsUpdate(url: url)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .status,
                in: container,
                debugDescription: "Unexpected value for status, found \(status)"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .ok:
            try container.encode("ok", forKey: .status)
        case let .warning(url):
            try container.encode("warning", forKey: .status)
            try container.encode(url, forKey: .url)
        case let .needsUpdate(url):
            try container.encode("needsUpdate", forKey: .status)
            try container.encode(url, forKey: .url)
        }
    }
}
