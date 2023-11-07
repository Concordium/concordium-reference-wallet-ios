//
//  Binding.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 07/11/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

extension Binding {
    func isNotNil<T>() -> Binding<Bool> where Value == T? {
        .init(get: {
            wrappedValue != nil
        }, set: { _ in
            wrappedValue = nil
        })
    }
}
