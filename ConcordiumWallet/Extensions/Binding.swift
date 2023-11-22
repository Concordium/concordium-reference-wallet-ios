//
//  Binding.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 07/11/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

extension Binding {
    /// Convenience method for getting the nullity of the wrapped value as a derived Binding.
    /// - Returns: A `Binding` of `Bool` where `true` indicates the wrapped value is not nil, and `false` indicates it is nil.
    func isNotNil<T>() -> Binding<Bool> where Value == T? {
        .init(get: {
            wrappedValue != nil
        }, set: { _ in })
    }
}
