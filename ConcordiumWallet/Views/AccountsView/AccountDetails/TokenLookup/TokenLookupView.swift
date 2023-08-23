//
//  TokenLookupView.swift
//  ConcordiumWallet
//

import Combine
import SwiftUI

struct TokenLookupView: View {
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

    var service: CIS2ServiceProtocol
    var displayContractTokens: ((_ metadata: [CIS2TokenSelectionRepresentable]) -> Void)?
    private var account: AccountDataType
    private let tokenIndexPublisher = PassthroughSubject<String, Never>()
    private let searchButtonPublisher = PassthroughSubject<Void, Never>()

    @State private var tokenIndex: String = ""
    @State private var tokens: [CIS2Token] = []
    @State private var error: TokenError? = nil
    @State private var isLoading = false
    init(service: CIS2ServiceProtocol, account: AccountDataType) {
        self.service = service
        self.account = account
    }

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
            .debounce(for: 0.5, scheduler: RunLoop.main)
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
            .flatMapLatest { () -> AnyPublisher<([CIS2TokensMetadataItem], [CIS2TokenBalance]), TokenError> in
                Publishers.Zip(
                    service.fetchTokensMetadata(
                        contractIndex: tokenIndex,
                        contractSubindex: "0",
                        tokenId: tokens.map { $0.token }.joined(separator: ",")
                    )
                    .mapError { TokenError.networkError(err: $0) }
                    .map { $0.metadata }
                    .eraseToAnyPublisher(),
                    service.fetchTokensBalance(
                        contractIndex: tokenIndex,
                        contractSubindex: "0",
                        accountAddress: account.address,
                        tokenId: tokens.map { $0.token }.joined(separator: ",")
                    )
                    .mapError { TokenError.networkError(err: $0) }
                    .eraseToAnyPublisher()
                )
                .eraseToAnyPublisher()
            }
            .flatMapLatest { (items: [CIS2TokensMetadataItem], balance: [CIS2TokenBalance]) -> AnyPublisher<[CIS2TokenSelectionRepresentable], TokenError> in
                Publishers.MergeMany(
                    items.map { metadata in
                        service.fetchTokensMetadataURL(url: metadata.metadataURL)
                            .mapError { TokenError.networkError(err: $0) }
                            .map {
                                CIS2TokenSelectionRepresentable(
                                    tokenId: metadata.tokenId,
                                    balance: Int(balance.first(where: { $0.tokenId == metadata.tokenId })?.balance ?? "") ?? 0,
                                    details: $0
                                )
                            }
                    }
                )
                .collect()
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    var body: some View {
        ZStack {
            VStack {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 62, height: 3)
                    .padding(4)
                Text("Enter a contract index to look for tokens.")
                TextField("Contract index", text: $tokenIndex)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .onChange(of: tokenIndex) { newValue in
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
                    displayContractTokens?(metadata)
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
