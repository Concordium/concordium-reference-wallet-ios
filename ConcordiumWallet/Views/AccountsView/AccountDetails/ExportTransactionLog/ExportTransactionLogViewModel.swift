//
//  ExportTransactionLogViewModel.swift
//  Mock
//
//  Created by Lars Christensen on 19/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum ExportTransactionLogEvent {
    case doneTapped
}

class ExportTransactionLogViewModel: PageViewModel<ExportTransactionLogEvent> {
    @Published var account: AccountDataType
    
    init(account: AccountDataType) {
        self.account = account
    }
    
    func getDownloadUrl() -> URL? {
        var urlString = ""
        #if TESTNET
            urlString = "https://api-ccdscan.testnet.concordium.com/rest/export/statement?accountAddress="
        #elseif MAINNET
            urlString = "https://api-ccdscan.mainnet.concordium.software/rest/export/statement?accountAddress="
        #else
            urlString = "https://api-ccdscan.stagenet.io/rest/export/statement?accountAddress="
        #endif
        return URL(string: "\(urlString)\(account.address)")!
//        return URL(string: "https://api-ccdscan.mainnet.concordium.software/rest/export/statement?accountAddress=35CJPZohio6Ztii2zy1AYzJKvuxbGG44wrBn7hLHiYLoF2nxnh")
    }

    func getFileName() -> String {
        return "\(account.address).csv"
    }
}
