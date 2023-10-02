//
//  TokenDetailsView.swift
//  Mock
//
//  Created by Milan Sawicki on 31/08/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SDWebImageSwiftUI
import SwiftUI

struct TokenDetailsView: View {
    /// Provides context determining mode for the view.
    enum Context {
        /// Used when token for which details are shown is cached in database.
        case database
        /// Used when to display token details before adding to database.
        case preview
    }

    var token: CIS2TokenSelectionRepresentable
    var service: CIS2ServiceProtocol
    var popView: () -> Void
    var showAddress: () -> Void
    var sendFunds: () -> Void
    var context: Context
    @State private var isAlertShown = false
    @State private var isMetadataShown = false
    @State var isOwned = false
    @State private var error: TokenError? = nil

    var body: some View {
        VStack {
            if context == .database {
                balanceSection
                buttonsSection
            }
            tokenInfoSection
            Spacer()
            switch context {
            case .database:
                hideTokenButton
            case .preview:
                backToListButton
            }
        }
        .navigationTitle(token.name)
        .padding()
    }

    var balanceSection: some View {
        HStack {
            Text("\(token.balanceDisplayValue)")
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
//            Button {
//                sendFunds()
//            } label: {
//                Image(systemName: "paperplane.fill")
//                    .resizable()
//                    .frame(width: 32.0, height: 32.0)
//                    .foregroundColor(.white)
//                    .opacity(token.balance > 0 ? 1.0 : 0.5)
//            }
//            .disabled(token.balance == 0)
//            Spacer()
//            Divider()
//            Spacer()

            Button {
                showAddress()
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
                HStack(alignment: .center) {
                    WebImage(url: token.thumbnail)
                        .resizable()
                        .placeholder(Image(systemName: "photo"))
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(width: 300, height: 300, alignment: .center)
                }
                .frame(maxWidth: .infinity)
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
                    Text("Token ID")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(token.tokenId)
                        .font(.body)
                }
                Group {
                    Text("Ownership")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(isOwned ? "Owned" : "Not owned")
                        .font(.body)
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

                Button {
                    isMetadataShown = true
                } label: {
                    Text("Show raw metadata")
                }
            }
            .padding()
        }
        .alert(item: $error) { error in
            Alert(title: Text("Error"), message: Text(error.errorMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $isMetadataShown) {}
        .onReceive(service.observedTokensPublisher(for: token.accountAddress, filteredBy: token.tokenId).asResult()) { result in
            switch result {
            case .success(let items):
                isOwned = items.contains { $0.tokenId == token.tokenId }
            case .failure(let error):
                self.error = TokenError.networkError(err: error)
            }
        }
        
    }

    var hideTokenButton: some View {
        Button {
            isAlertShown = true
        } label: {
            Text("Don't show token in wallet")
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(Pallette.whiteText)
                .background(Pallette.error)
                .cornerRadius(10)
        }
        .actionSheet(isPresented: $isAlertShown) {
            ActionSheet(
                title: Text("Remove Token"),
                message: Text("Do you want to remove the token from local storage?"),
                buttons: [
                    .destructive(Text("Yes"), action: {
                        if let _ = try? service.deleteTokenFromCache(token) {
                            popView()
                        }
                    }),
                    .cancel(Text("No")),
                ]
            )
        }
    }

    var backToListButton: some View {
        Button {
            popView()
        } label: {
            Text("Back to list")
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(Pallette.primary)
                .cornerRadius(10)
        }
    }
}
