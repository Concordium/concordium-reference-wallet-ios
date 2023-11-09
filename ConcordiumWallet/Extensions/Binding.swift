//
//  Binding.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 07/11/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

extension Binding {
    /// A SwiftUI extension on `Binding` that provides a convenient method for checking whether the wrapped value is not nil.
    /// - Returns: A `Binding` of `Bool` where `true` indicates the wrapped value is not nil, and `false` indicates it is nil.
    func isNotNil<T>() -> Binding<Bool> where Value == T? {
        .init(get: {
            wrappedValue != nil
        }, set: { _ in
            wrappedValue = nil
        })
    }
}
