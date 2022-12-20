//
// Created by Concordium on 27/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol AccountDataType: DataStoreProtocol {
    var name: String? { get set }
    var displayName: String { get }
    var address: String { get set }
    var accountIndex: Int { get set }
    var submissionId: String? { get set }
    var transactionStatus: SubmissionStatusEnum? { get set }
    
    var encryptedAccountData: String? { get set }
    var encryptedPrivateKey: String? { get set}
    var encryptedCommitmentsRandomness: String? { get set }
    
    var identity: IdentityDataType? { get set }
    var revealedAttributes: [String: String] { get set }
    
    var finalizedBalance: Int { get set }
    var forecastBalance: Int { get set }
    
    var finalizedEncryptedBalance: Int { get set }
    var forecastEncryptedBalance: Int { get set }
    
    var totalForecastBalance: Int { get set }
    var encryptedBalance: EncryptedBalanceDataType? {get set}
    
    var encryptedBalanceStatus: ShieldedAccountEncryptionStatus? { get set }
    var accountNonce: Int {get set}
    
    var credential: Credential? { get set }
    var createdTime: Date { get }
    var usedIncomingAmountIndex: Int { get set }
    var isReadOnly: Bool { get set }
   
    var baker: BakerDataType? { get set }
    var delegation: DelegationDataType? { get set }
    
    var releaseSchedule: ReleaseScheduleDataType? { get set }
    var transferFilters: TransferFilter? { get set }
    
    var showsShieldedBalance: Bool {get set}
    var hasShieldedTransactions: Bool {get set}
    
    func withUpdatedForecastBalance(_ forecastBalance: Int,
                                    forecastShieldedBalance: Int) -> AccountDataType
    
    func withUpdatedFinalizedBalance(_ finaliedBalance: Int,
                                     _ finalizedEncryptedBalance: Int,
                                     _ status: ShieldedAccountEncryptionStatus,
                                     _ encryptedBalance: EncryptedBalanceDataType,
                                     hasShieldedTransactions: Bool,
                                     accountNonce: Int,
                                     accountIndex: Int,
                                     delegation: DelegationDataType?,
                                     baker: BakerDataType?,
                                     releaseSchedule: ReleaseScheduleDataType) -> AccountDataType
    
    func withUpdatedIdentity(identity: IdentityDataType) -> AccountDataType
    func withUpdatedStatus(status: SubmissionStatusEnum) -> AccountDataType
    func withTransferFilters(filters: TransferFilter) -> AccountDataType
    func withMarkAsReadOnly(_ isReadOnly: Bool) -> AccountDataType
    func withShowShielded(_ showsShieled: Bool) -> AccountDataType
}

extension AccountDataType {
    var forecastAtDisposalBalance: Int {
        let stakedAmount = baker?.stakedAmount ?? delegation?.stakedAmount ?? 0
        let scheduledTotal = releaseSchedule?.total ?? 0
        
        return forecastBalance - max(stakedAmount, scheduledTotal)
    }
    
    func withUpdatedForecastBalance(_ forecastBalance: Int, forecastShieldedBalance: Int) -> AccountDataType {
        _ = write {
            var pAccount = $0
            pAccount.forecastBalance = forecastBalance
            pAccount.forecastEncryptedBalance = forecastShieldedBalance
        }
        return self
    }

    func withUpdatedFinalizedBalance(_ finaliedBalance: Int,
                                     _ finalizedEncryptedBalance: Int,
                                     _ status: ShieldedAccountEncryptionStatus,
                                     _ encryptedBalance: EncryptedBalanceDataType,
                                     hasShieldedTransactions: Bool,
                                     accountNonce: Int,
                                     accountIndex: Int,
                                     delegation: DelegationDataType?,
                                     baker: BakerDataType?,
                                     releaseSchedule: ReleaseScheduleDataType) -> AccountDataType {
        _ = write {
            var pAccount = $0
            pAccount.finalizedBalance = finaliedBalance
            pAccount.finalizedEncryptedBalance = finalizedEncryptedBalance
            pAccount.encryptedBalanceStatus = status
            pAccount.encryptedBalance = encryptedBalance
            pAccount.accountNonce = accountNonce
            pAccount.accountIndex = accountIndex
            pAccount.delegation = delegation
            pAccount.baker = baker
            pAccount.releaseSchedule = releaseSchedule
            pAccount.hasShieldedTransactions = hasShieldedTransactions
        }
        return self
    }
    
    func withUpdatedIdentity(identity: IdentityDataType) -> AccountDataType {
        _ = write {
            var pAccount = $0
            pAccount.identity = identity
            pAccount.transactionStatus = SubmissionStatusEnum.committed
        }
        return self
    }
    
    func withUpdatedStatus(status: SubmissionStatusEnum) -> AccountDataType {
        _ = write {
            var pAccount = $0
            pAccount.transactionStatus = status
        }
        return self
    }
    func withShowShielded(_ showsShieled: Bool) -> AccountDataType {
        _ = write {
            var pAccount = $0
            pAccount.showsShieldedBalance = showsShieled
        }
        return self
    }

