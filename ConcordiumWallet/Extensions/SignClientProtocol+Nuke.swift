//
//  SignClientProtocol.swift
//  ConcordiumWallet
//

import Web3Wallet

extension SignClientProtocol {
    func nuke() {
        getSessions().forEach { session in
            Task {
                do {
                    try await disconnect(topic: session.topic)
                } catch let err {
                    print("ERROR: WalletConnect: Deinitializing WalletConnectCoordinator: Cannot disconnect session with topic '\(session.topic)': \(err)")
                }
            }
        }
    }
}
