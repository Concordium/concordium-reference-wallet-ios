//
//  WalletConnectSignMessageView.swift
//  ConcordiumWallet
//
//  Created by Michael Olesen on 06/07/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
import SwiftUI

struct WalletConnectSignMessageView: View {
    let dappName: String
    let accountName: String
    let message: SignableValueRepresentation
    
    var boxText: AttributedString {
        var d = AttributedString(dappName)
        var a = AttributedString(accountName)
        d.font = .body.bold()
        a.font = .body.bold()
        return "Application " + d + " connected to account " + a
    }
    
    var body: some View {
        VStack {
            HStack {
                Image("checkmark 1")
                    .padding()
                VStack(alignment: .leading) {
                    Text(boxText)
                }
                .padding([.top, .trailing, .bottom], 16)
                .foregroundColor(.white)
            }
            .background(.black)
            .cornerRadius(10)
            
            VStack {
                switch message {
                case .decoded(let value):
                    Text("Message").fontWeight(.bold)
                    Text(value)
                        .font(.custom("Courier", size: 13))
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(.gray, lineWidth: 1)
                        )
                        .background(.white)
                case .raw(let value):
                    Text("Decoding message to JSON failed.")
                        .foregroundColor(.red)
                    Text("Raw Message").fontWeight(.bold)
                    Text(value)
                        .font(.custom("Courier", size: 13))
                        .foregroundColor(.red)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(.gray, lineWidth: 1)
                        )
                        .background(.white)
                }
            }
        }
    }
}


struct WalletConnectSignMessageView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectSignMessageView(
            dappName: "My dApp",
            accountName: "My Account",
            message: .raw("xxx")
        )
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .previewDisplayName("Default preview")
    }
}
