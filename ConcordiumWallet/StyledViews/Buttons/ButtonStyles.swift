//
//  ButtonStyles.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct StandardStyle: ButtonStyle {
    let disabled: Bool
    let padding: CGFloat
    let fillWidth: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(padding)
            .frame(maxWidth: fillWidth ? .infinity : nil)
            .background(disabled ? Pallette.inactiveButton : Pallette.primary)
            .cornerRadius(10)
            .foregroundColor(configuration.isPressed ? .white.opacity(0.2) : .white)
            .font(Font(Fonts.buttonTitle))
    }
}

extension Button {
    func applyStandardButtonStyle(
        disabled: Bool = false,
        padding: CGFloat = 15,
        fillWidth: Bool = true
    ) -> some View {
        buttonStyle(
            StandardStyle(
                disabled: disabled,
                padding: padding,
                fillWidth: fillWidth
            )
        ).disabled(disabled)
    }
}
