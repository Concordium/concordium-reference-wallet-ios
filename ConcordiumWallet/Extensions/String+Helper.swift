//
//  String+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 2.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

extension String {
    
    static let numberFormatter = NumberFormatter()
    
    var floatValue: Float {
        String.numberFormatter.formatterBehavior = .behavior10_4
        String.numberFormatter.numberStyle = .decimal
        String.numberFormatter.decimalSeparator = ","
        String.numberFormatter.groupingSeparator = "."
        if let result = String.numberFormatter.number(from: self) {
            return result.floatValue
        }
        
        return 0
    }
    
    //
    func applyPatternOnNumbers(pattern: String = "###-###-####", replacmentCharacter: Character = "#") -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        
        return pureNumber
    }
    
    //
    func replace(firstDigitIndex: Int, secondDigitIndex: Int, firstDigitChar: Character, secondDigitChar: Character) -> String {
        var chars = Array(self)     // gets an array of characters
        chars[firstDigitIndex] = firstDigitChar
        chars[secondDigitIndex] = secondDigitChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    //
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }
    
    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        return String(self[start...])
    }
}
