//
//  URL+queryParameters.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/14/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
    public var queryFragments: [String: String]? {
        var components = URLComponents()
        components.query = self.fragment
        guard let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
    public var urlWithoutParameters: URL? {
        guard var components = URLComponents(string: self.absoluteString) else {
            return nil
        }
        components.query = nil
        return components.url
    }
}
