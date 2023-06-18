//
//  WalletConnectRequestScreen.swift
//  Mock
//
//  Created by Milan Sawicki on 13/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI
import Web3Wallet
struct WalletConnectActionRequestView: View {
    var didAccept: (() -> Void)
    var didReject: (() -> Void)
    var request: Request
    var body: some View {
        VStack {
            Text("Transaction Approval")
                .bold()
                .font(.system(size: 20))
            
            Text("<dApp name> requests your signature on the following transaction: ")
                .padding()
            Text("Currently available amounts: ")
            Spacer()
            HStack(spacing: 16) {
                Button(action: {
                    didReject()
                }, label: {
                    Text("Reject")
                        .foregroundColor(Pallette.error)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(

                                    RoundedRectangle(

                                        cornerRadius: 10,
                                        style: .continuous
                                    )
                                    .stroke(Pallette.error, lineWidth: 2)

                                )
                })

                Button(action: {
                    didAccept()
                }, label: {
                    Text("Accept")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                })
                .background(Pallette.primary)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

//struct WalletConnectRequestScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        WalletConnectActionRequestView()
//    }
//}
