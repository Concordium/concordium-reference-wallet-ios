//
//  ButtonSlider.swift
//  ConcordiumWallet
//
//  Created by Lars Christensen on 23/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

private let size: CGFloat = 55.00

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

struct ButtonSlider: View {
    var isShielded: Bool
    var actionTokens: () -> Void
    var actionSend: () -> Void
    var actionReceive: () -> Void
    var actionEarn: () -> Void
    var actionShield: () -> Void
    var actionSettings: () -> Void

    @State var disabled: Bool = false
    var buttons: [ActionButton] {
        [
            ActionButton(
                imageName: "ccd_coins",
                disabled: disabled,
                action: actionTokens
            ),
            ActionButton(
                imageName: "button_slider_send",
                disabled: disabled,
                action: actionSend
            ),
            ActionButton(
                imageName: "button_slider_earn",
                disabled: disabled,
                action: actionEarn
            ),
            ActionButton(
                imageName: "button_slider_receive",
                disabled: disabled,
                action: actionReceive
            ),
            isShielded ? ActionButton(
                imageName: "button_slider_shield",
                disabled: disabled,
                action: actionShield
            ) : nil,
            ActionButton(
                imageName: "button_slider_settings",
                disabled: disabled,
                action: actionSettings
            ),
        ]
        .compactMap { $0 }
    }

    var shouldHideArrows: Bool { buttons.count < 5 }

    var body: some View {
        HStack {
            Button(action: { /* TODO */ }) {
                Image("button_slider_back").padding()
            }
            .hidden(shouldHideArrows)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 24) {
                    VerticalLine()
                    ForEach(buttons) { item in
                        item
                            .frame(height: size)
                        VerticalLine()
                    }
                }
            }
            Button(action: { /* TODO */ }) {
                Image("button_slider_forward").padding()
            }
            .hidden(shouldHideArrows)
        }
        .frame(maxWidth: .infinity, maxHeight: size)
        .background(Pallette.primary)
        .cornerRadius(5)
    }
}

struct ActionButton: View, Identifiable {
    let imageName: String
    var disabled: Bool = false
    var action: () -> Void
    
    var id: String { imageName }

    var body: some View {
        Image(imageName)
            .background(disabled ? Pallette.inactiveButton : Pallette.primary)
            .onTapGesture {
                self.action()
            }
            .disabled(disabled)
    }
}

struct VerticalLine: View {
    var body: some View {
        Divider()
            .frame(maxWidth: 1, maxHeight: size)
            .background(Pallette.whiteText)
    }
}

struct ButtonSlider_Previews: PreviewProvider {
    static var previews: some View {
        ButtonSlider(
            isShielded: true,
            actionTokens: {},
            actionSend: {},
            actionReceive: {},
            actionEarn: {},
            actionShield: {},
            actionSettings: {}
        )
    }
}
