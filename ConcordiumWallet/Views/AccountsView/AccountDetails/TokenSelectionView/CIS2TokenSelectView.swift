//
//  TokenSelectionView.swift
//  ConcordiumWallet
//

import Combine
import SwiftUI

struct CIS2TokenSelectView: View {
    @State private var tokenIndex: String = ""
    @State var selectedItems: Set<CIS2TokenSelectionRepresentable>
    
    @StateObject var viewModel: CIS2TokenSelectViewModel
    @StateObject var searchTokenViewModel: SearchTokenViewModel
    
    var popView: () -> Void
    var showDetails: (_ token: CIS2TokenSelectionRepresentable) -> Void
    var didUpdateTokens: () -> Void
    let service: CIS2ServiceProtocol
    
    private let accountAddress: String
    private let contractIndex: String

    init(
        tokens: [CIS2Token],
        accountAdress: String,
        contractIndex: String,
        popView: @escaping () -> Void,
        didUpdateTokens: @escaping () -> Void,
        showDetails: @escaping (_ token: CIS2TokenSelectionRepresentable) -> Void,
        service: CIS2ServiceProtocol
    ) {
        self.popView = popView
        self.didUpdateTokens = didUpdateTokens
        self.accountAddress = accountAdress
        self.contractIndex = contractIndex
        self.showDetails = showDetails
        self.service = service
        _selectedItems = State(initialValue: Set(service.observedTokens(for: accountAdress, filteredBy: contractIndex)))
        
        _viewModel = .init(wrappedValue: CIS2TokenSelectViewModel(allContractTokens: tokens, accountAdress: accountAdress, contractIndex: contractIndex, service: service))
        _searchTokenViewModel = .init(wrappedValue: SearchTokenViewModel(accountAdress: accountAdress, contractIndex: contractIndex, service: service))
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
                    .onChange(of: tokenIndex) { idx in
                        if idx.isEmpty {
                            searchTokenViewModel.state = .idle
                        }
                    }
                    .onSubmit {
                        searchTokenViewModel.runSearch(tokenIndex)
                    }
                    .textInputAutocapitalization(.never)
                    /// we should allow user to type in letters since `token_id` is represented in hex
                    .keyboardType(.default)
                    .padding(8)
                    .submitLabel(.search)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Pallette.primary, lineWidth: 1)
            )
            .padding(.vertical, 4)
            
            GeometryReader { proxy in
                ScrollView {
                    LazyVStack {
                        if tokenIndex.isEmpty {
                            AllTokensListView(proxy)
                        } else {
                            SearchTokensListView(proxy)
                        }
                    }
                    .transition(.opacity)
                }
            }
            .refreshable {
                if tokenIndex.isEmpty {
                    viewModel.loadInitial()
                }
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
        .padding()
    }
    
    func didSelect(item: CIS2TokenSelectionRepresentable) {
        if let index = selectedItems.firstIndex(where: { $0.tokenId == item.tokenId }) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.insert(item)
        }
    }
    
    func addToStorage() {
        if let _ = try? service.storeCIS2Tokens(Array(selectedItems), accountAddress: accountAddress, contractIndex: contractIndex) {
            didUpdateTokens()
        }
    }
    
    func AllTokensListView(_ proxy: GeometryProxy) -> some View {
        Group {
            if !viewModel.isLoading && viewModel.tokens.isEmpty && viewModel.currentPage != 1 {
                SearchTokenFullscreenText(text: "No tokens found.", proxy: proxy)
            } else {
                ForEach(viewModel.tokens, id: \.self) { model in
                    CIS2TokenView(model: model)
                        .onTapGesture { showDetails(model) }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
                LoadingStateView(proxy.size)
            }
        }
    }
    
    @ViewBuilder
    func SearchTokensListView(_ proxy: GeometryProxy) -> some View {
        switch searchTokenViewModel.state {
            case .idle:
                SearchTokenFullscreenText(text: "Enter token ID and tap Search", proxy: proxy)
            case .searching:
                ZStack {
                    ProgressView()
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            case .found(let tokens):
                if tokens.isEmpty {
                    SearchTokenFullscreenText(text: "No tokens matching given predicate.", proxy: proxy)
                } else {
                    ForEach(tokens, id: \.self) { model in
                        CIS2TokenView(model: model)
                            .onTapGesture { showDetails(model) }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                    }
                }
            case .error:
                SearchTokenFullscreenText(text: "No tokens matching given predicate.", proxy: proxy)
        }
    }
    
    func SearchTokenFullscreenText(text: String, proxy: GeometryProxy) -> some View {
        ZStack {
            Text(text)
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
    }
    
    func LoadingStateView(_ size: CGSize) -> some View {
        ZStack {
            switch(viewModel.isLoading, viewModel.hasMore) {
                case (false, true):
                    ProgressView()
                        .onAppear {
                            viewModel.loadMore()
                        }
                case (true, _):
                    ProgressView()
                default: EmptyView()
            }
        }
        .padding(16)
    }
    
    func CIS2TokenView(model: CIS2TokenSelectionRepresentable) -> some View {
        HStack {
            AsyncImage(
                url: model.thumbnail ?? model.display,
                scale: UIScreen.main.scale
            ) { phase in
                Group {
                    switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                    }
                }
                .frame(width: 45, height: 45)
            }
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
                Image(systemName: selectedItems.contains { $0.tokenId == model.tokenId } ? "checkmark.square.fill" : "square")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Pallette.primary)
            }
        }
    }
}
