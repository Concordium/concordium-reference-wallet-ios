//
//  TokenLookupView.swift
//  ConcordiumWallet
//

import BigInt
import Combine
import SwiftUI

enum TokenError: Error, Identifiable {
    var id: String { errorMessage }
    case inputError(msg: String)
    case networkError(err: Error)

    var errorMessage: String {
        switch self {
        case let .inputError(msg: msg):
            return msg
        case let .networkError(err: error):
            if let e = error as? NetworkError {
                return ErrorMapper.toViewError(error: e).errorDescription ?? e.localizedDescription
            } else {
                return error.localizedDescription
            }
        }
    }
}

struct TokenLookupView: View {
    var service: CIS2ServiceProtocol
    var displayContractTokens: ((_ metadata: [CIS2TokenSelectionRepresentable], _ contractIndex: String) -> Void)?
    private var account: AccountDataType
    private let tokenIndexPublisher = PassthroughSubject<String, Never>()
    private let searchButtonPublisher = PassthroughSubject<Void, Never>()

    @State private var contractIndex: String = ""
    @State private var tokens: [CIS2Token] = []
    @State private var error: TokenError? = nil
    @State private var isLoading = false

    var tokensPublisher: AnyPublisher<[CIS2Token], TokenError> {
        tokenIndexPublisher
            .setFailureType(to: TokenError.self)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .flatMapLatest { token -> AnyPublisher<String, TokenError> in
                if token.isNumeric {
                    return .just(token)
                } else {
                    return .fail(
                        TokenError.inputError(msg: "Input cannot contain characters other than digits.")
                    )
                }
            }
            .debounce(for: 1, scheduler: RunLoop.main)
            .flatMapLatest { token -> AnyPublisher<[CIS2Token], TokenError> in
                service.fetchTokens(contractIndex: token, contractSubindex: "0")
                    .map { $0.tokens }
                    .mapError { TokenError.networkError(err: $0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    var tokensMetadataPublisher: AnyPublisher<[CIS2TokenSelectionRepresentable], TokenError> {
        searchButtonPublisher
            .setFailureType(to: TokenError.self)
            .flatMapLatest { () -> AnyPublisher<(CIS2TokensMetadata, [CIS2TokenBalance]), TokenError> in
                Publishers.Zip(
                    service.fetchTokensMetadata(
                        contractIndex: contractIndex,
                        contractSubindex: "0",
                        tokenId: tokens.map { $0.token }.joined(separator: ",")
                    )
                    .mapError { TokenError.networkError(err: $0) }
                    .eraseToAnyPublisher(),
                    service.fetchTokensBalance(
                        contractIndex: contractIndex,
                        contractSubindex: "0",
                        accountAddress: account.address,
                        tokenId: tokens.map { $0.token }.joined(separator: ",")
                    )
                    .mapError { TokenError.networkError(err: $0) }
                    .eraseToAnyPublisher()
                )
                .eraseToAnyPublisher()
            }
            .flatMapLatest { (metadata: CIS2TokensMetadata, balance: [CIS2TokenBalance]) -> AnyPublisher<[CIS2TokenSelectionRepresentable], TokenError> in
                Publishers.MergeMany(
                    metadata.metadata.map { metadataItem in
                        service.fetchTokensMetadataDetails(url: metadataItem.metadataURL)
                            .tryMap { details in
                                guard let balance = BigInt(balance.first(where: { $0.tokenId == metadataItem.tokenId })?.balance ?? "") else {
                                    throw TokenError.inputError(msg: "Invalid balance")
                                }
                                return CIS2TokenSelectionRepresentable(
                                    contractName: metadata.contractName,
                                    tokenId: metadataItem.tokenId,
                                    balance: balance,
                                    contractIndex: contractIndex,
                                    name: details.name,
                                    symbol: details.symbol,
                                    decimals: details.decimals ?? 6,
                                    description: details.description,
                                    thumbnail: details.thumbnail?.url,
                                    unique: details.unique ?? false,
                                    accountAddress: account.address
                                )
                            }
                    }
                )
                .mapError { TokenError.networkError(err: $0) }
                .collect()
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    init(service: CIS2ServiceProtocol, account: AccountDataType) {
        self.service = service
        self.account = account
    }

    var body: some View {
        ZStack {
            VStack {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 62, height: 3)
                    .padding(4)
                Text("Enter a contract index to look for tokens.")
                TextField("Contract index", text: $contractIndex)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .onChange(of: contractIndex) { newValue in
                        isLoading = true
                        self.tokens.removeAll()
                        tokenIndexPublisher.send(newValue)
                    }
                    .padding()
                Spacer()
                Button(action: {
                    searchButtonPublisher.send(())
                }) {
                    Text("Look for tokens")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Pallette.whiteText)
                }
                .disabled(tokens.isEmpty || isLoading)
                .background(tokens.isEmpty || isLoading ? Pallette.inactiveButton : Pallette.primary)
                .cornerRadius(10)
            }
            if isLoading {
                ProgressView()
            }
        }
        .padding()
        .onReceive(
            tokensPublisher.asResult(),
            perform: { result in
                isLoading = false
                switch result {
                case let .success(tokens):
                    self.tokens = tokens
                case let .failure(error):
                    self.tokens.removeAll()
                    self.error = error
                }
            }
        )
        .onReceive(
            tokensMetadataPublisher.asResult(),
            perform: { result in
                isLoading = false
                switch result {
                case let .success(metadata):
                    displayContractTokens?(metadata, contractIndex)
                case let .failure(error):
                    self.error = error
                }
            }
        )
        .alert(item: $error) { error in
            Alert(title: Text("Error"), message: Text(error.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}
