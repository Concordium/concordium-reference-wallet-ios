//
// Created by Concordium on 19/02/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

struct ApiConstants {

#if DEBUG
    // UserDefaults loads from launch arguments: https://www.swiftbysundell.com/articles/launch-arguments-in-swift/
    static let overriddenProxyUrl = UserDefaults.standard.string(forKey: "proxy")
#else
    static let overriddenProxyUrl: String? = nil
#endif
#if TESTNET
    static let proxyUrl = URL(string: overriddenProxyUrl ?? "https://wallet-proxy.testnet.concordium.com")!
#elseif MAINNET
    static let proxyUrl = URL(string: overriddenProxyUrl ?? "https://wallet-proxy.mainnet.concordium.software")!
#else // Staging
    static let proxyUrl = URL(string: overriddenProxyUrl ?? "https://wallet-proxy.stagenet.concordium.com")!
#endif

    #if TESTNET
    static let scheme = "concordiumwallettest"
    #elseif MAINNET
    static let scheme = "concordiumwallet"
    #else // Staging
    static let scheme = "concordiumwalletstaging"
    #endif
    static let notabeneCallback = "\(scheme)://identity-issuer/callback"

    static let ipInfo = proxyUrl.appendingPathComponent("/v0/ip_info")
    static let global = proxyUrl.appendingPathComponent("/v0/global")
    static let submitCredential = proxyUrl.appendingPathComponent("/v0/submitCredential")
    static let submissionStatus = proxyUrl.appendingPathComponent("/v0/submissionStatus")
    static let accNonce = proxyUrl.appendingPathComponent("/v0/accNonce")
    static let accEncryptionKey = proxyUrl.appendingPathComponent("/v0/accEncryptionKey")
    static let submitTransfer = proxyUrl.appendingPathComponent("/v0/submitTransfer")
    static let transferCost = proxyUrl.appendingPathComponent("/v0/transactionCost")
    static let accountBalance = proxyUrl.appendingPathComponent("/v0/accBalance")
    static let accountTransactions = proxyUrl.appendingPathComponent("v1/accTransactions")
    static let gtuDrop = proxyUrl.appendingPathComponent("/v0/testnetGTUDrop")
}
