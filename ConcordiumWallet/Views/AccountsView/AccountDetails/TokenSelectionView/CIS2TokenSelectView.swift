//
//  TokenSelectionView.swift
//  ConcordiumWallet
//

import Combine
import SDWebImageSwiftUI
import SwiftUI

struct CIS2TokenSelectView: View {
    @State var viewModel: [CIS2TokenSelectionRepresentable]
    @State private var tokenIndex: String = ""
    @State var selectedItems: Set<String> = []
    var popView: (() -> Void)?
    var filterTextfieldPublisher = PassthroughSubject<String, Never>()

    var filteredTokens: [CIS2TokenSelectionRepresentable] {
        viewModel.filter { tokenIndex.isEmpty ? true : $0.tokenId.contains(tokenIndex) }
    }

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
                if filteredTokens.isEmpty {
                    HStack {
                        Text("No tokens matching given predicate.")
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        ForEach(filteredTokens, id: \.self) { model in
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
                                VStack(alignment: .leading) {
                                    Text(model.details.name)
                                    Text("Your balance: \(GTU(intValue: model.balance).displayValue())")
                                        .foregroundColor(Pallette.fadedText)
                                }
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
                Button(action: addToStorage) {
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
        if selectedItems.contains(where: { $0 == id }) {
            selectedItems.remove(id)
        } else {
            selectedItems.insert(id)
        }
    }

    func addToStorage() {
    }
}
