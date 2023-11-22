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
    var didTapTokensButton: () -> Void
    var actionSend: () -> Void
    var didTapTransactionList: () -> Void
    var actionReceive: () -> Void
    var actionEarn: () -> Void
    var actionShield: () -> Void
    var actionSettings: () -> Void
    var isDisabled: Bool
    
    var buttons: [ActionButton] {
        [
            ActionButton(
                imageName: "ccd_coins",
                action: didTapTokensButton
            ),
            ActionButton(
                imageName: "button_slider_send",
                action: actionSend
            ),
            ActionButton(
                imageName: "transaction_list",
                action: didTapTransactionList
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
                
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 24) {
                            VerticalLine()
                            ForEach(buttons) { btn in
                                btn
                                VerticalLine()
                            }
                        }
                    }
                    Button(action: { buttons.last.map { b in withAnimation { proxy.scrollTo(b.id) } } }) {
                        Image("button_slider_forward").padding()
                    }
                } else {
                    HStack {
                        ForEach(buttons) { btn in
                            VerticalLine()
                            Spacer()
                            btn
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
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
    var isSelected: Bool = false
    var id: String { imageName }

    var body: some View {
        VStack {
            Image(imageName)
                .frame(width: 32, height: 32)
                .onTapGesture {
                    self.action()
                }
            if isSelected {
                Divider()
                    .frame(height: 2)
                    .background(Pallette.whiteText)
            }
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
            didTapTokensButton: {},
            actionSend: {},
            didTapTransactionList: {},
            actionReceive: {},
            actionEarn: {},
            actionShield: {},
            actionSettings: {},
            isDisabled: false
        )
        .frame(width: 500,height: 80)
    }
}
