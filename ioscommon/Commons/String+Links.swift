//
//  String+Links.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 19/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

extension String {
    func stringWithHighlightedLink(text: String, link: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        var currentRange = attributedString.mutableString.range(of: text)
        while currentRange.location != NSNotFound {
            attributedString.addAttribute(.link, value: link, range: currentRange)
            currentRange = attributedString
                .mutableString
                .range(
                    of: text,
                    range: NSRange(
                        location: currentRange.upperBound,
                        length: attributedString.mutableString.length - currentRange.upperBound
                    )
                )
        }
        return attributedString
    }
}
