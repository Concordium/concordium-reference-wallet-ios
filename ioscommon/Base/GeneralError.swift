//
// Created by Concordium on 07/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

enum GeneralError: Error, Equatable {
    case unexpectedNullValue
    case userCancelled
    
    static func isGeneralError(_ target: GeneralError, error: Error) -> Bool {
        if let generalError = error as? GeneralError {
            return generalError == target
        } else {
            return false
        }
    }
}
