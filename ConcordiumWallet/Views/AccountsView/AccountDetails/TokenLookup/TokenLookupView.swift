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
    var account: AccountDataType

    var displayContractTokens: ((_ tokens: [CIS2Token], _ contractIndex: String) -> Void)?
    
    private let tokenIndexPublisher = PassthroughSubject<String, Never>()

    @State private var contractIndex: String = ""
    @State private var tokens: [CIS2Token] = []
    @State private var error: TokenError? = nil
    @State private var isLoading = false
    
    @FocusState private var isIndexFieldFocused: Bool

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

    var body: some View {
        ZStack {
            VStack {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 62, height: 3)
                    .padding(4)
                Text("Enter a contract index to look for tokens.")
                TextField("Contract index", text: $contractIndex)
                    .focused($isIndexFieldFocused)
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
                    displayContractTokens?(tokens, contractIndex)
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
        .alert(item: $error) { error in
            Alert(title: Text("Error"), message: Text(error.errorMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear(perform: {
            isIndexFieldFocused = true
        })
    }
}
