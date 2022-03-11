//
//  TransactionData.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 09/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum Field: Hashable {
    case account
    case pool
    case amount
    case restake
    
    func getLabelText() -> String {
        switch self {
        case .account:
            return "delegation.receipt.accounttodelegate".localized
        case .pool:
            return "delegation.receipt.tagetbakerpoolid".localized
        case .amount:
            return "delegation.receipt.delegationamount".localized
        case .restake:
            return "delegation.receipt.restake".localized
        }
    }

    
    static func == (lhs: Field, rhs: Field) -> Bool {
        switch (lhs, rhs) {
        case (account, account): return true
        case (pool, pool): return true
        case (amount, amount): return true
        case (restake, restake): return true
        default: return false
        }
    }
    
    
}

class DelegationData: Hashable {
    var field: Field
    func getKeyLabel() -> String {
        field.getLabelText()
    }
    
    func getDisplayValue() -> String {
        fatalError("Subclasses need to implement the `getDisplayValue()` method.")
    }
    init(field: Field) {
        self.field = field
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(field.getLabelText())
    }
    static func == (lhs: DelegationData, rhs: DelegationData) -> Bool {
        return lhs.field == rhs.field
    }
}

//MARK: --
class AccountDelegationData: DelegationData {
    var accountAddress: String = ""
    init(accountAddress: String) {
        self.accountAddress = accountAddress
        super.init(field: .account)
    }
    
    override func getDisplayValue() -> String {
        return accountAddress
    }
}

class PoolDelegationData: DelegationData {
    var pool: BakerPool
    init(pool: BakerPool) {
        self.pool = pool
        super.init(field: .pool)
    }
    override func getDisplayValue() -> String {
        return pool.getDisplayValue()
    }
}

class AmountDelegationData: DelegationData{
    var amount: GTU
    init(amount: GTU) {
        self.amount = amount
        super.init(field: .amount)
    }
    override func getDisplayValue() -> String {
        return amount.displayValue()
    }
}

class RestakeDelegationData: DelegationData {
    var restake: Bool
    init(restake: Bool) {
        self.restake = restake
        super.init(field: .restake)
    }

    override func getDisplayValue() -> String {
        if restake {
            return "delegation.receipt.addedtodelegation".localized
        } else {
            return "delegation.receipt.notaddedtodelegation".localized
        }
    }
}


class DelegationDataHandler {
    private var currentData: Set<DelegationData>? = nil
    private var data: Set<DelegationData> = Set()

    init() {
        currentData = Set()
        currentData?.update(with: AmountDelegationData(amount: GTU(intValue: 45)))
        currentData?.update(with: PoolDelegationData(pool: BakerPool.lpool))
    }
    
    func remove(field: Field) {
        if let entry = data.filter({ $0.field == field}).first {
            data.remove(entry)
        }
    }
    
    func add(entry: DelegationData) {
        //we add or update to the set for the specific field
        //only one entry per field, as the == is overwritten
        data.update(with: entry)
    }
    
    func getCurrentEntry<T:DelegationData>() -> T? {
        return currentData?.filter({ $0 is T}).first as? T
    }
}
