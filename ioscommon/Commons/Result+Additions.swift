//
// Created by Concordium on 24/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
extension Result {
    @discardableResult func onSuccess(_ handler: (Success) -> Void) -> Self {
        if case let .success(value) = self {
            handler(value)
        }
        return self
    }

    @discardableResult func onFailure(_ handler: (Failure) -> Void) -> Self {
        if case let .failure(error) = self {
            handler(error)
        }
        return self
    }
}