    func withTransferFilters(filters: TransferFilter) -> AccountDataType {
        _ = write {
            var pAccount = $0
            pAccount.transferFilters = filters
        }
        return self
    }
    
    func withMarkAsReadOnly(_ isReadOnly: Bool) -> AccountDataType {
        _ = write {
            var pAccount = $0
            pAccount.isReadOnly = isReadOnly
        }
        return self
    }
    
    func canTransfer(amount: GTU, withTransferCost cost: GTU, onBalance balanceType: AccountBalanceTypeEnum) -> Bool {
        if balanceType == .balance {
            let balance = self.forecastAtDisposalBalance
            return amount.intValue + cost.intValue <= balance
        } else {
            return amount.intValue <= self.forecastEncryptedBalance && cost.intValue <= self.forecastAtDisposalBalance
        }
    }
}

struct AccountDataTypeFactory {
    static func create() -> AccountDataType {
        AccountEntity()
    }
}

final class AccountEntity: Object {
    @objc dynamic var name: String? = ""
    @objc dynamic var address: String = ""
    @objc dynamic var accountIndex: Int = 0
    @objc dynamic var submissionId: String? = ""
    @objc dynamic var transactionStatusString: String? = ""
    @objc dynamic var encryptedBalanceStatusString: String? = ""
    @objc dynamic var encryptedAccountData: String? = ""
    @objc dynamic var encryptedCommitmentsRandomness: String? = ""
    @objc dynamic var encryptedPrivateKey: String? = ""
    @objc dynamic var identityEntity: IdentityEntity?
    @objc dynamic var encryptedBalanceEntity: EncryptedBalanceEntity? = EncryptedBalanceEntity()
    @objc dynamic var finalizedBalance: Int = 0
    @objc dynamic var forecastBalance: Int = 0
    @objc dynamic var forecastEncryptedBalance: Int = 0
    @objc dynamic var finalizedEncryptedBalance: Int = 0
    @objc dynamic var accountNonce: Int = 0
    @objc dynamic var createdTime = Date()
    @objc dynamic var credentialJson = ""
    @objc dynamic var usedIncomingAmountIndex: Int = 0
    @objc dynamic var isReadOnly: Bool = false
 
    @objc dynamic var releaseScheduleEntity: ReleaseScheduleEntity?
    @objc dynamic var bakerEntity: BakerEntity?
    @objc dynamic var delegationEntity: DelegationEntity?
    
    @objc dynamic var transferFilters: TransferFilter? = TransferFilter()
    var revealedAttributesList = List<IdentityAttributeEntity>()
    @objc dynamic var showsShieldedBalance: Bool = false
    @objc dynamic var hasShieldedTransactions: Bool = false
    
    override class func primaryKey() -> String? {
        "address"
    }
}

extension AccountEntity: AccountDataType {
    
    var displayName: String {
        get {
            if name != nil && !name!.isEmpty {
                return name!
            }
            return address.prefix(4) + "..." + address.suffix(4)
        }
    }
    
    var totalForecastBalance: Int {
        get {
             return forecastBalance + forecastEncryptedBalance
        }
        // swiftlint:disable unused_setter_value
        set {
        }
    }

    var identity: IdentityDataType? {
        get {
            identityEntity
        }
        set {
            self.identityEntity = newValue as? IdentityEntity
        }
    }

    var encryptedBalance: EncryptedBalanceDataType? {
        get {
            encryptedBalanceEntity
        }
        set {
            self.encryptedBalanceEntity = newValue as? EncryptedBalanceEntity
        }
    }
    
    var revealedAttributes: [String: String] {
        get {
            revealedAttributesList.reduce(into: [String: String]()) { (dict, attribute) in
                dict[attribute.name] = attribute.value
            }
        }
        set {
            let attributes = newValue.map { IdentityAttributeEntity(name: $0.key, value: $0.value) }
            revealedAttributesList.removeAll()
            revealedAttributesList.append(objectsIn: attributes)
        }
    }

    var transactionStatus: SubmissionStatusEnum? {
        get {
            SubmissionStatusEnum(rawValue: transactionStatusString ?? "")
        }
        set {
            transactionStatusString = newValue?.rawValue
        }
    }
    
    var encryptedBalanceStatus: ShieldedAccountEncryptionStatus? {
        get {
            ShieldedAccountEncryptionStatus(rawValue: encryptedBalanceStatusString ?? "")
        }
        set {
            encryptedBalanceStatusString = newValue?.rawValue
        }
    }
    
    var credential: Credential? {
        get {
            try? Credential(credentialJson)
        }
        set {
            guard let credentialJson = try? newValue?.jsonString() else { return }
            self.credentialJson = credentialJson
        }
    }
    
    var releaseSchedule: ReleaseScheduleDataType? {
        get {
            return releaseScheduleEntity
        }
        set {
             self.releaseScheduleEntity = newValue as? ReleaseScheduleEntity
        }
    }
    
    var delegation: DelegationDataType? {
        get {
            return delegationEntity
        }
        set {
             self.delegationEntity = newValue as? DelegationEntity
        }
    }
    var baker: BakerDataType? {
        get {
            return bakerEntity
        }
        set {
             self.bakerEntity = newValue as? BakerEntity
        }
    }
}
