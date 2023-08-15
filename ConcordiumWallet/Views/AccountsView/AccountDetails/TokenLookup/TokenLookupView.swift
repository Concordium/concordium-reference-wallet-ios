//
//  TokenLookupView.swift
//  ConcordiumWallet
//

import Combine
import SwiftUI

// MARK: - CIS2Tokens

struct CIS2Tokens: Codable {
    let count: Int
    let limit: Int
    let tokens: [CIS2Token]
}

// MARK: - Token

struct CIS2Token: Codable {
    let id: Int
    let token, totalSupply: String
}

struct TokenLookupView: View {
    enum TokenError: Error {
        case inputError(msg: String)
        case networkError(err: Error)
    }
    
    var service: CIS2ServiceProtocol
    var didTapSearch: ((_ tokens: [CIS2Token]) -> Void)?
    private let tokenIndexPublisher = PassthroughSubject<String, Never>()
    private var cancellables: [AnyCancellable] = []
    @State private var tokenIndex: String = ""
    @State private var tokens: [CIS2Token] = []
    @State private var error: Error?

    init(service: CIS2ServiceProtocol) {
        self.service = service
    }

    var tokensPublisher: AnyPublisher<[CIS2Token], TokenError> {
        tokenIndexPublisher
            .filter { !$0.isEmpty }
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .map { token in
//                if token.isEmpty {
//                    return AnyPublisher<[CIS2Token], TokenError>.fail(TokenError.inputError(msg: "input is empty"))
//                }
                return service.fetchTokens(contractIndex: token, contractSubindex: "0")
                    .map { $0.tokens }
                    .mapError { TokenError.networkError(err: $0) }
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
                .textFieldStyle(.roundedBorder)
                .onChange(of: tokenIndex) { newValue in
                    tokenIndexPublisher.send(newValue)
                }
                .padding()
            Spacer()
            Button(action: { didTapSearch?(tokens) }) {
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
            tokensPublisher.catch({ err -> Empty in
                self.error = err
                return Empty()
            }),
            perform: { self.tokens = $0 }
        )
    }
}
