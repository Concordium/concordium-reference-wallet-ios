//
//  StakeDataHandler.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 09/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum Field: Hashable {
    // common for both delegation and baking
    case restake
    
    // delegation
    case delegationAccount
    case delegationStopAccount
    case pool
    case amount
    
    // baking
    case poolSettings
    case bakerStake
    case bakerMetadataURL
    case bakerAccountCreate
    case bakerAccountUpdate
    case bakerKeys
 
    // swiftlint:disable cyclomatic_complexity
    func getLabelText() -> String {
        switch self {
        // common
        case .restake:
            return "stake.receipt.restake".localized
            
        // delegation
        case .delegationAccount:
            return "delegation.receipt.accounttodelegate".localized
        case .delegationStopAccount:
            return "delegation.receipt.accounttostop".localized
        case .pool:
            return "delegation.receipt.tagetbakerpool".localized
        case .amount:
            return "delegation.receipt.delegationamount".localized
      
        // baking
        case .poolSettings:
            return "baking.receipt.poolstatus".localized
        case .bakerStake:
            return "baking.receipt.bakerstake".localized
        case .bakerAccountCreate:
            return "baking.receipt.accountcreate".localized
        case .bakerAccountUpdate:
            return "baking.receipt.accountupdate".localized
        case .bakerMetadataURL:
            return "baking.receipt.metadataurl".localized
        case .bakerKeys:
            return ""
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func getOrderIndex() -> Int {
        switch self {
        // common
        case .restake:
            return 3
            
        // delegation
        case .delegationAccount:
            return 0
        case .delegationStopAccount:
            return 0
        case .pool:
            return 2
        case .amount:
            return 1
      
        // baking
        case .poolSettings:
            return 2
        case .bakerStake:
            return 1
        case .bakerAccountCreate:
            return 0
        case .bakerAccountUpdate:
            return 0
        case .bakerMetadataURL:
            return 4
        case .bakerKeys:
            return 5
        }
    }
}

struct DisplayValue: Equatable {
    let key: String
    let value: String
}

protocol StakeDataConvertible {
    var asStakeData: StakeData { get }
}

protocol FieldValue: StakeDataConvertible {
    var field: Field { get }
    var costParameters: [TransferCostParameter] { get }
    var displayValues: [DisplayValue] { get }
    
    func add(to transaction: inout TransferDataType)
}

extension FieldValue {
    var asStakeData: StakeData {
        StakeData(field: field, value: self)
    }
}

protocol SimpleFieldValue: FieldValue {
    var displayValue: String { get }
}

extension SimpleFieldValue {
    var displayValues: [DisplayValue] {
        return [DisplayValue(key: field.getLabelText(), value: displayValue)]
    }
}

protocol AccountValue: FieldValue {
    var accountAddress: String { get }
}

extension AccountValue {
    var costParameters: [TransferCostParameter] { [] }
    
    var displayValues: [DisplayValue] {
        return [DisplayValue(key: field.getLabelText(), value: accountAddress)]
    }
    
    func add(to transaction: inout TransferDataType) {}
}

struct StakeData: Hashable {
    let field: Field
    let value: FieldValue
    
    var displayValues: [DisplayValue] {
        value.displayValues
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(field)
    }
    
    static func == (lhs: StakeData, rhs: StakeData) -> Bool {
        return lhs.field == rhs.field
    }
    
    static func === (lhs: StakeData, rhs: StakeData) -> Bool {
        return lhs.field == rhs.field
    }
}

// MARK: - BAKER data
struct BakerCreateAccountData: AccountValue {
    let field = Field.bakerAccountCreate
    let accountAddress: String
}

struct BakerUpdateAccountData: AccountValue {
    let field = Field.bakerAccountUpdate
    let accountAddress: String
}

struct BakerPoolSettingsData: SimpleFieldValue {
    let field = Field.poolSettings
    let poolSettings: BakerPoolSetting
    
    var displayValue: String { poolSettings.getDisplayValue() }
    var costParameters: [TransferCostParameter] { [.openStatus] }
    
    func add(to transaction: inout TransferDataType) {
        switch poolSettings {
        case .open:
            transaction.openStatus = "openForAll"
        case .closed:
            transaction.openStatus = "closedForAll"
        case .closedForNew:
            transaction.openStatus = "closedForNew"
        }
    }
}

struct BakerMetadataURLData: SimpleFieldValue {
    let field = Field.bakerMetadataURL
    let metadataURL: String
    
    var displayValue: String { metadataURL }
    var costParameters: [TransferCostParameter] { [.metadataSize(metadataURL.count)] }
        
    func add(to transaction: inout TransferDataType) {
        transaction.metadataURL = metadataURL
    }
}

struct BakerKeyData: FieldValue {
    let field = Field.bakerKeys
    let keys: GeneratedBakerKeys
    
    var costParameters: [TransferCostParameter] { [] } 
    
    var displayValues: [DisplayValue] {
        [
            DisplayValue(
                key: "baking.receipt.electionverifykey".localized,
                value: keys.electionVerifyKey.splitInto(lines: 2)
            ),
            DisplayValue(
                key: "baking.receipt.signatureverifykey".localized,
                value: keys.signatureVerifyKey.splitInto(lines: 2)
            ),
            DisplayValue(
                key: "baking.receipt.aggregationverifykey".localized,
                value: keys.aggregationVerifyKey.splitInto(lines: 6)
            )
        ]
    }
    
    // Baker keys are pass explicitly elsewhere
    func add(to transaction: inout TransferDataType) {}
}

struct RestakeBakerData: SimpleFieldValue {
    let field = Field.restake
    let restake: Bool
    
    var displayValue: String {
        if restake {
            return "baking.receipt.addedtostake".localized
        } else {
            return "baking.receipt.notaddedtostake".localized
        }
    }
    var costParameters: [TransferCostParameter] { [.restake] }
    
    func add(to transaction: inout TransferDataType) {
        transaction.restakeEarnings = restake
    }
}

// MARK: - DELEGATION data
struct DelegationAccountData: AccountValue {
    let field = Field.delegationAccount
    let accountAddress: String
}

struct DelegationStopAccountData: AccountValue {
    let field = Field.delegationStopAccount
    let accountAddress: String
}

struct PoolDelegationData: SimpleFieldValue {
    let field = Field.pool
    let pool: BakerTarget
    
    var displayValue: String {
        pool.getDisplayValue()
    }
    var costParameters: [TransferCostParameter] {
        switch pool {
        case .passive:
            return [.target, .passive]
        case .bakerPool:
            return [.target]
        }
    }
    
    func add(to transaction: inout TransferDataType) {
        switch pool {
        case .passive:
            transaction.delegationType = "Passive"
        case .bakerPool(let bakerId):
            transaction.delegationType = "Baker"
            transaction.delegationTargetBaker = bakerId
        }
    }
}

// MARK: - Common data

struct AmountData: SimpleFieldValue {
    let field = Field.amount
    let amount: GTU
    
    var displayValue: String { amount.displayValueWithGStroke() }
    var costParameters: [TransferCostParameter] { [.amount] }
    
    func add(to transaction: inout TransferDataType) {
        transaction.capital = String(amount.intValue)
    }
}

struct RestakeDelegationData: SimpleFieldValue {
    let field = Field.restake
    let restake: Bool
    
    var displayValue: String {
        if restake {
            return "delegation.receipt.addedtodelegation".localized
        } else {
            return "delegation.receipt.notaddedtodelegation".localized
        }
    }
    var costParameters: [TransferCostParameter] { [.restake] }
    
    func add(to transaction: inout TransferDataType) {
        transaction.restakeEarnings = restake
    }
}

enum StakeWarning {
    case noChanges
    case loweringStake
    case moreThan95
    case amountZero
}

@resultBuilder
enum CurrentDataBuilder {
    static func buildBlock(_ components: StakeDataConvertible...) -> [StakeData] {
        return components.map { $0.asStakeData }
    }
    
    static func buildFinalResult(_ component: [StakeData]) -> Set<StakeData> {
        return Set(component)
    }
}

class StakeDataHandler {
    let transferType: TransferType
    
    // this is the data that is currently on the chain
    private let currentData: Set<StakeData>?
    
    // this is what we are now changing
    private var data: Set<StakeData> = Set()

    init(transferType: TransferType) {
        self.transferType = transferType
        self.currentData = nil
    }
    
    init(transferType: TransferType, @CurrentDataBuilder currentData: () -> Set<StakeData>) {
        self.transferType = transferType
        self.currentData = currentData()
    }
    
    /// Remove an entry by field
    func remove(field: Field) {
        if let entry = data.filter({ $0.field == field }).first {
            data.remove(entry)
        }
    }
    /// An entry is added only if its value is changed compared to the data that is being updated
    /// An entry is always added in case of new registration
    func add<T: FieldValue>(entry: T) {
        let stakeData = entry.asStakeData
        let isValueUnchanged = currentData?.contains(where: { data in
            data === stakeData
        }) ?? false
        
        // we always allow the account to be in the new data
        if isValueUnchanged && !(entry is AccountValue) {
            // remove current value from current data
            self.remove(field: entry.field)
            return
        }
        // we add or update to the set for the specific field
        // only one entry per field, as the == is overwritten
        data.update(with: stakeData)
    }
    
    /// Retrieves an entry from the currently saved value
    func getCurrentEntry<T: FieldValue>() -> T? {
        return currentData?.filter({ $0.value is T}).first?.value as? T
    }
    
    func getCurrentEntry<T: FieldValue>(_ type: T.Type) -> T? {
        return currentData?.filter({ $0.value is T }).first?.value as? T
    }
    
    /// Retrieves an entry from the updated values (current trasnaction)
    func getNewEntry<T: FieldValue>() -> T? {
        return data.filter({ $0.value is T}).first?.value as? T
    }
    
    func getNewEntry<T: FieldValue>(_ type: T.Type) -> T? {
        return data.filter({ $0.value is T }).first?.value as? T
    }
    
    /// Checks if we are updating
    func hasCurrentData() -> Bool {
        self.currentData != nil
    }
    
    /// Retrieves all the fields that were changed sorted in the right order for display
    func getAllOrdered() -> [DisplayValue] {
        return data
            .sorted { lhs, rhs in
                lhs.field.getOrderIndex() < rhs.field.getOrderIndex()
            }
            .flatMap { $0.displayValues }
    }
    
    func getCurrentOrdered() -> [DisplayValue] {
        return currentData?
            .sorted { lhs, rhs in
                lhs.field.getOrderIndex() < rhs.field.getOrderIndex()
            }
            .flatMap { $0.displayValues } ?? []
    }
    
    func getCurrentWarning(atDisposal balance: Int) -> StakeWarning? {
        if !containsChanges() {
            return .noChanges
        } else if isLoweringStake() {
            return .loweringStake
        } else if moreThan95(atDisposal: balance) {
            return .moreThan95
        } else if isNewAmountZero() {
            return .amountZero
        } else {
            return nil
        }
    }
    
    /// Checks if the amount we are now selecting is lower that the previous amount
    func isLoweringStake() -> Bool {
        guard let currentAmount: AmountData = getCurrentEntry() else {
            return false
        }
        guard let newAmount: AmountData = getNewEntry() else {
            return false
        }
        if newAmount.amount.intValue < currentAmount.amount.intValue {
            return true
        }
        return false
    }
    
    func isNewAmountZero() -> Bool {
        guard let newAmount: AmountData = getNewEntry() else {
            return false
        }
        if newAmount.amount.intValue == 0 {
            return true
        }
        return false
    }
  
    /// Checks is the new delegation amount is using over 95% of funds
    func moreThan95(atDisposal: Int) -> Bool {
        guard let newAmount: AmountData = getNewEntry() else {
            return false
        }
        if Double(newAmount.amount.intValue) > Double(atDisposal) * 0.95 {
            return true
        }
        return false
    }
    
    /// Checks if there are any changes to the stake data
    func containsChanges() -> Bool {
        // we remove the account data and see if there are any actual changes
        let res = data.filter({ !($0.value is AccountValue)}).count
        return res != 0
    }
    
    func getCostParameters() -> [TransferCostParameter] {
        data.compactMap { data in
            data.value.costParameters
        }.reduce([], +)
    }
    
    func getTransferObject() -> TransferDataType {
        var transfer = TransferDataTypeFactory.create()
        transfer.transferType = transferType
        data.forEach { data in
            data.value.add(to: &transfer)
        }
        if transfer.transferType == .removeDelegation || transfer.transferType == .removeBaker {
            transfer.capital = "0"
        }
        return transfer
    }
}
