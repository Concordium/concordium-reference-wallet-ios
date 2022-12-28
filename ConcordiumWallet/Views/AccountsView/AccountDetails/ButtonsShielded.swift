//
//  ButtonsShielded.swift
//  ConcordiumWallet
//
//  Created by Lars Christensen on 27/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

private let size: CGFloat = 60.0

struct ButtonsShielded: View {
    var actionSendShielded: () -> Void
    var actionUnshield: () -> Void
    var actionReceive: () -> Void

    var body: some View {
        HStack {
            ShieldedActionButton(imageName: "button_slider_send_shielded", action: actionSendShielded)
            VerticalLine()
            ShieldedActionButton(imageName: "button_slider_unshield", action: actionUnshield)
            VerticalLine()
            ShieldedActionButton(imageName: "button_slider_receive", action: actionReceive)
        }
        .frame(maxWidth: .infinity, maxHeight: size)
        .background(Pallette.primary)
        .cornerRadius(5)
    }
}

struct ShieldedActionButton: View {
    let imageName: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Image(imageName)
        }
        .frame(maxWidth: .infinity, maxHeight: size)
        .background(Pallette.primary)
        .onTapGesture {
            self.action()
        }
    }
}

struct ButtonsShielded_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsShielded(
            actionSendShielded: {},
            actionUnshield: {},
            actionReceive: {})
    }
}
