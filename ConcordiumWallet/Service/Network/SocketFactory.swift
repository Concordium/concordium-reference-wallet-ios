//
//  SocketFactory.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 06/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
import Starscream
import WalletConnectRelay

extension WebSocket: WebSocketConnecting { }

struct SocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        return WebSocket(url: url)
    }
}
