import Foundation

enum SchemaError: Error {
    case invalidBase64(String)
    case unknownFormat
    
    var codeAndMsg: (Int, String) {
        switch self {
        case .invalidBase64(_):
            return (1110, "Provided schema is not valid base64")
        case .unknownFormat:
            return (1120, "Unknown schema format")
        }
    }
}

enum SessionError: Error {
    case sessionNotFound(topic: String)
    case unexpectedNamespaces(namespaces: [String])
    case unexpectedAccountCount(addresses: [String])
    case accountNotFound(address: String)
    
    var codeAndMsg: (Int, String) {
        switch self {
        case let .sessionNotFound(topic: topic):
            return (7001, "Session not found for topic \(topic)")
        case let .unexpectedNamespaces(namespaces: n):
            return (7010, "Expected single namespace with key 'ccd' but got \(n)")
        case let .unexpectedAccountCount(addresses: a):
            return (7011, "Expected single address but got '\(a)'")
        case let .accountNotFound(address: addr):
            return (7012, "Account with address '\(addr)' not found")
        }
    }
}

enum RequestError: Error {
    case unsupportedTransactionType(TransferType)
    case invalidPayload(String)
    
    var codeAndMsg: (Int, String) {
        switch self {
        case let .unsupportedTransactionType(type):
            return (8100, "Unsupported transaction type '\(type)' (only 'Update' is supported)")
        case let .invalidPayload(msg):
            return (8200, "Invalid payload: \(msg)")
        }
    }
}

enum WalletConnectError: Error {
    case internalError(String)
    case schemaError(SchemaError)
    case sessionError(SessionError)
    case requestError(RequestError)
    case transactionError(String)
    case userRejected
    
    var codeAndMsg: (Int, String) {
        switch self {
        case let .internalError(msg):
            return (10000, msg)
        case let .schemaError(err):
            let (code, msg) = err.codeAndMsg
            return (code, "Schema error: \(msg)")
        case let .sessionError(err):
            let (code, msg) = err.codeAndMsg
            return (code, "Session error: \(msg)")
        case let .requestError(err):
            let (code, msg) = err.codeAndMsg
            return (code, "Request error: \(msg)")
        case let .transactionError(msg):
            return (11000, "Cannot submit transaction: \(msg)")
        case .userRejected:
            return (5000, "Request rejected by user")
        }
    }
}
