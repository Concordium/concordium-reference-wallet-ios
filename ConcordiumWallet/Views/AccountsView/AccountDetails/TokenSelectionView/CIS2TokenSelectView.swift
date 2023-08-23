//
//  TokenSelectionView.swift
//  ConcordiumWallet
//

import SDWebImageSwiftUI
import SwiftUI

struct CIS2TokenSelectView: View {
    @State var viewModel: [CIS2TokenSelectionRepresentable]
    @State private var tokenIndex: String = ""
    @State var selectedItems: Set<String> = []
    var popView: (() -> Void)?

    var body: some View {
        VStack {
            Text("Please select the tokens you want to add from the contract.")
                .multilineTextAlignment(.center)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                TextField("Search for token ID", text: $tokenIndex)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.numberPad)
                    .padding(8)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Pallette.primary, lineWidth: 1)
            )
            .padding([.top, .bottom], 4)
            VStack {
                ScrollView {
                    ForEach(viewModel, id: \.self) { model in
                        HStack {
                            WebImage(url: model.details.thumbnail?.url)
                                .resizable()
                                .placeholder {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.gray)
                                }
                                .indicator(.activity)
                                .transition(.fade(duration: 0.2))
                                .scaledToFit()
                                .frame(width: 45, height: 45, alignment: .center)
                            Text(model.details.name)
                            Spacer()
                            Button {
                                didSelect(token: model.tokenId)
                            } label: {
                                Image(systemName: selectedItems.contains { $0 == model.tokenId } ? "checkmark.square.fill" : "square")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Pallette.primary)
                            }
                        }
                        .padding([.top, .bottom], 8)
                        .padding([.leading, .trailing], 16)
                    }
                }
                Spacer()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Pallette.primary, lineWidth: 1)
            )
            Spacer()
            HStack(spacing: 16) {
                Button(action: { popView?() }) {
                    Text("Back")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Pallette.primary)
                .cornerRadius(10)
                Button(action: { }) {
                    Text("Accept")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Pallette.primary)
                .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func didSelect(token id: String) {
        if selectedItems.contains { $0 == id.tokenId } {
            selectedItems.remove(model.tokenId)
        } else {
            selectedItems.insert(model.tokenId)
        }
    }

    func addToStorage() {
        
    }
}
