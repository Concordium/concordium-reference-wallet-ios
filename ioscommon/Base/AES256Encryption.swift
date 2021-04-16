//
// Created by Johan Rugager Vase on 20/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import CommonCrypto

protocol Randomizer {
    static func randomIv() -> Data
    static func randomSalt() -> Data
    static func randomData(length: Int) -> Data
}

protocol Crypter {
    func encrypt(_ digest: Data) throws -> Data
    func decrypt(_ encrypted: Data) throws -> Data
}

struct AES256Crypter {

    private var key: Data
    private var iv: Data

    public init(key: Data, iv: Data) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw Error.badKeyLength
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw Error.badInputVectorLength
        }
        self.key = key
        self.iv = iv
    }

    enum Error: Swift.Error {
        case keyGeneration(status: Int)
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badInputVectorLength
    }

    private func crypt(input: Data, operation: CCOperation) throws -> Data {
        let cryptLength = size_t(input.count + kCCBlockSizeAES128)
        var cryptData = [UInt8](repeating: 0, count: cryptLength)

        let keyLength = key.count
        let algorithm: CCAlgorithm = CCAlgorithm(kCCAlgorithmAES)
        let options: CCOptions = CCOptions(kCCOptionPKCS7Padding)

        var numBytesEncrypted: size_t = 0

        let cryptStatus = CCCrypt(operation,
                                  algorithm,
                                  options,
                                  [UInt8](key), keyLength,
                                  [UInt8](iv),
                                  [UInt8](input), input.count,
                                  &cryptData, cryptLength,
                                  &numBytesEncrypted)

        guard cryptStatus == kCCSuccess else {
            print("Error: \(cryptStatus)")
            throw Error.cryptoFailed(status: cryptStatus)
        }

        return Data(bytes: cryptData, count: numBytesEncrypted)
    }

    static func createKey(password: String, salt: Data, rounds: Int = 100_000) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        let passwordData = password.data(using: .utf8)!
        let saltData = salt
        var derivedKeyData = Data(repeating: 0, count: length)

        let localDerivedKeyData = derivedKeyData

        derivedKeyData.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) -> Void in
            status = CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    NSString(string: password).utf8String,
                    size_t(passwordData.count),
                    (saltData as NSData).bytes.bindMemory(to: UInt8.self, capacity: salt.count),
                    size_t(saltData.count),
                    CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256),
                    uint(rounds),
                    ptr.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    size_t(localDerivedKeyData.count)
            )
        }
        guard status == 0 else {
            Logger.error("keyGeneration(status: \(Int(status)))")
            throw Error.keyGeneration(status: Int(status))
        }
        return derivedKeyData
    }

}

extension AES256Crypter: Crypter {

    func encrypt(_ digest: Data) throws -> Data {
        return try crypt(input: digest, operation: CCOperation(kCCEncrypt))
    }

    func decrypt(_ encrypted: Data) throws -> Data {
        return try crypt(input: encrypted, operation: CCOperation(kCCDecrypt))
    }

}

extension AES256Crypter: Randomizer {

    static func randomIv() -> Data {
        return randomData(length: kCCBlockSizeAES128)
    }

    static func randomSalt() -> Data {
        return randomData(length: 32)
    }

    static func randomData(length: Int) -> Data {
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { (mutableBytes: UnsafeMutableRawBufferPointer) in
            SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes.baseAddress!)
        }
        assert(status == Int32(0))
        return data
    }

}
