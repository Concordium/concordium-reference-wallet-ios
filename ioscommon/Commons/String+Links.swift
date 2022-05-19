//
//  String+Links.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 19/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

extension String {
    func stringWithHighlightedLinks(_ links: [String: String]) -> NSAttributedString {
        guard !links.isEmpty else {
            return NSAttributedString(string: self)
        }
        
        guard let regex = try? NSRegularExpression(pattern: links.keys.joined(separator: "|")) else {
            return NSAttributedString(string: self)
        }
        
        return regex.matches(in: self, range: NSRange(location: 0, length: count))
            .reduce(NSMutableAttributedString(string: self)) { partialResult, matchResult in
                let key = partialResult.mutableString.substring(with: matchResult.range)
                if let value = links[key] {
                    partialResult.addAttribute(.link, value: value, range: matchResult.range)
                }
                
                return partialResult
            }
    }
}
