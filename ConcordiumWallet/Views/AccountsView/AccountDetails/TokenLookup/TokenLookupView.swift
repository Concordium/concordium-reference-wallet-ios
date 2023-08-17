//
//  TokenLookupView.swift
//  ConcordiumWallet
//

import Combine
import SwiftUI

// MARK: - CIS2TokenMetadata

struct CIS2TokenDetails: Codable, Hashable {
    let name: String
    let symbol: String?
    let decimals: Int
    let description: String
    let thumbnail, display: Display?
    let unique: Bool
}

// MARK: - Display

struct Display: Codable, Hashable {
    let url: String
}

// MARK: - CIS2Tokens

// TODO: move to separate files!
struct CIS2Tokens: Codable {
    let count: Int
    let limit: Int
    let tokens: [CIS2Token]
}

// MARK: - Token

// TODO: move to separate files!
struct CIS2Token: Codable {
    let id: Int
    let token, totalSupply: String
}

// TODO: move to separate files!
struct CIS2TokensMetadata: Codable {
    var contractName: String
    var metadata: [CIS2TokensMetadataItem]
}

// TODO: move to separate files!
struct CIS2TokensMetadataItem: Codable {
    var metadataChecksum: String?
    var metadataURL: String
    var tokenId: String
}

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
    var displayContractTokens: ((_ metadata: [CIS2TokenDetails]) -> Void)?
    private let tokenIndexPublisher = PassthroughSubject<String, Never>()
    private let searchButtonPublisher = PassthroughSubject<Void, Never>()
    @State private var tokenIndex: String = ""
    @State private var tokens: [CIS2Token] = []
    @State private var error: TokenError? = nil

    init(service: CIS2ServiceProtocol) {
        self.service = service
    }

    var tokensPublisher: AnyPublisher<[CIS2Token], TokenError> {
        tokenIndexPublisher
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { token in
                if !token.isNumeric {
                    return AnyPublisher<[CIS2Token], TokenError>.fail(
                        TokenError.inputError(msg: "Input cannot contain characters other than digits.")
                    )
                }
                return service.fetchTokens(contractIndex: token, contractSubindex: "0")
                    .map { $0.tokens }
                    .mapError { TokenError.networkError(err: $0) }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    var tokensMetadataPublisher: AnyPublisher<[CIS2TokenDetails], TokenError> {
        searchButtonPublisher
            .map {
                service.fetchTokensMetadata(contractIndex: tokenIndex, contractSubindex: "0", tokenId: tokens.first?.token ?? "")
                .mapError { TokenError.networkError(err: $0) }
                .map {
                    $0.metadata.publisher
                        .map {
                            service.fetchTokensMetadataURL(url: $0.metadataURL)
                                .mapError { TokenError.networkError(err: $0) }
                                .eraseToAnyPublisher()
                        }
                        .switchToLatest()
                        .collect()
                        .eraseToAnyPublisher()
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
    var body: some View {
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
            .disabled(tokens.isEmpty)
            .background(tokens.isEmpty ? Pallette.inactiveButton : Pallette.primary)
            .cornerRadius(10)
        }
        .padding()
        .onReceive(
            tokensPublisher.asResult(),
            perform: { result in
                switch result {
                case let .success(tokens):
                    self.tokens = tokens
                case let .failure(error):
                    self.tokens.removeAll()
                    self.error = error
                }
            }
        )
        .onReceive(tokensMetadataPublisher.asResult(), perform: { result in
            switch result {
            case let .success(metadata):
                print("CIS2 -> \(metadata)")
                displayContractTokens?(metadata)
            case let .failure(error):
                print("CIS2 -> \(error)")
                self.error = error
            }
        })
        .alert(item: $error) { error in
            Alert(title: Text("Error"), message: Text(error.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}
