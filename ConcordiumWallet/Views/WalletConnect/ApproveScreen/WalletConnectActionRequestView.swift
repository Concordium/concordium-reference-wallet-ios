//
//  WalletConnectRequestScreen.swift
//  Mock
//
//  Created by Milan Sawicki on 13/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI
import Web3Wallet
import Combine

struct EstimatedCost {
    let nrg: Int
    let ccd: GTU?
}

class TransferInfo: ObservableObject {
    @Published var estimatedCost: EstimatedCost? = nil
}

struct WalletConnectActionRequestView: View {
    let service: AccountsServiceProtocol
    let dappName: String
    var accountName: String {
        account.name ?? ""
    }
    private var accountBalancePublisher: AnyPublisher<String, NetworkError> {
        service.recalculateAccountBalance(account: account, balanceType: .balance)
            .mapError { return $0 as? NetworkError ?? .communicationError(error: $0) }
            .map { GTU(intValue: $0.forecastAtDisposalBalance).displayValueWithGStroke() }
            .eraseToAnyPublisher()
    }
    @State var error: NetworkError?
    @State var balance: String = ""
    let account: AccountDataType
    let amount: GTU
    let contractAddress: ContractAddress
    let transactionType: String
    let receiveName: String
    let maxExecutionEnergy: Int
    let params: SignableValueRepresentation?
    let request: Request
    @ObservedObject var info: TransferInfo
    
    var boxText: AttributedString {
        var d = AttributedString(dappName)
        var a = AttributedString(accountName)
        d.font = .body.bold()
        a.font = .body.bold()
        return "Application " + d + " connected to account " + a
    }
    
    var maxEnergyAllowedText: AttributedString {
        if let cost = info.estimatedCost {
            return AttributedString("\(cost.nrg) NRG")
        }
        var p = AttributedString("Pending...")
        p.font = .body.italic()
        return p
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

    let isAccountBalanceSufficient: Bool
    
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
                    .foregroundColor(isAccountBalanceSufficient ? .black : .red)
                Text(balance)
                    .foregroundColor(isAccountBalanceSufficient ? .black : .red)
            }
            ScrollView {
                VStack {
                    Text("Transaction: \(transactionType)")
                        .fontWeight(.bold)
                        .padding([.top], 8)
                    Divider()
                    buildTransactionItem(title: "Amount", value: Text(amount.displayValueWithGStroke()))
                        .foregroundColor(isAccountBalanceSufficient ? .black : .red)
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
                    if !isAccountBalanceSufficient {
                        Text("Insufficient funds")
                            .foregroundColor(.red)
                    }
                    
                }
            }
            .alert(item: $error) { error in
                Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
            }
            .onReceive(accountBalancePublisher.asResult(), perform: { result in
                switch result {
                case .success(let balance):
                    self.balance = balance
                case .failure(let error):
                    self.error = error
                }
            })
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 1)
            )
            .padding()
            Text(estimatedTransactionFeeText)
        }
        .navigationBarBackButtonHidden()
    }

    func buildTransactionItem(title: String, value: some View) -> some View {
        VStack {
            Text(title).fontWeight(.bold)
            value
        }.padding([.bottom], 4)
    }
}
