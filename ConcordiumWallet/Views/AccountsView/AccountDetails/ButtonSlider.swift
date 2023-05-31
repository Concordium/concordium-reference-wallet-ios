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
        /// Representation of single item in slider.
        enum SliderItem: Int, Identifiable {
            var id: Int { rawValue }
            case send
            case earn
            case receive
            case shield
            case settings
            case cis2

            var iconName: String {
                switch self {
                case .send:
                    return "button_slider_send"
                case .earn:
                    return "button_slider_earn"
                case .receive:
                    return "button_slider_receive"
                case .shield:
                    return "button_slider_shield"
                case .settings:
                    return "button_slider_settings"
                case .cis2:
                    return "ccd_coins"
                }
            }
        }

        var isShielded: Bool
        var actionSend: () -> Void
        var actionReceive: () -> Void
        var actionEarn: () -> Void
        var actionShield: () -> Void
        var actionSettings: () -> Void

        @State var disabled: Bool = false
        var buttons: [SliderItem] {
            [
                .send,
                .earn,
                .receive,
                isShielded ? .shield : nil,
                .settings,
                .cis2,
            ]
            .compactMap { $0 }
        }

        var shouldHideArrows: Bool { buttons.count < 5 }

        var body: some View {
            HStack {
                Button(action: {}) {
                    Image("button_slider_back").padding()
                }
                .hidden(shouldHideArrows)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 24) {
                        VerticalLine()
                        ForEach(buttons) { item in
                            ActionButton(
                                imageName: item.iconName,
                                disabled: disabled,
                                action: {}
                            )
                            .frame(height: size)
                            VerticalLine()
                        }
                    }
                }
                Button(action: {}) {
                    Image("button_slider_forward").padding()
                }
                .hidden(shouldHideArrows)
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(Pallette.primary)
            .cornerRadius(5)
        }
    }

struct ActionButton: View {
    let imageName: String
    var disabled: Bool = false
    var action: () -> Void

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
            actionSend: {},
            actionReceive: {},
            actionEarn: {},
            actionShield: {},
            actionSettings: {}
        )
    }
}
