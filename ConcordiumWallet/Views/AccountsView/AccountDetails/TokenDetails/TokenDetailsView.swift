//
//  TokenDetailsView.swift
//  Mock
//
//  Created by Milan Sawicki on 31/08/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

struct TokenDetailsView: View {
    var token: CIS2TokenSelectionRepresentable
    var service: CIS2ServiceProtocol
    var popView: () -> Void
    @State private var isAlertShown = false

    var body: some View {
        VStack {
            balanceSection
            buttonsSection
            tokenInfoSection
            Spacer()
            hideTokenButton
        }

        .navigationTitle(token.name)
        .padding()
    }

    var balanceSection: some View {
        HStack {
            Text("\(token.displayValueBalance)")
                .foregroundColor(Pallette.primary)
                .font(.largeTitle)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(.black)
        .cornerRadius(10)
    }

    var buttonsSection: some View {
        HStack(alignment: .center) {
            Spacer()
            Button {
            } label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
                    .foregroundColor(.white)
            }
            Spacer()
            Divider()
            Spacer()

            Button {
            } label: {
                Image(systemName: "qrcode")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 32.0, height: 32.0)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 16)
        .padding(32)
        .background(Pallette.primary)
        .cornerRadius(10)
    }

    var tokenInfoSection: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    Text("About token")
                        .foregroundColor(Pallette.primary)
                        .font(.subheadline)
                    Text("\(token.name)")
                        .font(.title2)
                    Divider()
                }
                Group {
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(token.description)
                        .font(.body)
                    Divider()
                }
                Group {
                    Text("Contract index, subindex")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(token.contractIndex), 0")
                        .font(.body)
                }
                Group {
                    Text("Token")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(token.symbol ?? " - ")
                        .font(.body)
                }
                Group {
                    Text("Decimals")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(token.decimals)").font(.body)
                }
            }
            .padding()
        }
    }

    var hideTokenButton: some View {
        Button {
            if let _ = try? service.deleteTokenFromCache(token) {
                popView()
            }
        } label: {
            Text("Don't show token in wallet")
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(Pallette.whiteText)
                .background(Pallette.error)
                .cornerRadius(10)
        }.alert(isPresented: $isAlertShown) {
            Alert(title: Text("Are you sure you want to delete the token?"), message: Text("Great choice!"), dismissButton: .cancel())
        }
    }
}
