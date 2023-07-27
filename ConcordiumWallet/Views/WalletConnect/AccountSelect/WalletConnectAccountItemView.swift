//
//  WalletConnectAccountItemView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 02/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

struct WalletConnectAccountItemView: View {
    var account: AccountDataType
    var onSelect: (() -> Void)
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                Text(account.name ?? " - ")
                    .fontWeight(.semibold)
                Text(account.identity?.nickname ?? " - ")
                    .fontWeight(.light)
                Spacer()
            }
            HStack(spacing: 8) {
                Text("walletconnect.select.account.total".localized)
                Spacer()
                Text(GTU(intValue: account.totalForecastBalance).displayValueWithGStroke())
            }
            HStack(spacing: 8) {
                Text("walletconnect.select.account.at.disposal")
                Spacer()
                Text(GTU(intValue: account.forecastAtDisposalBalance).displayValueWithGStroke())
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Pallette.fadedText, lineWidth: 1)
        )
    }
}

