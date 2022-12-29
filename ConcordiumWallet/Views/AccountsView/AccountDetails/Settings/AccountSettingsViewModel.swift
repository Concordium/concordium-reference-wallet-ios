//
//  AccountSettingsViewModel.swift
//  Mock
//
//  Created by Lars Christensen on 29/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum AccountSettingsLogEvent {
    case releaseSchedule
    case transferFilters
    case showShielded
    case hideShielded
    case exportPrivateKey
    case exportTransactionLog
    case renameAccount
}

class AccountSettingsViewModel: PageViewModel<AccountSettingsLogEvent> {
    @Published var account: AccountDataType
    
    init(account: AccountDataType) {
        self.account = account
    }
}
