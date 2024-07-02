//
//  UnshiedSunsetView.swift
//  ConcordiumWallet
//
//  Created by Max on 12.06.2024.
//  Copyright © 2024 concordium. All rights reserved.
//

import SwiftUI

struct UnshiedSunsetView: View {
    @SwiftUI.Environment(\.openURL) var openURL
    @SwiftUI.Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Image("ico_unshield")
                    Text("Transaction Shielding\nis going away")
                        .font(Font.system(size: 30, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.27, green: 0.53, blue: 0.67))
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                
                VStack(spacing: 24) {
                    Text("We recommend that you unshield any Shielded balance today. To do so move your account to the new CryptoX Concordium wallet.")
                        .font(Font.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    Text(
                        """
                        1. Install the CryptoX Concordium wallet
                        2. Copy your seed phrase
                        3. Insert your seed phrase in the CryptoX wallet
                        """
                    )
                    .font(Font.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    Text("When that’s done, you will be able to unshield your Shielded balance through the CryptoX wallet, and you can safely delete this one.")
                        .font(Font.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    Text("Don’t worry, your wallet will stay here on your device until you uninstall it, but we highly encourage you to migrate today.")
                        .font(Font.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 24) {
                    Button {
                        if let url  = URL(string: "itms-apps://itunes.apple.com/app/id1593386457"), UIApplication.shared.canOpenURL(url) {
                            openURL(url)
                        }
                    } label: {
                        Text("Install CryptoX Concordium wallet")
                            .font(Font.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .contentShape(.rect)
                    }
                    .foregroundColor(.clear)
                    .background(Color(red: 0.27, green: 0.53, blue: 0.67))
                    .cornerRadius(8)

                    Button {
                        dismiss()
                    } label: {
                        Text("Continue with the old wallet")
                            .font(Font.system(size: 14, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 32)
            }
        }
    }
}

#Preview {
    UnshiedSunsetView()
}
