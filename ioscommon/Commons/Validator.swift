//
//  Validator.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 22/02/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum ValidationType {
    case nameLength(String)
    case memoSize(Memo)
}

struct ValidationProvider {
    static func validate(_ type: ValidationType) -> Bool {
        switch type {
        case .nameLength(let name):
            return NameLengthValidator.isValid(name)
        case .memoSize(let memo):
            return MemoSizeValidator.isValid(memo)
        }
    }
}

// MARK: - Memo Size Validator
private struct MemoSizeValidator {
    private static let maxBytes = 256

    static func isValid(_ value: Memo?) -> Bool {
        guard let value = value else { return false }
        return value.size <= maxBytes
    }
}

// MARK: - Name Length Validator
private struct NameLengthValidator {

    private static let regexPattern = "^.{1,35}$" // Min 1, Max 35 characters

    static func isValid(_ value: String?) -> Bool {
        guard let value = value else { return false }

        let range = NSRange(location: 0, length: value.count)

        do {
            if try
                NSRegularExpression(
                    pattern: regexPattern,
                    options: .caseInsensitive
                )
                .firstMatch(
                    in: value,
                    options: [],
                    range: range
                ) == nil {
                return false
            }
        } catch {
            return false
        }

        return true
    }
}
