//
// Created by Johan Rugager Vase on 19/02/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

struct ApiConstants {

#if DEBUG
    //UserDefaults loads from launch arguments: https://www.swiftbysundell.com/articles/launch-arguments-in-swift/
    static let overriddenServerUrl = UserDefaults.standard.string(forKey: "server")
    static let overriddenProxyUrl = UserDefaults.standard.string(forKey: "proxy")
#else
    static let overriddenServerUrl: String? = nil
    static let overriddenProxyUrl: String? = nil
#endif
#if TESTNET
    static let serverUrl = URL(string: overriddenServerUrl ?? "https://wallet-server.testnet.concordium.com/v0")!
    static let proxyUrl = URL(string: overriddenProxyUrl ?? "https://wallet-proxy.testnet.concordium.com/v0")!
#elseif MAINNET
    static let serverUrl = URL(string: overriddenServerUrl ?? "https://wallet-server.eu.staging.concordium.com/v0")!
    static let proxyUrl = URL(string: overriddenProxyUrl ?? "https://wallet-proxy.eu.staging.concordium.com/v0")!
#else //Staging
    static let serverUrl = URL(string: overriddenServerUrl ?? "https://wallet-server.eu.staging.concordium.com/v0")!
    static let proxyUrl = URL(string: overriddenProxyUrl ?? "https://wallet-proxy.eu.staging.concordium.com/v0")!
#endif

    #if TESTNET
    static let scheme = "concordiumwallettest"
    #elseif MAINNET
    static let scheme = "concordiumwallet"
    #else //Staging
    static let scheme = "concordiumwalletstaging"
    #endif
    static let notabeneCallback = "\(scheme)://identity-issuer/callback"

    static let ipInfo = proxyUrl.appendingPathComponent("/ip_info")
    static let global = proxyUrl.appendingPathComponent("/global")
    static let submitCredential = proxyUrl.appendingPathComponent("/submitCredential")
    static let submissionStatus = proxyUrl.appendingPathComponent("/submissionStatus")
    static let accNonce = proxyUrl.appendingPathComponent("/accNonce")
    static let accEncryptionKey = proxyUrl.appendingPathComponent("/accEncryptionKey")
    static let submitTransfer = proxyUrl.appendingPathComponent("/submitTransfer")
    static let transferCost = proxyUrl.appendingPathComponent("/transactionCost")
    static let accountBalance = proxyUrl.appendingPathComponent("/accBalance")
    static let accountTransactions = proxyUrl.appendingPathComponent("/accTransactions")
    static let gtuDrop = proxyUrl.appendingPathComponent("/testnetGTUDrop")
}
