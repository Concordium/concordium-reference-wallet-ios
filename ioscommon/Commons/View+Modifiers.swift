//
//  View+Modifiers.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 30/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

extension View {
    func ignoreAnimations() -> some View {
        transaction { transaction in
            transaction.animation = nil
        }
    }
}
