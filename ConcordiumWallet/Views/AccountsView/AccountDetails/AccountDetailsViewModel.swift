//
// Created by Concordium on 01/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

class TransactionsListViewModel {
    @Published var transactions = [TransactionViewModel]()
}

enum AccountMenuState {
    case open
    case closed
}

class AccountDetailsViewModel {
    var name: String?
    var address: String?
    
    @Published var selectedTab: AccountDetailTab = .transfers
    @Published var selectedBalance: AccountBalanceTypeEnum = .balance
    
    @Published var accountState: SubmissionStatusEnum = .committed
    @Published var balance: String = ""
    @Published var hasTransfers = true // assume transfers exists to avoid showing placeholders until we know about it
    @Published var transactionsList = TransactionsListViewModel()
    @Published var allAccountTransactionsList = TransactionsListViewModel()
    @Published var showUnlockButton = false
    @Published var isReadOnly = false
    @Published var isShielded = false
    @Published var atDisposal: String = ""
    @Published var stakedValue: String = ""
    @Published var stakedLabel: String?
    @Published var hasStaked: Bool = false
    @Published var isShieldedEnabled: Bool = true
    @Published var menuState: AccountMenuState = .closed
    
    init(account: AccountDataType, balanceType: AccountBalanceTypeEnum) {
        setAccount(account: account, balanceType: balanceType)
    }
    
    func setAccount(account: AccountDataType, balanceType: AccountBalanceTypeEnum) {
        accountState = account.transactionStatus ?? .committed
        name = account.displayName
        address = account.address
        isReadOnly = account.isReadOnly
        isShieldedEnabled = account.showsShieldedBalance
        if balanceType == .shielded {
            isShielded = true
            balance = GTU(intValue: account.forecastEncryptedBalance).displayValue()
            hasStaked = false
        } else {
            isShielded = false
            balance = GTU(intValue: account.forecastBalance).displayValue()
            if let baker = account.baker, baker.bakerID != -1 {
                self.hasStaked = true
                self.stakedLabel = String(format: "accountDetails.bakingstakelabel".localized, String(baker.bakerID))
                self.stakedValue = GTU(intValue: baker.stakedAmount ).displayValueWithGStroke()
                
            } else if let delegation = account.delegation {
                let pool = BakerPool.from(delegationType: delegation.delegationTargetType, bakerId: delegation.delegationTargetBakerID)
                self.hasStaked = true
                self.stakedLabel = String(format: "accountDetails.delegationstakeLabel".localized, pool.getDisplayValueForAccountDetails())
                self.stakedValue = GTU(intValue: Int(delegation.stakedAmount) ).displayValueWithGStroke()
            } else {
                self.hasStaked = false
                stakedLabel = nil
            }
        }
        atDisposal = GTU(intValue: account.forecastAtDisposalBalance).displayValueWithGStroke()
    }

    func toggleMenu() {
        menuState = menuState == .closed ? .open : .closed
    }
    
    func setTransactions(transactions: [TransactionViewModel]) {
        appendTransactions(transactions: transactions, shouldClearPrevious: true)
    }
    
    func setAllAccountTransactions(transactions: [TransactionViewModel]) {
        appendAllAccountTransactions(transactions: transactions, shouldClearPrevious: true)
    }

    func appendTransactions(transactions: [TransactionViewModel], shouldClearPrevious: Bool = false) {
        if transactions.count == 0 {
            if shouldClearPrevious {
                transactionsList.transactions = transactions
            } 
//            //we did not receive new transactions - therefore the last transaction in the list must be the last existing
//            if transactionsList.transactions.count > 0 {
//                transactionsList.transactions[transactionsList.transactions.count - 1].isLast = true
//            }
        } else {
            if shouldClearPrevious {
                transactionsList.transactions = transactions
            } else {
                transactionsList.transactions.append(contentsOf: transactions)
            }
        }
        
        let containsLockedTransaction = transactionsList.transactions.contains {
            $0.total == nil
        }
        showUnlockButton = containsLockedTransaction
    }
    
    func appendAllAccountTransactions(transactions: [TransactionViewModel], shouldClearPrevious: Bool = false) {
        if transactions.count == 0 {
//            //we did not receive new transactions - therefore the last transaction in the list must be the last existing
//            if allAccountTransactionsList.transactions.count > 0 {
//                allAccountTransactionsList.transactions[allAccountTransactionsList.transactions.count - 1].isLast = true
//            }
        } else {
            if shouldClearPrevious {
                allAccountTransactionsList.transactions = transactions
            } else {
                allAccountTransactionsList.transactions.append(contentsOf: transactions)
            }
        }
    }
}

extension BakerPool {
    fileprivate func getDisplayValueForAccountDetails() -> String {
        switch self {
        case .lpool:
            return "accountDetails.lpoolvalue".localized
        case .bakerPool(let bakerId):
            return String(format: "accountDetails.bakerpoolvalue".localized, bakerId)
        }
    }
}
