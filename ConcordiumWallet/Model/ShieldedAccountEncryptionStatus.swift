//
//  ShieldedAccountEncryptionStatus.swift
//  ConcordiumWallet
//
//  Concordium on 03/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

enum ShieldedAccountEncryptionStatus: String, Codable {
    case decrypted // no lock
    case partiallyDecrypted // sum + lock
    case encrypted // just lock
}
