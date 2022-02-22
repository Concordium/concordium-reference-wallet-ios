//
//  Validator.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 22/02/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol ValidatorConvertible {
    func isValid(_ value: String?) -> Bool
}

enum ValidatorType {
    case nameLength
}

enum ValidationProvider {
    static func validator(for type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .nameLength:
            return NameLengthValidator()
        }
    }
}

// MARK: - Name Validator

struct NameLengthValidator: ValidatorConvertible {

    private let regexPattern = "^.{1,35}$" // Min 1, Max 35 characters

    func isValid(_ value: String?) -> Bool {
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
