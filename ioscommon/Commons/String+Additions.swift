//
//  String+Additions.swift
//  Quiz
//
//  Created by Valentyn Kovalsky on 03/10/2018.
//  Copyright © 2018 Springfeed. All rights reserved.
//

import CryptoKit
import UIKit

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }

    func matches (regex rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    var isNegative: Bool {
        if self.contains("-") {
            return true
        }
        return false
    }
    
    var unsignedWholePart: Int {
        let decimalSeparator = NumberFormatter().decimalSeparator!
        let sep = decimalSeparator[decimalSeparator.startIndex]
        let splits = self.split(whereSeparator: {$0 == sep})
        if splits.count == 0 {
            return 0
        }
        if splits.count == 1 && self[self.startIndex] == sep {
            return 0
        }
        return abs(Int(splits[0]) ?? 0)
    }
    
    func fractionalPart(precision: Int) -> Int {
        let decimalSeparator = NumberFormatter().decimalSeparator!
        let sep = decimalSeparator[decimalSeparator.startIndex]
        let splits = self.split(whereSeparator: {$0 == sep})
        
        if splits.count == 0 {
            return 0
        }
        var fractional: String
        if splits.count == 1 {
            if self[self.startIndex] == sep {
                fractional = String(splits[0])
            } else {
                fractional = ""
            }
        } else {
            fractional = String(splits[1])
        }
        
        if fractional.count < precision {
            let appendedZeros = precision - fractional.count
            for _ in 0..<appendedZeros {
                fractional += "0"
            }
        }
        // remove all after precision
        let endIndex = fractional.index(startIndex, offsetBy: precision)
        fractional = String(fractional[startIndex..<endIndex])
        
        return Int(fractional) ?? 0
    }
    
    func isValidName() -> Bool {
        if self.first == " " || self.last == " " { return false }
        
        let alphaNum = CharacterSet.alphanumerics
        let nonBasedCharacters = CharacterSet.nonBaseCharacters
        let alphaNumWithoutNonBased = alphaNum.subtracting(nonBasedCharacters)
        let specials = CharacterSet(charactersIn: "-_,.!? ")
        let allIncluded = alphaNumWithoutNonBased.union(specials)

        return self.trimmingCharacters(in: allIncluded) == ""
    }

    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."

        var versionComponents = components(separatedBy: versionDelimiter)
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

        let zeroDiff = versionComponents.count - otherVersionComponents.count

        if zeroDiff == 0 {
            return self.compare(otherVersion, options: .numeric)
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff))
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros)
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents
                .joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric)
        }
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

        return ceil(boundingBox.height)
    }
}
