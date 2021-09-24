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
    static let proxyUrl = URL(string: overriddenProxyUrl ?? "https://wallet-proxy.testnet.concordium.com/v0")!
#elseif MAINNET
    static let proxyUrl = URL(string: overriddenProxyUrl ?? "https://wallet-proxy.mainnet.concordium.software/v0")!
#else // Staging
    static let proxyUrl = URL(string: overriddenProxyUrl ?? "https://wallet-proxy.stagenet.concordium.com/v0")!
#endif

    #if TESTNET
    static let scheme = "concordiumwallettest"
    #elseif MAINNET
    static let scheme = "concordiumwallet"
    #else // Staging
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
    
    /// Generate a callback URI associated with an identifier
    static func callbackUri(with identityCreationID: String) -> String {
        "\(notabeneCallback)/\(identityCreationID)"
    }
    /// Check if the URI is a callback URI
    static func isCallbackUri(uri: String) -> Bool {
        uri.hasPrefix(notabeneCallback)
    }
    /// Get the identity creation identifier and poll URL from a callback URI.
    /// Note that the pollUrl is NOT expected to be URL-encoded.
    static func parseCallbackUri(uri: URL) -> (identityCreationId: String, pollUrl: String)? {
        let identityCreationId = uri.absoluteURL.lastPathComponent
        guard let pollUrl = uri.absoluteString.components(separatedBy: "#code_uri=").last else {
            return nil
        }
        return (identityCreationId, pollUrl)
    }
}
