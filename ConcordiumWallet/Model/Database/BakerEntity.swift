//
//  BakerEntity.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//
import Foundation
import RealmSwift

protocol BakerDataType: DataStoreProtocol {
    var bakerID: Int { get set }
    var stakedAmount: Int { get set }
    var restakeEarnings: Bool { get set }
    var bakerAggregationVerifyKey: String { get set }
    var bakerElectionVerifyKey: String { get set }
    var bakerSignatureVerifyKey: String { get set }
    var pendingChange: PendingChangeDataType? { get set }
}

final class BakerEntity: Object {
    @objc dynamic var bakerID: Int = -1
    @objc dynamic var stakedAmount: Int = 0
    @objc dynamic var restakeEarnings: Bool = false
    @objc dynamic var bakerAggregationVerifyKey: String = ""
    @objc dynamic var bakerElectionVerifyKey: String = ""
    @objc dynamic var bakerSignatureVerifyKey: String = ""
    @objc dynamic var pendingChangeEntity: PendingChangeEntity?
        
    convenience init(accountBakerModel: AccountBaker) {
        self.init()
        self.bakerID = accountBakerModel.bakerID
        self.stakedAmount = Int(accountBakerModel.stakedAmount) ?? 0
        self.restakeEarnings = accountBakerModel.restakeEarnings
        self.bakerAggregationVerifyKey = accountBakerModel.bakerAggregationVerifyKey
        self.bakerElectionVerifyKey = accountBakerModel.bakerElectionVerifyKey
        self.bakerSignatureVerifyKey = accountBakerModel.bakerSignatureVerifyKey
        self.pendingChangeEntity = PendingChangeEntity(pendingChange: accountBakerModel.pendingChange)
    }
}

extension BakerEntity: BakerDataType {
    var pendingChange: PendingChangeDataType? {
        get {
            pendingChangeEntity
        }
        set {
            self.pendingChangeEntity = newValue as? PendingChangeEntity
        }
    }
}
