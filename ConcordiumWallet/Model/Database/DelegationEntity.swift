//
//  DelegationEntity.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol DelegationDataType: DataStoreProtocol {
    var stakedAmount: Int { get set}
    var restakeEarnings: Bool { get set}
    var delegationTargetType: String { get set}
    var delegationTargetBakerID: Int { get set}
    var pendingChange: PendingChangeDataType? { get set }
}

final class DelegationEntity: Object {
    @objc dynamic var stakedAmount: Int = 0
    @objc dynamic var restakeEarnings: Bool = false
    @objc dynamic var delegationTargetType: String = ""
    @objc dynamic var delegationTargetBakerID: Int = -1
    @objc dynamic var pendingChangeEntity: PendingChangeEntity?
    
    convenience init(accountDelegationModel: AccountDelegation) {
        self.init()
        self.stakedAmount = Int(accountDelegationModel.stakedAmount) ?? 0
        self.restakeEarnings = accountDelegationModel.restakeEarnings
        self.delegationTargetType = accountDelegationModel.delegationTarget.delegateType
        self.delegationTargetBakerID = accountDelegationModel.delegationTarget.bakerID ?? -1
        self.pendingChangeEntity = PendingChangeEntity(pendingChange: accountDelegationModel.pendingChange)
    }
}

extension DelegationEntity: DelegationDataType {
    var pendingChange: PendingChangeDataType? {
        get {
            pendingChangeEntity
        }
        set {
            self.pendingChangeEntity = newValue as? PendingChangeEntity
        }
    }
}
