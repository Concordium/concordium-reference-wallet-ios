//
// Created by Concordium on 31/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import XCTest
@testable import ProdMainNet

class KeychainWrapperTest: XCTestCase {
    let key = "testkey"
    let keychain = KeychainWrapper()

    override func tearDown() {
        _ = keychain.deleteKeychainItem(withKey: key)
    }

    func testStoreAndRetrieveValue() {
        keychain.store(key: key, value: "test", securedByPassword: "123456")
                .flatMap { keychain.getValue(for: key, securedByPassword: "123456") }
                .onSuccess { XCTAssertEqual($0, "test") }
                .onFailure { XCTFail("keychain returned error: \($0)") }
    }

    func testStoreAndCheckValidPassword() {
        keychain.storePassword(password: "qwerty")
                .flatMap { _ in keychain.checkPassword(password: "qwerty") }
                .onSuccess { XCTAssertEqual($0, true) }
                .onFailure { XCTFail("keychain returned error: \($0)") }
    }

    func testStoreAndCheckPasswordCreated() {
        keychain.storePassword(password: "qwerty")
                .map { _ in keychain.passwordCreated() }
                .onSuccess { XCTAssertEqual($0, true) }
                .onFailure { XCTFail("keychain returned error: \($0)") }
    }

    #if !targetEnvironment(simulator)
    //password protected keychain items only work on a real device
    func testStoreAndCheckInvalidPassword() {
        keychain.storePassword(password: "qwerty")
                .flatMap { _ in keychain.checkPassword(password: "wrong") }
                .onSuccess { val in  XCTFail("keychain should not return success on wrong password \(val)") }
                .onFailure {
                    if case KeychainError.wrongPassword = $0 {
                        //success - this is the expected return value
                    } else {
                        XCTFail("keychain should not return success on wrong password")
                    }
                }
    }
    #endif
}
