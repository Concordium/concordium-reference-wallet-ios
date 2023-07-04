//
//  WalletConnectRequestScreen.swift
//  Mock
//
//  Created by Milan Sawicki on 13/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI
import Web3Wallet

struct EstimatedCost {
    let nrg: Int
    let ccd: GTU?
}

class TransferInfo: ObservableObject {
    @Published var estimatedCost: EstimatedCost? = nil
}

struct WalletConnectActionRequestView: View {
    let dappName: String
    let accountName: String
    let balanceAtDisposal: GTU
    
    let amount: GTU
    let contractAddress: ContractAddress
    let transactionType: String
    let receiveName: String
    let maxExecutionEnergy: Int
    let params: ContractUpdateParameterRepresentation?
    let request: Request
    @ObservedObject var info: TransferInfo
    
    var boxText: AttributedString {
        var d = AttributedString(dappName)
        var a = AttributedString(accountName)
        d.font = .body.bold()
        a.font = .body.bold()
        return "Application " + d + " connected to account " + a
    }
    
    var estimatedTransactionFeeText: AttributedString {
        if let cost = info.estimatedCost {
            if let ccd = cost.ccd {
                return AttributedString("Estimated transaction fee: \(ccd.displayValueWithGStroke())")
            }
            return "Cannot estimate transaction fee in CCD"
        }
        var p = AttributedString("Pending...")
        p.font = .body.italic()
        return "Estimated transaction fee: " + p
    }
    
    var maxEnergyAllowedText: AttributedString {
        if let cost = info.estimatedCost {
            return AttributedString("\(cost.nrg) NRG")
        }
        var p = AttributedString("Pending...")
        p.font = .body.italic()
        return p
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
            
            HStack {
                Text("Account Balance:")
                Text("\(balanceAtDisposal.displayValueWithGStroke())")
            }
            ScrollView{
                VStack {
                    Text("Transaction:  \(transactionType)")
                        .fontWeight(.bold)
                        .padding([.top], 8)
                    Divider()
                    buildTransactionItem(title: "Amount", value: Text(amount.displayValueWithGStroke()))
                    buildTransactionItem(title: "Contract index (subindex)", value: Text("\(contractAddress.index.string) (\(contractAddress.subindex.string))"))
                    buildTransactionItem(title: "Contract and function name", value: Text(receiveName))
                    buildTransactionItem(title: "Max energy allowed", value: Text(maxEnergyAllowedText))
                    if let params {
                        buildTransactionItem(
                            title: "Parameter",
                            value: VStack {
                                switch params {
                                case .decoded(let value):
                                    Text(value)
                                        .font(.custom("Courier", size: 13))
                                        .padding()
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 2)
                                                .stroke(.gray, lineWidth: 1)
                                        )
                                        .background(.white)
                                case .raw(let value):
                                    Text("Decoding message to JSON failed. Raw message:")
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
                        )
                    } else {
                        buildTransactionItem(title: "No parameter", value: EmptyView())
                    }
                    
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 1)
            )
            .padding()
            Text(estimatedTransactionFeeText)
        }
    }

    func buildTransactionItem(title: String, value: some View) -> some View {
        VStack {
            Text(title).fontWeight(.bold)
            value
        }.padding([.bottom], 4)
    }
}
