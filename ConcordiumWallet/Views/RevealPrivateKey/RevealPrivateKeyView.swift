//
//  RevealPrivateKeyView.swift
//  ConcordiumWallet
//
//  Created by Max on 11.09.2024.
//  Copyright © 2024 concordium. All rights reserved.
//

import SwiftUI

final class RevealPrivateKeyViewModel: ObservableObject {
    typealias DependencyProvider = MoreFlowCoordinatorDependencyProvider & IdentitiesFlowCoordinatorDependencyProvider
    
    @Published var privateKey: String = ""
    
    private let dependencyProvider: DependencyProvider
    private let passwordDelegate: RequestPasswordDelegate
    
    init(dependencyProvider: DependencyProvider, passwordDelegate: RequestPasswordDelegate = SwiftUIRequestPasswordDelegate()) {
        self.dependencyProvider = dependencyProvider
        self.passwordDelegate = passwordDelegate
    }
    
    func getPrivateKey() async {
        do {
            let pwHash = try await passwordDelegate.requestUserPassword(keychain: dependencyProvider.keychainWrapper())
            let seedValue = try dependencyProvider.keychainWrapper().getValue(for: "RecoveryPhraseSeed", securedByPassword: pwHash).get()
            await MainActor.run {
                withAnimation {
                    self.privateKey = seedValue
                }
            }
        } catch {
            debugPrint(error)
        }
    }
}

struct RevealPrivateKeyView: View {
    @StateObject var viewModel: RevealPrivateKeyViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                Divider()
                VStack(spacing: 16) {
                    Text("Your wallet private key is the access key to all the funds in your wallet. Copy it and keep it safe. To avoid mistakes, do not write it down manually.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.black)
                    
                    
                    VStack {
                        HStack(alignment: .center, spacing: 8) {
                            Text(viewModel.privateKey)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(12)
                        }
                        .frame(minHeight: 88)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.78, green: 0.78, blue: 0.78), lineWidth: 1)
                            
                        )
                        .padding(16)
                    }
                    .frame(minHeight: 120)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .inset(by: 0.5)
                            .stroke(viewModel.privateKey.isEmpty
                                    ? .black.opacity(0.05)
                                    : Color(red: 0.27, green: 0.52, blue: 0.67),
                                    lineWidth: 1
                                   )
                    )
                    .overlay {
                        if !viewModel.privateKey.isEmpty {
                            EmptyView()
                        } else {
                            ZStack {
                                Image("icon_lock_pk")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 120)
                            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.5)
                                    .stroke(.black.opacity(0.05), lineWidth: 1)
                            )
                        }
                    }
                    .animation(.bouncy, value: viewModel.privateKey)
                    .onTapGesture {
                        handleTap()
                    }
                    
                    Button(action: {
                        handleTap()
                    }, label: {
                        Label(
                            viewModel.privateKey.isEmpty
                            ? "Show the wallet private key"
                            : "Copy to clipboard",
                            image: viewModel.privateKey.isEmpty ? "ico_eye" : "ico_copy"
                        )
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.black)
                        .transition(AnyTransition.opacity.animation(.bouncy))
                    })
                    .tint(.black)
                    
                    Spacer()
                }
                .padding(18)
            }
            .navigationTitle("Wallet private key")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func handleTap() {
        HapticFeedbackHelper.generate(feedback: .light)

        if viewModel.privateKey.isEmpty {
            Task {
                await viewModel.getPrivateKey()
            }
        } else {
            UIPasteboard.general.string = viewModel.privateKey
        }
    }
}
