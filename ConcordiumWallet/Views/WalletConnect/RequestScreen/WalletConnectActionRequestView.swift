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
    let dappName: String
    let amount: GTU
    let balanceAtDisposal: GTU
    let contractAddress: ContractAddress
    let transactionType: String
    let params: String
    let didAccept: (() -> Void)
    let didReject: (() -> Void)
    let request: Request
    var body: some View {
        VStack {
            Text("Transaction Approval")
                .bold()
                .font(.system(size: 20))
            
            Text("\(dappName) requests your signature on the following transaction: ")
                .padding()
            HStack {
                Text("Balance (at disposal): ")
                Text("\(balanceAtDisposal.displayValueWithGStroke())")
            }
            Text("Currently available amounts: ")
        
                VStack {
                    Text("Transaction: \(transactionType)")
                        .fontWeight(.bold)
                        .padding() // TODO: add transaction type
                    Divider()
                    buildTransactionItem(title: "Sender account", value: "Main")
                    buildTransactionItem(title: "Amount", value: amount.displayValueWithGStroke())
                    buildTransactionItem(title: "Contract index", value: "index: \(contractAddress.index) subindex: \(contractAddress.subindex)")
                    VStack {
                        Text(params).font(.custom("AmericanTypewriter", size: 13)).padding()
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 1)
                )
                .padding()
            
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
    
    func buildTransactionItem(title: String, value: String) -> some View {
        VStack {
            Text(title).fontWeight(.bold)
            Text(value)
        }.padding()
    }
}
