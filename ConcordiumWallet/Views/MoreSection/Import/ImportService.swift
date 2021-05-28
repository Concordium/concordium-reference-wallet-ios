//
// Created by Concordium on 24/06/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

struct ImportService {
    let storageManager: StorageManagerProtocol
    let accountsService: AccountsServiceProtocol
    let mobileWallet: MobileWalletProtocol
    
    init(storageManager: StorageManagerProtocol, accountsService: AccountsServiceProtocol, mobileWallet: MobileWalletProtocol) {
        self.storageManager = storageManager
        self.accountsService = accountsService
        self.mobileWallet = mobileWallet
    }

    func checkPassword(importFile url: URL, exportPassword: String) throws {
        let data = try Data(contentsOf: url)
        let exportContainer = try ExportContainer(data: data)
        let importedData = try decryptImport(exportContainer, exportPassword: exportPassword)
        
        //Logger.debug("import data: \(importedData.prettyPrintedJSONString)");
        
        _ = try decodeImport(importedData: importedData)
    }

    func importFile(from url: URL, pwHash: String, exportPassword: String) throws -> AnyPublisher<ImportedItemsReport, Error> {
        let data = try Data(contentsOf: url)
        //Logger.debug("file imported:  \(String(data: data, encoding: .utf8)!)")
        let exportContainer = try ExportContainer(data: data)
        let importedData = try decryptImport(exportContainer, exportPassword: exportPassword)
        let importedObjects = try decodeImport(importedData: importedData)
        Logger.debug("Imported  \(importedObjects.value)")
        return Importer(storageManager: storageManager, mobileWallet: mobileWallet, accountsService: accountsService).importToDatabase(importedObjects.value, pwHash: pwHash)
    }

    private func decodeImport(importedData: Data) throws -> ExportVersionContainer {
        let importedObjects = try ExportVersionContainer(data: importedData)
        guard importedObjects.v == 1 else {
            throw ImportError.unsupportedVersion(inputVersion: importedObjects.v)
        }

        guard importedObjects.type == ExportVersionContainer.concordiumWalletExportType else {
            throw ImportError.unsupportedWalletType(type: importedObjects.type)
        }

        guard importedObjects.environment == ExportVersionContainer.concordiumWalletExportEnvironment else {
            throw ImportError.unsupportedEnvironemt(environment: importedObjects.environment)
        }

        return importedObjects
    }

    private func decryptImport(_ exportContainer: ExportContainer, exportPassword: String) throws -> Data {
        let metadata = exportContainer.metadata
        let iterations = metadata.iterations
        guard let salt = Data(base64Encoded: metadata.salt) else {
            throw ImportError.corruptDataError(reason: "salt not properly formatted")
        }
        guard let iv = Data(base64Encoded: metadata.initializationVector) else {
            throw ImportError.corruptDataError(reason: "initializationVector not properly formatted")
        }
        guard let cipher = Data(base64Encoded: exportContainer.cipherText) else {
            throw ImportError.corruptDataError(reason: "cipherText not properly formatted")
        }
        let key = try AES256Crypter.createKey(password: exportPassword, salt: salt, rounds: iterations)
        let exportData = try AES256Crypter(key: key, iv: iv).decrypt(cipher)
        return exportData
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
