//
//  TransactionData.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 09/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum Field: Hashable {
    //common for both delegation and baking
    case restake
    
    //delegation
    case delegationAccount
    case pool
    case amount
    
    //baking
    case poolSettings
    case bakerStake
    case bakerAccountCreate
    case bakerAccountUpdate
    
    
    func getLabelText() -> String {
        switch self {
        //common
        case .restake:
            return "stake.receipt.restake".localized
            
        //delegation
        case .delegationAccount:
            return "delegation.receipt.accounttodelegate".localized
        case .pool:
            return "delegation.receipt.tagetbakerpool".localized
        case .amount:
            return "delegation.receipt.delegationamount".localized
      
        //baking
        case .poolSettings:
            return "baking.receipt.poolstatus".localized
        case .bakerStake:
            return "baking.receipt.bakerstake".localized
        case .bakerAccountCreate:
            return "baking.receipt.accountcreate".localized
        case .bakerAccountUpdate:
            return "baking.receipt.accountupdate".localized
        }
    }

    func getOrderIndex() -> Int {
        switch self {
        //common
        case .restake:
            return 3
            
        //delegation
        case .delegationAccount:
            return 0
        case .pool:
            return 2
        case .amount:
            return 1
      
        //baking
        case .poolSettings:
            return 2
        case .bakerStake:
            return 1
        case .bakerAccountCreate:
            return 0
        case .bakerAccountUpdate:
            return 0
        }
    }
    
    static func == (lhs: Field, rhs: Field) -> Bool {
        switch (lhs, rhs) {
        case (delegationAccount, delegationAccount): return true
        case (pool, pool): return true
        case (amount, amount): return true
        case (restake, restake): return true
        case (poolSettings, poolSettings): return true
        case (bakerStake, bakerStake): return true
        case (bakerAccountCreate, bakerAccountCreate): return true
        case (bakerAccountUpdate, bakerAccountUpdate): return true
        default: return false
        }
    }
}

class StakeData: Hashable {
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
    static func == (lhs: StakeData, rhs: StakeData) -> Bool {
        return lhs.field == rhs.field
    }
    
    static func === (lhs: StakeData, rhs: StakeData) -> Bool {
        return lhs.field == rhs.field
        && lhs.getDisplayValue() == rhs.getDisplayValue()
    }
}

//MARK: --
class BakerCreateAccountData: AccountDelegationData {
    init(accountAddress: String) {
        super.init(accountAddress: accountAddress, field: .bakerAccountCreate)
    }
}

class BakerUpdateAccountData: AccountDelegationData {
    init(accountAddress: String) {
        super.init(accountAddress: accountAddress, field: .bakerAccountUpdate)
    }
}

class DelegatioonAccountData: AccountDelegationData {
    init(accountAddress: String) {
        super.init(accountAddress: accountAddress, field: .delegationAccount)
    }
}

class AccountDelegationData: StakeData {
    var accountAddress: String = ""
    fileprivate init(accountAddress: String, field: Field) {
        self.accountAddress = accountAddress
        super.init(field: field)
    }
    
    override func getDisplayValue() -> String {
        return accountAddress
    }
}

class PoolDelegationData: StakeData {
    var pool: BakerPool
    init(pool: BakerPool) {
        self.pool = pool
        super.init(field: .pool)
    }
    override func getDisplayValue() -> String {
        return pool.getDisplayValue()
    }
}

class BakerPoolSettingsData: StakeData {
    var poolSettings: BakerPoolSetting
    init (poolSettings: BakerPoolSetting) {
        self.poolSettings = poolSettings
        super.init(field: .poolSettings)
    }
}

class AmountDelegationData: StakeData{
    var amount: GTU
    init(amount: GTU) {
        self.amount = amount
        super.init(field: .amount)
    }
    override func getDisplayValue() -> String {
        return amount.displayValueWithGStroke()
    }
}

class RestakeDelegationData: StakeData {
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

//enum StakeTransactionType {
//    case registerBaker
//    case updateBaker
//    case registerDelegation
//    case updateDelegation
//}

class StakeDataHandler {
    
    
    //this is the data that is currently on the chain
    private var currentData: Set<StakeData>? = nil
    
    //this is what we are now changing
    private var data: Set<StakeData> = Set()

    init() {
        currentData = Set()
        currentData?.update(with: AmountDelegationData(amount: GTU(intValue: 45)))
        currentData?.update(with: PoolDelegationData(pool: BakerPool.lpool))
        currentData?.update(with: RestakeDelegationData(restake: false))
    }
    
    /// Remove an entry by field
    func remove(field: Field) {
        if let entry = data.filter({ $0.field == field}).first {
            data.remove(entry)
        }
    }
    /// An entry is added only if its value is changed compared to the data that is being updated
    /// An entry is always added in case of new registration
    func add(entry: StakeData) {
        let isValueUnchanged = currentData?.contains(where: { data in
            data === entry
        }) ?? false
        
        if isValueUnchanged {
            return
        }
        //we add or update to the set for the specific field
        //only one entry per field, as the == is overwritten
        data.update(with: entry)
    }
    
    /// Retrieves an entry from the currently saved value
    func getCurrentEntry<T:StakeData>() -> T? {
        return currentData?.filter({ $0 is T}).first as? T
    }
    
    /// Retrieves an entry from the updated values (current trasnaction)
    func getNewEntry<T:StakeData>() -> T? {
        return data.filter({ $0 is T}).first as? T
    }
    
    /// Checks if we are updating
    func hasCurrentData() -> Bool {
        self.currentData != nil
    }
    
    /// Retrieves all the fields that were changed sorted in the right order for display
    func getAllOrdered() -> [StakeData] {
        return data.sorted { lhs, rhs in
            lhs.field.getOrderIndex() < rhs.field.getOrderIndex()
        }
    }
    
    /// Checks if the amount we are now selecting is lower that the previous amount
    func isLoweringStake() -> Bool {
        guard let currentAmount: AmountDelegationData = getCurrentEntry() else {
            return false
        }
        guard let newAmount: AmountDelegationData = getNewEntry() else {
            return false
        }
        if newAmount.amount.intValue < currentAmount.amount.intValue {
            return true
        }
        return false
    }
    
    func moreThan95(atDisposal: Int) -> Bool {
        guard let currentAmount: AmountDelegationData = getCurrentEntry() else {
            return false
        }
        if Double(currentAmount.amount.intValue) > Double(atDisposal) * 0.95 {
            return true
        }
        return false
    }
    
    /// Checks if there are any changes to the stake data
    func containsChanges() -> Bool {
        // we remove the account data and see if there are any actual changes
        let res = data.filter({ !($0 is AccountDelegationData)}).count
        return res != 0
    }
}
