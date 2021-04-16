//
//  KeychainWrapper.swift
//  ConcordiumWallet
//
//  Created by Dennis Vexborg Kristensen on 18/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import LocalAuthentication
import Security
import CryptoKit

protocol KeychainWrapperProtocol {
    func storePassword(password: String) -> Result<String, KeychainError>
    func checkPasswordHash(pwHash: String) -> Result<Bool, KeychainError>
    func checkPassword(password: String) -> Result<Bool, KeychainError>
    func passwordCreated() -> Bool
    func hashPassword(_ password: String) -> String

    func storePasswordBehindBiometrics(pwHash: String) -> Result<Void, KeychainError>
    func getPasswordWithBiometrics() -> Result<String, KeychainError>

    func store(key: String, value: String, securedByPassword: String) -> Result<Void, KeychainError>
    func getValue(for key: String, securedByPassword: String) -> Result<String, KeychainError>

    func getValueWithBiometrics(for key: String) -> Result<String, KeychainError>
    func storeWithBiometrics(key: String, value: String) -> Result<Void, KeychainError>

    func deleteKeychainItem(withKey key: String) -> Result<Void, KeychainError>
}

enum KeychainError: Error {
    case invalidInput
    case noPassword
    case unexpectedPasswordData
    case unexpectedItemData
    case passwordNotFound
    case wrongPassword
    case itemNotFound
    case userCancelled
    case unhandledError(status: OSStatus)
}

enum KeychainKeys: String {
    case loginPassword
    case password
    case oldPassword // Old password is keept in keychain while re-encrypting all accounts (resume process on failure).
}

extension KeychainWrapper: KeychainWrapperProtocol {
    func storePassword(password: String) -> Result<String, KeychainError> {
        let hash = hashPassword(password)
        return store(key: KeychainKeys.loginPassword.rawValue,
                     value: passwordCheck,
                     securedByPassword: hash)
        .map { _ in hash }
        
    }
    
    func hashPassword(_ password: String) -> String {
        let data = password.data(using: .utf8)!
        return SHA512.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }

    func passwordCreated() -> Bool {
        keychainItemExists(forKey: KeychainKeys.loginPassword.rawValue)
    }

    func checkPassword(password: String) -> Result<Bool, KeychainError> {
        checkPasswordHash(pwHash: hashPassword(password))
    }

    func checkPasswordHash(pwHash: String) -> Result<Bool, KeychainError> {
        getValue(for: KeychainKeys.loginPassword.rawValue, securedByPassword: pwHash)
            .map { readPwCheck in
                passwordCheck == readPwCheck
        }.flatMap { pwEquals in
            pwEquals ? Result.success(true) : Result.failure(KeychainError.wrongPassword)
        }
    }

    func storePasswordBehindBiometrics(pwHash: String) -> Result<Void, KeychainError> {
        let data = pwHash.data(using: .utf8)!
        return deleteKeychainItem(withKey: KeychainKeys.password.rawValue).flatMap {
            setKeychainItem(withKey: KeychainKeys.password.rawValue, itemData: data, password: nil)
        }
    }

    func getPasswordWithBiometrics() -> Result<String, KeychainError> {
         getKeychainItem(withKey: KeychainKeys.password.rawValue, password: nil).flatMap {
             guard let pwHash = String(data: $0, encoding: .utf8) else {
                 return .failure(KeychainError.passwordNotFound)
             }
             return .success(pwHash)
         }
    }

    func store(key: String, value: String, securedByPassword password: String) -> Result<Void, KeychainError> {
        let data = value.data(using: .utf8)!
        return setKeychainItem(withKey: key, itemData: data, password: password)
    }

    func getValue(for key: String, securedByPassword password: String) -> Result<String, KeychainError> {
        getKeychainItem(withKey: key, password: password).flatMap {
            guard let result = String(data: $0, encoding: .utf8) else {
                return .failure(KeychainError.unexpectedItemData)
            }
            return .success(result)
        }
    }

    func getValueWithBiometrics(for key: String) -> Result<String, KeychainError> {
        getPasswordWithBiometrics().flatMap {
            getValue(for: key, securedByPassword: $0)
        }
    }

