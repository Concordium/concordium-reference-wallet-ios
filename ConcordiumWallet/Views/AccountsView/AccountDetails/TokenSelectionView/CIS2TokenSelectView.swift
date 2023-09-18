//
//  TokenSelectionView.swift
//  ConcordiumWallet
//

import Combine
import SDWebImageSwiftUI
import SwiftUI

struct CIS2TokenSelectView: View {
    @State private var tokenIndex: String = ""
    @State var selectedItems: Set<CIS2TokenSelectionRepresentable> = []
    var popView: () -> Void
    var showDetails: (_ token: CIS2TokenSelectionRepresentable) -> Void
    var didUpdateTokens: () -> Void
    let service: CIS2ServiceProtocol
    var viewModel: [CIS2TokenSelectionRepresentable]
    private let accountAddress: String
    private let contractIndex: String
    private var filteredTokens: [CIS2TokenSelectionRepresentable] {
        viewModel.filter { tokenIndex.isEmpty ? true : $0.tokenId.contains(tokenIndex) }
    }

    init(
        viewModel: [CIS2TokenSelectionRepresentable],
        accountAdress: String,
        contractIndex: String,
        popView: @escaping () -> Void,
        didUpdateTokens: @escaping () -> Void,
        showDetails: @escaping (_ token: CIS2TokenSelectionRepresentable) -> Void,
        service: CIS2ServiceProtocol
    ) {
        self.viewModel = viewModel
        self.popView = popView
        self.didUpdateTokens = didUpdateTokens
        self.accountAddress = accountAdress
        self.contractIndex = contractIndex
        self.showDetails = showDetails
        self.service = service
        _selectedItems = State(initialValue: Set(service.getUserStoredCIS2Tokens(for: accountAdress, in: contractIndex)))
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
                                WebImage(url: model.thumbnail)
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
                                    Text(model.name)
                                    Text("Your balance: \(model.balanceDisplayValue)")
                                        .foregroundColor(Pallette.fadedText)
                                }
                                Spacer()
                                Button {
                                    didSelect(item: model)
                                } label: {
                                    Image(systemName: selectedItems.contains { $0 == model } ? "checkmark.square.fill" : "square")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(Pallette.primary)
                                }
                            }.onTapGesture { showDetails(model) }
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
                Button(action: popView) {
                    Text("Back")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Pallette.primary)
                .cornerRadius(10)
                Button(action: addToStorage) {
                    Text("Add tokens")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Pallette.primary)
                .cornerRadius(10)
            }
        }
        .onAppear()
        .padding()
    }

    func didSelect(item: CIS2TokenSelectionRepresentable) {
        if selectedItems.contains(where: { $0 == item }) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }

    func addToStorage() {
        let updated = viewModel.filter { selectedItems.contains($0) }
        if let _ = try? service.storeCIS2Tokens(updated, accountAddress: accountAddress, contractIndex: contractIndex) {
            didUpdateTokens()
        }
    }
}
