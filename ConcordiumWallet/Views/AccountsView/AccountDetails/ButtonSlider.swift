//
//  ButtonSlider.swift
//  ConcordiumWallet
//
//  Created by Lars Christensen on 23/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct ButtonSlider: View {
    var isShielded: Bool
    var actionTokens: () -> Void
    var actionSend: () -> Void
    var actionReceive: () -> Void
    var actionEarn: () -> Void
    var actionShield: () -> Void
    var actionSettings: () -> Void

    var isDisabled: Bool
    
    var buttons: [ActionButton] {
        [
            ActionButton(
                imageName: "ccd_coins",
                action: actionTokens
            ),
            ActionButton(
                imageName: "button_slider_send",
                action: actionSend
            ),
            ActionButton(
                imageName: "button_slider_earn",
                action: actionEarn
            ),
            ActionButton(
                imageName: "button_slider_receive",
                action: actionReceive
            ),
            isShielded ? ActionButton(
                imageName: "button_slider_shield",
                action: actionShield
            ) : nil,
            ActionButton(
                imageName: "button_slider_settings",
                action: actionSettings
            ),
        ]
        .compactMap { $0 }
    }

    var displayArrows: Bool { buttons.count > 5 }

    var body: some View {
        ScrollViewReader { proxy in
            HStack {
                if displayArrows {
                    Button(action: { buttons.first.map { b in withAnimation { proxy.scrollTo(b.id) } } }) {
                        Image("button_slider_back").padding()
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 24) {
                        VerticalLine()
                        ForEach(buttons) { btn in
                            btn
                            VerticalLine()
                        }
                    }
                }
                
                if displayArrows {
                    Button(action: { buttons.last.map { b in withAnimation { proxy.scrollTo(b.id) } } }) {
                        Image("button_slider_forward").padding()
                    }
                }
            }
            .disabled(isDisabled)
        }
        .background(isDisabled ? Pallette.inactiveButton : Pallette.primary)
        .cornerRadius(5)
    }
}

struct ActionButton: View, Identifiable {
    let imageName: String
    var action: () -> Void
    
    var id: String { imageName }

    var body: some View {
        Image(imageName)
            .onTapGesture {
                self.action()
            }
    }
}

struct VerticalLine: View {
    var body: some View {
        Divider()
            .frame(maxWidth: 1)
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
            actionSettings: {},
            isDisabled: false
        )
    }
}
