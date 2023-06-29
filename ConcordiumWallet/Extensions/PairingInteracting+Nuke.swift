//
//  PairingInteracting+Nuke.swift
//  ConcordiumWallet
//

import Web3Wallet

extension PairingInteracting {
    
    func nuke() {
        getPairings().forEach { pairing in
            Task {
                do {
                    try await disconnect(topic: pairing.topic)
                } catch let err {
                    print("ERROR: WalletConnect: Deinitializing WalletConnectCoordinator: Cannot disconnect pairing with topic '\(pairing.topic)': \(err)")
                }
            }
        }
    }
}
