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
    var submissionId: String? { get set }
    var transactionStatus: SubmissionStatusEnum? { get set }
    
    var encryptedAccountData: String? { get set }
    var encryptedPrivateKey: String? { get set}
    var encryptedCommitmentsRandomness: String? { get set }
    
    var identity: IdentityDataType? { get set }
    var revealedAttributes: [String: String] { get set }
    
    var finalizedBalance: Int { get set }
    var forecastBalance: Int { get set }
    var forecastAtDisposalBalance: Int {get set}
    var stakedAmount: Int { get set}
    
    var finalizedEncryptedBalance: Int { get set }
    var forecastEncryptedBalance: Int { get set }
    
    var totalForecastBalance: Int { get set }
    var encryptedBalance: EncryptedBalanceDataType? {get set}
    
    var encryptedBalanceStatus: ShieldedAccountEncryptionStatus? { get set }
    var accountNonce: Int {get set}
    
    var credential: Credential? { get set }
    var createdTime: Date { get }
    var usedIncomingAmountIndex: Int { get set}
    var isReadOnly: Bool { get set }
    var bakerId: Int { get set }
    var releaseSchedule: ReleaseScheduleDataType? { get set }
    var transferFilters: TransferFilter? { get set }
    
    func withUpdatedForecastBalance(_ forecastBalance: Int,
                                    forecastShieldedBalance: Int,
                                    forecastAtDisposalBalance: Int) -> AccountDataType
    
    func withUpdatedFinalizedBalance(_ finaliedBalance: Int,
                                     _ finalizedEncryptedBalance: Int,
                                     _ status: ShieldedAccountEncryptionStatus,
                                     _ encryptedBalance: EncryptedBalanceDataType,
                                     accountNonce: Int,
                                     bakerId: Int,
                                     staked: Int,
                                     releaseSchedule: ReleaseScheduleDataType) -> AccountDataType
    
    func withUpdatedIdentity(identity: IdentityDataType) -> AccountDataType
    func withUpdatedStatus(status: SubmissionStatusEnum) -> AccountDataType
    func withTransferFilters(filters: TransferFilter) -> AccountDataType
    func withMarkAsReadOnly(_ isReadOnly: Bool = true) -> AccountDataType
}

extension AccountDataType {
    func withUpdatedForecastBalance(_ forecastBalance: Int, forecastShieldedBalance: Int, forecastAtDisposalBalance: Int) -> AccountDataType {
        _ = write {
            var pAccount = $0
            pAccount.forecastBalance = forecastBalance
            pAccount.forecastEncryptedBalance = forecastShieldedBalance
            pAccount.forecastAtDisposalBalance = forecastAtDisposalBalance
        }
        return self
    }

    func withUpdatedFinalizedBalance(_ finaliedBalance: Int,
                                     _ finalizedEncryptedBalance: Int,
                                     _ status: ShieldedAccountEncryptionStatus,
                                     _ encryptedBalance: EncryptedBalanceDataType,
                                     accountNonce: Int, bakerId: Int, staked: Int,
                                     releaseSchedule: ReleaseScheduleDataType) -> AccountDataType {
        _ = write {
            var pAccount = $0
            pAccount.finalizedBalance = finaliedBalance
            pAccount.finalizedEncryptedBalance = finalizedEncryptedBalance
            pAccount.encryptedBalanceStatus = status
            pAccount.encryptedBalance = encryptedBalance
            pAccount.accountNonce = accountNonce
            pAccount.bakerId = bakerId
            pAccount.stakedAmount = staked
            pAccount.releaseSchedule = releaseSchedule
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

    func withTransferFilters(filters: TransferFilter) -> AccountDataType {
        _ = write {
            var pAccount = $0
            pAccount.transferFilters = filters
        }
        return self
    }
    
    func withMarkAsReadOnly(_ isReadOnly: Bool = true) {
        _ = write {
            var pAccount = $0
            pAccount.isReadOnly = isReadOnly
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
    @objc dynamic var forecastAtDisposalBalance: Int = 0
    @objc dynamic var stakedAmount: Int = 0
    @objc dynamic var forecastEncryptedBalance: Int = 0
    @objc dynamic var finalizedEncryptedBalance: Int = 0
    @objc dynamic var accountNonce: Int = 0
    @objc dynamic var createdTime = Date()
    @objc dynamic var credentialJson = ""
    @objc dynamic var usedIncomingAmountIndex: Int = 0
    @objc dynamic var isReadOnly: Bool = false
    @objc dynamic var bakerId: Int = -1
    @objc dynamic var releaseScheduleEntity: ReleaseScheduleEntity?
    @objc dynamic var transferFilters: TransferFilter? = TransferFilter()
    var revealedAttributesList = List<IdentityAttributeEntity>()

    override class func primaryKey() -> String? {
        "address"
    }
}

extension AccountEntity: AccountDataType {
    
    var displayName: String {
        get {
            if let name = name, name.count > 0 {
                return name
            }
            let lowerBound = address.startIndex
            let upperBound = address.index(lowerBound, offsetBy: 8)
            return "<" + String(address[lowerBound..<upperBound]) + ">"
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
}
