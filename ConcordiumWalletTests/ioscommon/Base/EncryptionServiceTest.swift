//
// Created by Concordium on 20/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import XCTest
@testable import ProdMainNet

class EncryptionServiceTest: XCTestCase {
    func testGenerateKey() {
        let key = try? AES256Crypter.createKey(password: "password", salt: "salt".data(using: .utf8)!)
        let expectedKey = "A5Si7eMyyaE+uC6bJGMWBMMd+Xi04vD70sVJlE+deaU="
        XCTAssertEqual(key!.base64EncodedString(), expectedKey)
    }

    func testEncryptWithKnownValues() {
        do {
            let salt = Data(base64Encoded: "Lb9ul7JP2FzxZITi+5PebOM0VMZPyl/ogzRUIZBg3zM=")!
            let iv = Data(base64Encoded: "Iq+RX1R0oMtD61n5MnaonQ==")!
            let password = "password"

            let key = try AES256Crypter.createKey(password: password, salt: salt)
            let expectedKey = "oPYV3DzzpCh25Z52JxnokB3c/3g9uxkjcllPp/RRcD0="
            XCTAssertEqual(key.base64EncodedString(), expectedKey)
            
            let encryptionService = try AES256Crypter(key: key, iv: iv)

            let clearText = "AES256"
            let clearTextData = clearText.data(using: .utf8)!
            let cipher = try encryptionService.encrypt(clearTextData)
            let expectedCipherBase64Encoded = "sQCDJmYQ7h0TIE2g1GgPqg=="
            XCTAssertEqual(expectedCipherBase64Encoded, cipher.base64EncodedString())

            let decrypted = try encryptionService.decrypt(cipher)
            XCTAssertEqual(clearText, String(data: decrypted, encoding: .utf8))
        } catch {
            XCTFail("an error was thrown: \(error)")
        }
    }
    
    func testEncryptWithRandomValues() {
        do {
            let salt = AES256Crypter.randomSalt()
            let iv = AES256Crypter.randomIv()
            let password = "password"

            let key = try AES256Crypter.createKey(password: password, salt: salt)
            let encryptionService = try AES256Crypter(key: key, iv: iv)

            //swiftlint:disable line_length
            let clearText = """
                 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin vel sodales eros. Maecenas quis erat ac massa convallis faucibus at quis massa. Vivamus laoreet nulla in maximus volutpat. In et ornare tortor. Nullam a ligula feugiat enim elementum rutrum. Ut fringilla dignissim tempor. Aenean malesuada neque nec ante dictum, eget ullamcorper tellus aliquam.

                 Ut eu viverra elit, congue sagittis nibh. Maecenas et tellus mauris. Aenean at eros ultrices, convallis tellus at, dictum erat. Fusce sagittis lorem nunc, sed sodales velit efficitur et. Integer et enim porta, congue purus non, pulvinar nisi. Integer fringilla commodo egestas. Phasellus imperdiet ornare porttitor. Praesent pharetra, nunc quis fermentum consequat, massa orci luctus lorem, ut mollis orci odio ut neque. Fusce ultrices sit amet ante quis elementum. Cras hendrerit in mi sed ullamcorper. Integer volutpat eget nibh sit amet viverra. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus venenatis lectus magna, in dictum nulla aliquet ac. Fusce eget luctus sapien. Proin ut massa sed orci blandit sagittis ac eu ipsum. Praesent pulvinar, nibh non maximus lacinia, dolor tellus pulvinar urna, ut mattis tortor felis sit amet eros.
            """
            let clearTextData = clearText.data(using: .utf8)!
            let cipher = try encryptionService.encrypt(clearTextData)

            let decrypted = try encryptionService.decrypt(cipher)
            XCTAssertEqual(clearText, String(data: decrypted, encoding: .utf8))
        } catch {
            XCTFail("an error was thrown: \(error)")
        }
    }
}
