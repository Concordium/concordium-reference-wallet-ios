//
//  ShieldedAmount.swift
//  ConcordiumWallet
//
//  Concordium on 03/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol ShieldedAmountType: DataStoreProtocol {
    var primaryKey: String { get set }
    var account: AccountDataType? { get set }
    var encryptedValue: String { get set }
    var decryptedValue: String { get set }
    var incomingAmountIndex: Int { get set }
    func with(account: AccountDataType, encryptedValue: String, decryptedValue: String, incomingAmountIndex: Int) -> ShieldedAmountType
    func withInitialValue(for account: AccountDataType) -> ShieldedAmountType
}

struct ShieldedAmountTypeFactory {
    static func create() -> ShieldedAmountType {
        ShieldedAmountEntity()
    }
}

final class ShieldedAmountEntity: Object {
    @objc dynamic var accountEntity: AccountEntity? = AccountEntity()
    @objc dynamic var encryptedValue: String = ""
    @objc dynamic var decryptedValue: String = ""
    @objc dynamic var incomingAmountIndex: Int = -1 // -1 means no index
    @objc dynamic var primaryKey: String = ""

    // swiftlint:disable line_length
    static let zeroValue = "c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    
    override class func primaryKey() -> String? {
        "primaryKey"
    }
    
    func with(account: AccountDataType, encryptedValue: String, decryptedValue: String, incomingAmountIndex: Int) -> ShieldedAmountType {
        _ = write {
            let shieldedAmount = $0
            shieldedAmount.account = account
            shieldedAmount.encryptedValue = encryptedValue
            shieldedAmount.decryptedValue = decryptedValue
            shieldedAmount.incomingAmountIndex = incomingAmountIndex
            shieldedAmount.primaryKey = account.address + encryptedValue
        }
        return self
    }

    func withInitialValue(for account: AccountDataType) -> ShieldedAmountType {
        _ = write {
            let shieldedAmount = $0
            shieldedAmount.account = account
            shieldedAmount.encryptedValue = ShieldedAmountEntity.zeroValue
            shieldedAmount.decryptedValue = "0"
            shieldedAmount.incomingAmountIndex = -1
            shieldedAmount.primaryKey = account.address + ShieldedAmountEntity.zeroValue
        }
        return self
    }
}

extension ShieldedAmountEntity: ShieldedAmountType {
    var account: AccountDataType? {
        get {
            accountEntity
        }
        set {
            self.accountEntity = newValue as? AccountEntity
        }
    }
}
