//
//  SendFundTokenSelection.swift
//  Mock
//
//  Created by Milan Sawicki on 01/09/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
import SDWebImageSwiftUI
import SwiftUI

struct SendFundTokenSelection: View {
    let service: CIS2ServiceProtocol
    let account: AccountDataType
    let didSelectToken: ((CIS2TokenSelectionRepresentable?) -> ())
    @State var tokens: [CIS2TokenSelectionRepresentable] = []

    var body: some View {
        ScrollView {
            Button {
                didSelectToken(nil)
            } label: {
                HStack {
                    Image("concordium_logo")
                        .resizable()
                        .frame(width: 48, height: 48, alignment: .center)
                    VStack(alignment: .leading) {
                        Text(GTU(intValue: account.forecastAtDisposalBalance).displayValue())
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.black)
                    }
                    .padding()
                    Spacer()
                }
            }
            ForEach(tokens, id: \.self) { token in
                Button {
                    didSelectToken(token)
                } label: {
                    HStack {
                        WebImage(url: token.thumbnail) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "photo")
                        }
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(width: 48, height: 48, alignment: .center)
                        VStack(alignment: .leading) {
                            Text(token.name)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.black)
                            Text(token.balanceDisplayValue)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .onReceive(service.observedTokensPublisher(for: account.address).asResult()) { tokensResult in
            switch tokensResult {
            case let .success(items):
                tokens = items.filter { $0.balance > 0 && $0.accountAddress == account.address }
            case let .failure(error):
                // set error
                print(error)
            }
        }
    }
}
