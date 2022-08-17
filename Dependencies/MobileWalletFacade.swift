//
// Created by Concordium on 13/02/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import MobileWallet

enum WalletError: Error {
    case invalidInput
    case noResponse
    case failed(String)
}

class MobileWalletFacade {
    func createIdRequestAndPrivateData(input: CreateIDRequestV1) throws -> IDRequestV1 {
        let response = try call(
            cFunction: create_id_request_and_private_data_v1,
            with: try encodeInput(input),
            debugTitle: "createIdRequestAndPrivateDataV1"
        )
        
        return try decodeOutput(IDRequestV1.self, from: response)
    }
    
    func createCredential(input: CreateSeedCredentialRequest) throws -> CreateCredentialRequest {
        let response = try call(
            cFunction: create_credential_v1,
            with: try encodeInput(input),
            debugTitle: "createCredentialV1"
        )
        
        return try decodeOutput(CreateCredentialRequest.self, from: response)
    }
    
    func createIdRequestAndPrivateData(input: String) throws -> String {
        try call(cFunction: create_id_request_and_private_data, with: input, debugTitle: "createIdRequestAndPrivateData")
    }

    func createCredential(input: String) throws -> String {
        try call(cFunction: create_credential, with: input, debugTitle: "createCredential")
    }

    func createTransfer(input: String) throws -> String {
        try call(cFunction: create_transfer, with: input, debugTitle: "createTransfer")
    }

    func createShielding(input: String) throws -> String {
        try call(cFunction: create_pub_to_sec_transfer, with: input, debugTitle: "createShielding")
    }
    
    func createUnshielding(input: String) throws -> String {
        try call(cFunction: create_sec_to_pub_transfer, with: input, debugTitle: "createUnshielding")
    }
    
    func createEncrypted(input: String) throws -> String {
        try call(cFunction: create_encrypted_transfer, with: input, debugTitle: "createEncrypted")
    }
    
    func createConfigureDelegation(input: String) throws -> String {
        try call(cFunction: create_configure_delegation_transaction, with: input, debugTitle: "createConfigureDelegation")
    }
    
    func createConfigureBaker(input: String) throws -> String {
        try call(cFunction: create_configure_baker_transaction, with: input, debugTitle: "createConfigureBaker")
    }
    
    func generateBakerKeys() throws -> String {
        try callNoParams(cFunction: generate_baker_keys, debugTitle: "generateBakerKeys")
    }
    
    func decryptEncryptedAmount(input: String) throws -> Int {
         try callIntFunction(cFunction: decrypt_encrypted_amount, with: input, debugTitle: "decryptEncryptedAmount")
    }
   
    func combineEncryptedAmounts(input1: String, input2: String) throws -> String {
           try callTwoParameterFunction(cFunction: combine_encrypted_amounts, with: input1, andWith: input2, debugTitle: "combineEncryptedAmounts")
       }
    
    func checkAccountAddress(input: String) -> Bool {
        input.withCString { inputPointer in
            let response = check_account_address(inputPointer)
            return response > 0
        }
    }

    func generateAccounts(input: String) throws -> String {
        try call(cFunction: generate_accounts, with: input, debugTitle: "generateAccounts")
    }
    
    private func call(cFunction: (UnsafePointer<Int8>?, UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<Int8>?,
                      with input: String,
                      debugTitle: String) throws -> String {
        Logger.debug("TX \(debugTitle):\n\(input)")
        var responseString = ""
        try input.withCString { inputPointer in
            var returnCode: UInt8 = 0
            guard let responsePtr = cFunction(inputPointer, &returnCode) else {
                throw WalletError.noResponse
            }
            responseString = String(cString: responsePtr)
            free_response_string(responsePtr)

            guard returnCode == 1 else {
                Logger.error("RX Error: \(responseString)")
                throw WalletError.failed(responseString)
            }
        }

        Logger.debug("RX \(debugTitle):\n\(responseString)")
        return responseString

    }

    private func callNoParams(cFunction: (UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<Int8>?,
                              debugTitle: String) throws -> String {
        Logger.debug("TX \(debugTitle):\n")
        var responseString = ""
        
        var returnCode: UInt8 = 0
        guard let responsePtr = cFunction(&returnCode) else {
            throw WalletError.noResponse
        }
        responseString = String(cString: responsePtr)
        free_response_string(responsePtr)
        
        guard returnCode == 1 else {
            Logger.error("RX Error: \(responseString)")
            throw WalletError.failed(responseString)
        }
        
        Logger.debug("RX \(debugTitle):\n\(responseString)")
        return responseString
    }

    private func callTwoParameterFunction(cFunction: (UnsafePointer<Int8>?,
                                                      UnsafePointer<Int8>?,
                                                      UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<Int8>?,
                                          with input1: String,
                                          andWith input2: String,
                                          debugTitle: String) throws -> String {
        Logger.debug("TX \(debugTitle):\n\(input1)\n\(input2)")
        var responseString = ""
        try input1.withCString { inputPointer1 in
            try input2.withCString { inputPointer2 in
                var returnCode: UInt8 = 0
                guard let responsePtr = cFunction(inputPointer1, inputPointer2, &returnCode) else {
                    throw WalletError.noResponse
                }
                responseString = String(cString: responsePtr)
                free_response_string(responsePtr)
                
                guard returnCode == 1 else {
                    Logger.error("RX Error: \(responseString)")
                    throw WalletError.failed(responseString)
                }
            }
        }
        Logger.debug("RX \(debugTitle):\n\(responseString)")
        return responseString

    }

    private func callIntFunction(cFunction: (UnsafePointer<Int8>?, UnsafeMutablePointer<UInt8>?) -> UInt64?,
                                 with input: String,
                                 debugTitle: String) throws -> Int {
        Logger.debug("TX \(debugTitle):\n\(input)")
        var response: UInt64?
        try input.withCString { inputPointer in
            var returnCode: UInt8 = 0
            response = cFunction(inputPointer, &returnCode)
            
            if response == nil {
                throw WalletError.noResponse
            }
        }

        guard let uintResponse = response else {
            throw WalletError.failed("RX: Empty integeer value")
        }
        let intResponse = Int(uintResponse)
        Logger.debug("RX \(debugTitle):\n\(intResponse)")
        return intResponse

    }
    
    private let encoder = newJSONEncoder()
    
    private func encodeInput<Input: Encodable>(_ input: Input) throws -> String {
        let data = try encoder.encode(input)
        
        guard let stringData = String(data: data, encoding: .utf8) else {
            throw WalletError.invalidInput
        }
        
        return stringData
    }
    
    private let decoder = newJSONDecoder()
    
    private func decodeOutput<Output: Decodable>(_ outputType: Output.Type, from string: String) throws -> Output {
        guard let data = string.data(using: .utf8) else {
            throw WalletError.noResponse
        }
        
        return try decoder.decode(outputType, from: data)
    }
}
