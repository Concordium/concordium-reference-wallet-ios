//
//  ExportTransactionLogViewModel.swift
//  Mock
//
//  Created by Lars Christensen on 19/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum ExportTransactionLogEvent {
    case save
    case done
}

class ExportTransactionLogViewModel: PageViewModel<ExportTransactionLogEvent> {
    @Published var account: AccountDataType
    @Published var descriptionText: String
    
    init(account: AccountDataType) {
        self.account = account
        descriptionText = ""
    }
    
    func getDownloadUrl() -> URL? {
        var urlString = ""
        #if TESTNET
            urlString = "https://api-ccdscan.testnet.concordium.com/rest/export/statement?accountAddress="
        #elseif MAINNET
        if UserDefaults.bool(forKey: "demomode.userdefaultskey".localized) == true {
            urlString = "https://api-ccdscan.testnet.concordium.com/rest/export/statement?accountAddress="
        } else {
            urlString = "https://api-ccdscan.mainnet.concordium.software/rest/export/statement?accountAddress="
        }
        #else
            urlString = "https://api-ccdscan.stagenet.io/rest/export/statement?accountAddress="
        #endif
        return URL(string: "\(urlString)\(account.address)")!
    }
    
    func getTempFileUrl() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentationDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: documentDirectory, withIntermediateDirectories: true)
        let fileUrl = documentDirectory.appendingPathComponent(getFileName())
        return fileUrl
    }

    func deleteTempFile() {
        do {
            try FileManager.default.removeItem(at: getTempFileUrl())
        } catch {
            print("\(error)")
        }
    }
    
    func saved() {
        descriptionText = "exporttransactionlog.save.completed".localized
    }
    
    private func getFileName() -> String {
        return "\(account.address).csv"
    }
}