    func storeWithBiometrics(key: String, value: String) -> Result<Void, KeychainError> {
        getPasswordWithBiometrics().flatMap {
            store(key: key, value: value, securedByPassword: $0)
        }
    }
}

struct KeychainWrapper {
    private let passwordCheck = "passwordcheck"

    private enum KeychainService: String {
        case concordiumWallet = "ConcordiumWallet"
    }

    private func keychainItemExists(forKey key: String) -> Bool {
        var query = keychainQuery(withKey: key)
        query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUIFail
        let res = SecItemCopyMatching(query as CFDictionary, nil)
        return res == errSecInteractionNotAllowed || res == errSecSuccess
    }

    /**
    * password: If nil, data is stored using biometrics
    */
    private func setKeychainItem(withKey key: String, itemData: Data, password: String?) -> Result<Void, KeychainError> {
        var query = keychainQuery(withKey: key)

        let access: SecAccessControl?
        if let password = password {
            access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .applicationPassword, nil)

            let localAuthenticationContext = LAContext()
            let theApplicationPassword = password.data(using: .utf8)
            _ = localAuthenticationContext.setCredential(theApplicationPassword, type: .applicationPassword)

            //This does not work on simulator :-( https://stackoverflow.com/questions/53341248
            #if !targetEnvironment(simulator)
            query[kSecUseAuthenticationContext as String] = localAuthenticationContext
            #endif
        } else {
            access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .biometryCurrentSet, nil)
        }
        query[kSecAttrAccessControl as String] = access as AnyObject?

        if keychainItemExists(forKey: key) {
            _ = deleteKeychainItem(withKey: key)
        }

        query[kSecValueData as String] = itemData as AnyObject?
        let result = SecItemAdd(query as CFDictionary, nil)
        if result != errSecSuccess {
            return .failure(mapKeychainError(error: result))
        }
        return .success(Void())
    }

    private func getKeychainItem(withKey key: String, password: String?) -> Result<Data, KeychainError> {
        var query = keychainQuery(withKey: key)

        let access: SecAccessControl?
        if let password = password {
            access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .applicationPassword, nil)

            let localAuthenticationContext = LAContext()
            let theApplicationPassword = password.data(using: .utf8)
            _ = localAuthenticationContext.setCredential(theApplicationPassword, type: .applicationPassword)

            //This does not work on simulator :-( https://stackoverflow.com/questions/53341248
            #if !targetEnvironment(simulator)
            query[kSecUseAuthenticationContext as String] = localAuthenticationContext
            #endif
        } else {
            let localAuthenticationContext = LAContext()
            let pwType = AppSettings.passwordType?.rawValue ?? PasswordType.passcode.rawValue
            localAuthenticationContext.localizedCancelTitle = "keychain.popup.button.enter\(pwType)".localized
            query[kSecUseAuthenticationContext as String] = localAuthenticationContext
            access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .biometryCurrentSet, nil)
        }

        query[kSecAttrAccessControl as String] = access as AnyObject?
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        var item: CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &item)
        if result != errSecSuccess {
            return .failure(mapKeychainError(error: result))
        }

        guard
            let resultsDict = item as? [String: Any],
            let resultsData = resultsDict[kSecValueData as String] as? Data
            else { return .failure(.unexpectedItemData) }
        return .success(resultsData)
    }

    public func deleteKeychainItem(withKey key: String) -> Result<Void, KeychainError> {
        let query = keychainQuery(withKey: key)
        let result = SecItemDelete(query as CFDictionary)
        if result != errSecSuccess && result != errSecItemNotFound {
            return .failure(mapKeychainError(error: result))
        }
        return .success(Void())
    }

    private func keychainQuery(withKey key: String?) -> [String: AnyObject] {
        var query = [String: AnyObject]()

        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = KeychainService.concordiumWallet.rawValue as AnyObject?
        query[kSecAttrAccessGroup as String] = nil

        if let key = key {
            query[kSecAttrAccount as String] = key as AnyObject?
        }
        return query
    }

    private func mapKeychainError(error: OSStatus) -> KeychainError {

        switch error {
        case errSecItemNotFound:
            return .itemNotFound
        case errSecAuthFailed:
            return .wrongPassword
        case errSecUserCanceled:
            return .userCancelled
        default:
            break
        }

        return .unhandledError(status: error)
    }
}
