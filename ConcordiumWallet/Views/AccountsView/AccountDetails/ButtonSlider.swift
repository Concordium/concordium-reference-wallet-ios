//
//  ButtonSlider.swift
//  ConcordiumWallet
//
//  Created by Lars Christensen on 23/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

private let size: CGFloat = 60.0

struct ButtonSlider: View {
    var isShielded: Bool

    var actionSend: () -> Void
    var actionReceive: () -> Void
    var actionEarn: () -> Void
    var actionShield: () -> Void
    var actionSettings: () -> Void
    
    @State var position: Int = 0
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: moveBack) {
                Image("button_slider_back")
            }
            Spacer()
            HStack(alignment: .center, spacing: 0) {
                VerticalLine()
                if position == 0 {
                    ActionButton(imageName: "button_slider_send", action: actionSend)
                    VerticalLine()
                }
                ActionButton(imageName: "button_slider_receive", action: actionReceive)
                VerticalLine()
                ActionButton(imageName: "button_slider_earn", action: actionEarn)
                VerticalLine()
                if isShielded {
                    ActionButton(imageName: "button_slider_shield", action: actionShield)
                    VerticalLine()
                    if position == 1 {
                        ActionButton(imageName: "button_slider_settings", action: actionSettings)
                        VerticalLine()
                    }
                } else {
                    ActionButton(imageName: "button_slider_settings", action: actionSettings)
                    VerticalLine()
                }
            }
            Spacer()
            Button(action: moveForward) {
                Image("button_slider_forward")
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: size)
        .background(Pallette.primary)
        .cornerRadius(5)
    }
    
    private func moveBack() {
        if position > 0 {
            position -= 1
        }
    }
    
    private func moveForward() {
        if isShielded {
            if position < 1 {
                position += 1
            }
        } else {
            if position < 0 {
                position += 1
            }
        }
    }
}

struct ActionButton: View {
    let imageName: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Image(imageName)
        }
        .frame(maxWidth: size, maxHeight: size)
        .background(Pallette.primary)
        .onTapGesture {
            self.action()
        }
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
            actionSend: {
            }, actionReceive: {
            }, actionEarn: {
            }, actionShield: {
            }, actionSettings: {
            })
    }
}
